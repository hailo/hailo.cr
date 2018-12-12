require "option_parser"
require "readline"
require "../hailo"
require "./server"

module Hailo::CLI
  USER_PROMPT = "> "
  HAILO_REPLY = "Hailo>"

  @@brain_file : String?
  @@train_file : String?
  @@order : Int32?
  @@debug = false
  @@run_server = false
  @@bind = "localhost"
  @@port = 9001

  def self.run : Nil
    parse_options
    hailo = Hailo.new(@@brain_file, @@order, @@debug)

    if train_file = @@train_file
      hailo.train(train_file, progress: true)
    elsif @@run_server
      Hailo::Server.new(hailo, @@bind, @@port).run
    else
      while bytes = LibReadline.readline(prompt: USER_PROMPT)
        line = String.new(bytes)
        hailo.learn(line)
        puts "#{HAILO_REPLY} #{hailo.reply(line)}"
      end
      print "\n"
    end
  end

  private def self.parse_options : Nil
    OptionParser.parse! do |parser|
      parser.banner = "Usage: hailo [options]"
      parser.invalid_option do |opt|
        STDERR.puts "Unrecognized option: #{opt}"
        STDERR.puts parser
        exit 1
      end

      parser.on("-t FILE", "--train=FILE", "Train brain from text in FILE") do |file|
        @@train_file = file
      end
      parser.on("-b FILE", "--brain=FILE", "Brain file to load/save") do |file|
        @@brain_file = file
      end
      parser.on("-o NUMBER", "--order=NUMBER", "Markov order (default: 2)") do |number|
        @@order = number.to_i
      end
      parser.on("-v", "--version", "Print the version") do
        puts Hailo::VERSION
        exit
      end
      parser.on("-H", "--help", "Show this help message") { puts parser; exit }
      parser.on("-d", "--debug", "Print debugging info") do
        @@debug = true
      end
      parser.on("-s", "--server", "Run as a server") do
        @@run_server = true
      end
      parser.on("-h HOST", "--host=HOST", "Host/address for the server to listen on") do |bind|
        @@bind = bind
      end
      parser.on("-p PORT", "--port=PORT", "Port for the server to listen on") do |port|
        @@port = port.to_i32
      end
    end
  end
end
