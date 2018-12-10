require "msgpack"
require "./progress"
require "./learn/cache"

module Hailo::Learn
  include Hailo::Progress

  def learn(message)
    tokens = make_tokens(message)
    return if tokens.size < @order

    @db.transaction do |_|
      token_ids = increase_token_occurrences(tokens)

      process_markov_chain(token_ids, @order) do |expr, prev_token_id, next_token_id|
        increase_link_counts(expr, prev_token_id, next_token_id)
      end

      message_count = get_info("message_count")
      new_count = message_count ? message_count.to_i32 + 1 : 1
      add_info("message_count", new_count)
    end
  end

  def train(train_file, progress = false)
    bulk_update do
      learn_with_cache(train_file, progress)
    end
  end

  private def learn_with_cache(train_file, progress)
    cache = Learn::Cache.new(@order)
    nr_lines = File.read_lines(train_file).size
    message_count = 0

    with_progress(nr_lines, "(1/3) Analyzing input text", print: progress) do |update_progress|
      File.each_line(train_file) do |line|
        tokens = make_tokens(line)
        if tokens.size >= @order
          cache.learn_from_tokens(tokens)
          message_count += 1
        end
        update_progress.call(1)
      end
    end

    @db.transaction do |_|
      add_info("message_count", message_count)

      with_progress(cache.tokens.size, "(2/3) Storing tokens", print: progress) do |update_progress|
        cache.tokens.each do |token, state|
          add_token(state.id, token.text, token.spacing.value, state.occurrences)
          update_progress.call(1)
        end
      end

      with_progress(cache.exprs.size, "(3/3) Storing expressions", print: progress) do |update_progress|
        cache.exprs.each do |expr, link_counts|
          add_expr(expr, link_counts.to_msgpack)
          update_progress.call(1)
        end
      end
    end
  end
end
