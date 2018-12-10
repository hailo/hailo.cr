class Hailo
  VERSION = "0.1.0"
end

require "./hailo/markov"
require "./hailo/parse"
require "./hailo/learn"
require "./hailo/store"
require "./hailo/reply"

class Hailo
  include Hailo::Markov
  include Hailo::Parse
  include Hailo::Learn
  include Hailo::Store
  include Hailo::Reply

  alias TokenId = Int32
  alias Expression = Array(TokenId)
  alias LinkCounts = Hash(TokenId, NamedTuple(prev: Int32, next: Int32))

  @order : Int32
  @db : DB::Connection
  @debug = false

  def initialize(brain_file = nil, order = nil, @debug = false)
    @db = open_storage(brain_file)
    @order = init_storage(order)
  end

  def learn_and_reply(message)
    learn(message)
    reply(message)
  end
end
