require_relative "teststrap"

describe "Game" do
  describe "run" do
    it "should display help text" do

      TEXT =<<END
ruby bin#{File::SEPARATOR}game_of_scones [options]

        --server       Create dedicated server
        --port         UDP port to use
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
      pending "server implementation"
      mock(Game::Server).new.mock!.listen 7500
      Game.run %w{--server}
    end

    it "should start up as server with specified port" do
      pending "server implementation"

      mock(Game::Server).new.mock!.listen 99
      Game.run ["--server", "--port 99"]
    end
  end
end