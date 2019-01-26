class Hailo
  VERSION = "0.1.0"
end

require "./hailo/markov"
require "./hailo/parse"
require "./hailo/learn"
require "./hailo/store"
require "./hailo/reply"
require "./hailo/lists"

class Hailo
  include Hailo::Markov
  include Hailo::Parse
  include Hailo::Learn
  include Hailo::Store
  include Hailo::Reply
  include Hailo::Lists

  alias TokenId = Int32
  alias Expression = Array(TokenId)
  alias LinkCounts = Hash(TokenId, NamedTuple(prev: Int32, next: Int32))

  @swap_tokens : Hash(String, String)
  @ban_tokens : Set(String)
  @order : Int32
  @db : DB::Connection
  @debug = false

  def initialize(brain_file = nil, order = nil, @debug = false,
                 swap_tokens = DEFAULT_SWAP_TOKENS,
                 ban_tokens = DEFAULT_BAN_TOKENS)
    @db = open_storage(brain_file)
    @order = init_storage_and_get_order(order)
    @swap_tokens = process_swap_tokens(swap_tokens)
    @ban_tokens = process_ban_tokens(ban_tokens)
  end

  def learn_and_reply(message) : String?
    learn(message)
    reply(message)
  end
end
