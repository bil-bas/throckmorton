module Game
  class << self

    # Entrypoint from the CLI. Starts up a client or server for you.
    def run(args)
      opts = Slop.parse args, help: true do
        banner "ruby bin#{File::SEPARATOR}game_of_scones [options]\n"

        on :server, 'Create dedicated server'
        on :port=, "UDP port to use (default: #{Server::DEFAULT_PORT})", as: :int, default: Server::DEFAULT_PORT

        on :v, :version, 'Game version'
      end

      if opts.version?
        puts "Game version: #{VERSION}"

      elsif opts.server?
        Server.new opts[:port].to_i

      elsif !opts.help?
        Window.new.show
      end
    end
  end
end