struct Hailo::Token::Probability
  getter token_id : TokenId
  getter p : Float64

  def initialize(@token_id, @p)
  end

  def inspect(io) : Nil
    io << sprintf("%d => %.2f%%", @token_id, @p*100)
  end
end
