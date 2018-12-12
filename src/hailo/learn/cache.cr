require "../markov"
require "../token"
require "../token/state"

class Hailo::Learn::Cache
  include Hailo::Markov

  getter tokens = Hash(Token, Token::State).new
  getter exprs = Hash(Expression, LinkCounts).new
  @order : Int32

  def initialize(@order)
  end

  def learn_from_tokens(tokens) : Nil
    seen_tokens = Set(Token).new
    token_ids = tokens.map do |token|
      @tokens[token] ||= Token::State.new(@tokens.size + 1, 0)

      if !seen_tokens.includes?(token)
        seen_tokens << token
        @tokens[token] = Token::State.new(@tokens[token].id, @tokens[token].occurrences + 1)
      end

      @tokens[token].id
    end

    process_markov_chain(token_ids, @order) do |expr, prev_token_id, next_token_id|
      link_counts = @exprs[expr] ||= LinkCounts.new

      prev_counts = link_counts[prev_token_id] ||= {prev: 0, next: 0}
      link_counts[prev_token_id] = {prev: prev_counts[:prev] + 1, next: prev_counts[:next]}
      next_counts = link_counts[next_token_id] ||= {prev: 0, next: 0}
      link_counts[next_token_id] = {prev: next_counts[:prev], next: next_counts[:next] + 1}
    end
  end
end
