module Hailo::Markov
  DEFAULT_MARKOV_ORDER = 2
  BOUNDARY_TOKEN_ID    = 0

  # process_markov_chain([1,2,3,4,5], 2) would result in:
  #
  #   yield 0, [1, 2], 3
  #   yield 1, [2, 3], 4
  #   yield 2, [3, 4], 5
  #   yield 3, [4, 5], 0
  private def process_markov_chain(token_ids, order) : Nil
    (0..token_ids.size - order).each do |i|
      expr = token_ids[i..i + order - 1]
      prev_id = i == 0 ? BOUNDARY_TOKEN_ID : token_ids[i - 1]
      next_id = i == token_ids.size - order ? BOUNDARY_TOKEN_ID : token_ids[i + order]

      yield prev_id, expr, next_id
    end
  end
end
