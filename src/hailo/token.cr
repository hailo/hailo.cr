struct Hailo::Token
  enum Spacing
    Normal  = 0
    Prefix  = 1
    Postfix = 2
    Infix   = 3
  end

  getter text : String
  getter spacing : Spacing

  def initialize(@text, @spacing = Spacing::Normal)
  end

  def similar_tokens : Array(Token)
    (Spacing.values - [spacing]).map do |other_spacing|
      Token.new(text, other_spacing)
    end
  end

  def inspect(io) : Nil
    if !spacing.normal?
      io << spacing
      io << "|"
    end

    io << text
  end
end
