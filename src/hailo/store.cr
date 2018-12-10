require "db"
require "msgpack"
require "sqlite3"
require "./token"
require "./token/state"

module Hailo::Store
  @select = Hash(String, DB::Statement).new
  @insert = Hash(String, DB::Statement).new

  private def open_storage(brain_file)
    DB.connect brain_file ? "sqlite3:#{brain_file}" : "sqlite3::memory:"
  end

  private def init_storage(order)
    @db.scalar "PRAGMA journal_mode=WAL"
    @db.exec "PRAGMA synchronous=OFF"
    order ||= DEFAULT_MARKOV_ORDER

    new = new_storage?
    if new
      used_order = order
      create_schema(order)
      create_indexes(order)
    else
      old_order = get_info("markov_order")
      raise "Couldn't retrieve Markov order from existing brain" if !old_order
      used_order = old_order.to_i32
    end

    prepare_statements(used_order)
    @insert["info"].exec(["markov_order", order]) if new

    used_order
  end

  private def new_storage?
    @db.query("SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'info'") do |res|
      return false if res.move_next
    end

    true
  end

  private def create_schema(order)
    schema = Array(String).new

    schema.push <<-SQL
      CREATE TABLE info (
        attribute TEXT NOT NULL PRIMARY KEY,
        text      TEXT NOT NULL
      )
      SQL

    schema.push <<-SQL
      CREATE TABLE token (
        id          INTEGER PRIMARY KEY,
        text        TEXT    NOT NULL,
        spacing     INTEGER NOT NULL,
        occurrences INTEGER NOT NULL
      )
      SQL

    token_columns = (1..order).map { |i| "token#{i}_id" }
    token_column_defs = token_columns.map do |name|
      "#{name}   INTEGER NOT NULL,"
    end.join "\n  "

    schema.push <<-SQL
      CREATE TABLE expr (
        #{token_column_defs}
        link_counts BLOB NOT NULL,
        PRIMARY KEY (#{token_columns.join ", "})
      ) WITHOUT ROWID
      SQL

    schema.each { |sql| @db.exec sql }
  end

  private def create_indexes(order)
    @db.exec "CREATE UNIQUE INDEX token_text_spacing on token (text, spacing)"

    (2..order).each do |i|
      @db.exec "CREATE INDEX expr_token#{i}_id on expr (token#{i}_id)"
    end
  end

  private def drop_indexes
    @db.exec "DROP INDEX IF EXISTS token_text_spacing"

    (2..@order).each do |i|
      @db.exec "DROP INDEX IF EXISTS expr_token#{i}_id"
    end
  end

  private def bulk_update
    drop_indexes
    yield
    create_indexes(@order)
    @db.exec "VACUUM"
  end

  private def get_info(attr : String)
    @db.query("SELECT text FROM info WHERE attribute = ?", attr) do |res|
      return res.read(String) if res.move_next
    end
  end

  private def prepare_statements(order)
    @insert["info"] =
      @db.build("INSERT OR REPLACE INTO info (attribute, text) VALUES (?, ?)")
    @insert["token"] =
      @db.build("INSERT OR REPLACE INTO token (id, text, spacing, occurrences) VALUES (?, ?, ?, ?)")
    @insert["token_autoinc"] =
      @db.build("INSERT INTO token (text, spacing, occurrences) VALUES (?, ?, ?)")

    token_columns = (1..order).map { |i| "token#{i}_id" }
    @insert["expr"] =
      @db.build("INSERT OR REPLACE INTO expr (#{token_columns.join ", "}, link_counts) VALUES (?, #{token_columns.map { "?" }.join %[, ]})")

    token_where = token_columns.map { |t| "#{t} = ?" }.join " AND "
    @select["get_link_counts"] = @db.build "SELECT link_counts FROM expr WHERE #{token_where}"

    (1..order).each do |i|
      @select["expr_by_token#{i}_id"] =
        @db.build "SELECT #{token_columns.join ','} FROM expr WHERE token#{i}_id = ? ORDER BY RANDOM() LIMIT 1"
    end

    @select["random_token_id"] = @db.build "SELECT id FROM token WHERE id >= (abs(RANDOM()) % (SELECT max(id) FROM token))+1 LIMIT 1"
  end

  private def add_info(attr, value)
    @insert["info"].exec([attr, value])
  end

  private def add_token(id, text, spacing, occurrences)
    @insert["token"].exec([id, text, spacing, occurrences])
  end

  private def add_expr(expr, link_counts)
    @insert["expr"].exec([expr, link_counts].flatten)
  end

  private def get_token_state(tokens)
    token_states = Hash(Token, Token::State).new
    return token_states if tokens.empty?

    where = tokens.map do |token|
      text = token.text.gsub /'/, "''"
      "(text = '#{text}' AND spacing = #{token.spacing.value})"
    end.join " OR "

    @db.query "SELECT * FROM token WHERE #{where}" do |rs|
      rs.each do
        token_id, text, spacing, occurrences = rs.read(Int32, String, Int32, Int32)
        token = Token.new(text, Token::Spacing.new(spacing))
        state = Token::State.new(token_id, occurrences)
        token_states[token] = state
      end
    end

    token_states
  end

  private def increase_token_occurrences(tokens)
    return Array(TokenId).new if tokens.empty?
    token_states = get_token_state(tokens)

    # increase occurrences count of known tokens
    token_states.each do |token, state|
      @insert["token"].exec([state.id, token.text, token.spacing.value, state.occurrences + 1])
    end

    # add unknown tokens
    missing = tokens.select { |t| !token_states.has_key?(t) }.uniq
    rows_to_add = missing.each do |token|
      result = @insert["token_autoinc"].exec([token.text, token.spacing.value, 1])
      token_id = result.last_insert_id.to_i32
      token_states[token] = Token::State.new(token_id, 1)
    end

    tokens.map { |t| token_states[t].id }
  end

  private def get_link_counts(expr)
    rs = @select["get_link_counts"].query expr
    rs.move_next ? LinkCounts.from_msgpack(rs.read(Bytes)) : LinkCounts.new
  end

  private def increase_link_counts(expr, prev_token_id, next_token_id)
    link_counts = get_link_counts(expr)

    prev_counts = link_counts[prev_token_id] ||= {prev: 0, next: 0}
    link_counts[prev_token_id] = {prev: prev_counts[:prev] + 1, next: prev_counts[:next]}
    next_counts = link_counts[next_token_id] ||= {prev: 0, next: 0}
    link_counts[next_token_id] = {prev: next_counts[:prev], next: next_counts[:next] + 1}

    @insert["expr"].exec [expr, link_counts.to_msgpack].flatten
  end

  private def get_tokens(token_ids)
    return Array(Token).new if token_ids.empty?
    placeholders = (1..token_ids.size).map { '?' }.join ','

    tokens = Hash(TokenId, Token).new
    @db.query "SELECT id, text, spacing FROM token WHERE id IN (#{placeholders})", token_ids do |rs|
      rs.each do
        id, text, spacing = rs.read(Int32, String, Int32)
        token = Token.new(text, Token::Spacing.new(spacing))
        tokens[id] = token
      end
    end

    token_ids.map { |id| tokens[id] }
  end

  private def get_random_token_id
    @select["random_token_id"].query do |res|
      return res.read(Int32) if res.move_next
    end
  end

  private def get_expr_by_token_id(token_id = nil)
    token_id = get_random_token_id if !token_id

    (1..@order).to_a.shuffle.each do |pos|
      @select["expr_by_token#{pos}_id"].query(token_id) do |res|
        return (0...res.column_count).map { res.read(Int32) } if res.move_next
      end
    end

    return
  end
end
