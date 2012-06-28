module Game
  class << self
    def run(args)
      opts = Slop.parse args, help: true do
        banner "ruby bin#{File::SEPARATOR}game_of_scones [options]\n"

        on :server, 'Create dedicated server'
        on :port, 'UDP port to use', as: :int, default: 7500

        on :v, :version, 'Game version'
      end

      if opts.version?
        puts "Game version: #{VERSION}"

      elsif opts.server?
        raise NotImplementedError
        Server.new.start opts.port

      elsif !opts.help?
        Window.new.show
      end
    end
  end
end