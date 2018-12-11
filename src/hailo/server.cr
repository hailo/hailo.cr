require "http/server"
require "json"

class Hailo::Server
  class LearnRequest
    JSON.mapping(input: String)
  end

  class LearnAndReplyRequest
    JSON.mapping(input: String)
  end

  class ReplyRequest
    JSON.mapping(input: String?)
  end

  class Response
    JSON.mapping(reply: String?, error: String?)

    def initialize(@reply = nil, @error = nil); end
  end

  @hailo : Hailo
  @host : String
  @port : Int32

  def initialize(@hailo, @host, @port)
  end

  def run
    server = HTTP::Server.new do |context|
      context.response.content_type = "application/json"
      json = context.request.body

      if !json
        context.response.status_code = 400
        context.response.output << Response.new(error: "Missing JSON body").to_json
        next
      end

      reply = nil
      case context.request.path
      when "/learn"
        request = LearnRequest.from_json(json)
        @hailo.learn(request.input)
      when "/learn_and_reply"
        request = LearnAndReplyRequest.from_json(json)
        reply = @hailo.learn_and_reply(request.input)
      when "/reply"
        request = ReplyRequest.from_json(json)
        reply = @hailo.reply(request.input)
      else
        context.response.status_code = 404
        context.response.output << Response.new(error: "Unsupported endpoint").to_json
        next
      end

      context.response.status_code = 200
      response = Response.new(reply: reply)
      context.response.output << response.to_json
      p request
      p response
    rescue ex
      p ex
      context.response.status_code = 500
      context.response.output << Response.new(error: "Internal server error").to_json
    end

    server.bind_tcp @host, @port

    puts "Hailo is listening for JSON POST requests, e.g.:"
    puts %{  curl #{@host}:#{@port}/reply -H "Content-Type: application/json" -d '{"input": "oh hi there"}'}

    server.listen
  end
end
