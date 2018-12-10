struct Hailo::Token::State
  getter id : TokenId
  getter occurrences : Int32

  def initialize(@id, @occurrences)
  end

  def inspect(io)
    io << sprintf("%d x %d", @id, @occurences)
  end
end
