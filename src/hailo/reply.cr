require "./token"
require "./token/probability"

module Hailo::Reply
  def reply(message = nil) : String?
    if message
      input_tokens = make_tokens(message)
      reply_tokens = choose_reply(input_tokens)
    else
      reply_tokens = choose_reply
    end

    return if !reply_tokens
    make_output(reply_tokens)
  end

  private def choose_reply(tokens = Array(Token).new) : Array(Token)?
    token_set = tokens.to_set
    candidates = get_key_candidates(token_set)
    key_token_states = get_token_state(candidates).values
    pivot_probs = get_pivot_probabilities(key_token_states)
    key_token_ids = key_token_states.map(&.id)
    key_token_set = key_token_ids.to_set

    best_reply = Array(TokenId).new
    best_score = 0.0
    elapsed_time = Time::Span.zero

    reply_count = 0
    while elapsed_time.seconds < 1
      elapsed_time += Time.measure do
        pivot_token_id = pivot_probs.empty? ? nil : choose_pivot(pivot_probs)
        pivot_expr = get_expr_by_token_id(pivot_token_id)
        return if !pivot_expr

        reply = generate_reply(pivot_expr)
        score = score_reply(reply, key_token_set)
        next if !best_reply.empty? && reply.to_set.subset? token_set

        if best_reply.empty? || score > best_score
          best_reply = reply
          best_score = score
        end
      end

      reply_count += 1

      # give other fibers a chance to work once in a while
      Fiber.yield if reply_count % 100 == 0
    end

    if @debug
      printf "[DEBUG] Generated %d replies. Best score: %.2f\n", reply_count, best_score
    end

    get_tokens(best_reply)
  end

  private def get_key_candidates(token_set) : Array(Token)
    candidates = Array(Token).new
    token_set.each do |token|
      next if token.spacing != Token::Spacing::Normal
      next if token_banned?(token.text)
      replacement = swap_token(token.text)
      candidates << (replacement ? Token.new(replacement) : token)
    end

    candidates
  end

  private def get_pivot_probabilities(token_states) : Array(Token::Probability)
    probabilities = Array(Token::Probability).new
    return probabilities if token_states.empty?
    return [Token::Probability.new(token_states[0].id, 1_f64)] if token_states.size == 1

    counts = token_states.map(&.occurrences)
    counts_sum = counts.sum
    probs = Array(Float64).new
    probs_sum = 0
    counts.each do |count|
      token_prob = -Math.log(count.fdiv counts_sum)/Math.log(2)
      probs << token_prob
      probs_sum += token_prob
    end

    token_states.map_with_index do |state, i|
      probabilities << Token::Probability.new(state.id, probs[i] / probs_sum)
    end

    probabilities
  end

  private def choose_pivot(token_probs) : TokenId
    random = Random.rand
    p_sum = 0
    token_probs.each do |token_prob|
      p_sum += token_prob.p
      return token_prob.token_id if p_sum > random
    end

    return token_probs[0].token_id
  end

  private def generate_reply(pivot_expr) : Array(TokenId)
    repeat_limit = Math.min(@order * 10, 50)
    output = pivot_expr.dup

    {:prev, :next}.each do |direction|
      expr = pivot_expr.dup
      i = 0
      loop do
        break if i % @order == 0 && (i >= repeat_limit * 3 ||
                 i >= repeat_limit && output.uniq.size <= @order)

        token_id = choose_linked_token_id(expr, direction)
        break if token_id == BOUNDARY_TOKEN_ID

        case direction
        when :prev
          output.unshift(token_id)
          expr = output.first(@order)
        when :next
          output << token_id
          expr = output.last(@order)
        end

        i += 1
      end
    end

    output
  end

  private def choose_linked_token_id(expr, direction) : TokenId
    link_counts = get_link_counts(expr)

    novel_tokens = Array(TokenId).new
    link_counts.each do |token_id, counts|
      counts[direction].times { novel_tokens << token_id }
    end

    novel_tokens.sample
  end

  private def score_reply(reply, key_token_set) : Float64
    score = 0_f64

    process_markov_chain(reply, @order) do |prev_token_id, expr, next_token_id|
      link_counts = nil

      if key_token_set.includes? prev_token_id
        link_counts ||= get_link_counts(expr)
        prob = link_counts[prev_token_id][:prev].fdiv link_counts.size
        score -= Math.log(prob)/Math.log(2)
      end

      if key_token_set.includes? next_token_id
        link_counts ||= get_link_counts(expr)
        prob = link_counts[next_token_id][:next].fdiv link_counts.size
        score -= Math.log(prob)/Math.log(2)
      end
    end

    # reduce the score of replies that contain more of the key tokens,
    # since they are probably less surprising
    key_count = reply.count { |t| key_token_set.includes? t }
    score /= Math.sqrt(key_count) if key_count > 1

    score
  end
end
