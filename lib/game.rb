module Game
  class << self

    # Entrypoint from the CLI. Starts up a client or server for you.
    def run(args)
      opts = Slop.parse args, help: true do
        banner "ruby bin#{File::SEPARATOR}throckmorton [options]\n"

        on :f, :fullscreen, "Run at full-screen resolution: #{screen_width}x#{screen_height}"


        on :a, :address=, "Server address to connect to (default: localhost)"
        on :p, :port=,    "UDP port to use (default: #{Server::DEFAULT_PORT})", as: :int, default: Server::DEFAULT_PORT
        on :s, :server,   "Create dedicated server"

        on :d, :debug,    "Run in debug mode" # This is handled elsewhere!

        on :v, :version,  "Game version"
      end

      if opts.debug?
        puts "DEBUG MODE ENABLED!"
        Bundler.require :debug
      end

      if opts.version?
        puts "Game version: #{VERSION}"

      elsif opts.server?
        Server.new opts[:port].to_i

      elsif !opts.help?
        Window.new(opts.fullscreen?, opts.debug?).show
      end
    end
  end
end