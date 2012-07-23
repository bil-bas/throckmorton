require_relative "../teststrap"

describe "Game" do
  describe "run" do
    it "should display help text" do
      TEXT =<<END
ruby bin#{File::SEPARATOR}throckmorton [options]

        --server       Create dedicated server
        --port         UDP port to use (default: 7500)
    -v, --version      Game version
    -h, --help         Display this help message.
END

      mock($stderr).puts TEXT.strip

      Game.run %w{--help}
    end

    it "should start up as a client" do
      mock(Game::Window).new.mock!.show
      Game.run []
    end

    it "should start up as server with default port" do
      mock(Game::Server).new 7500
      Game.run %w{--server}
    end

    it "should start up as server with specified port" do
      mock(Game::Server).new 99
      Game.run %w{--server --port=99}
    end
  end
end