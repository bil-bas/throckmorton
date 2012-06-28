require_relative "../teststrap"

describe "Server" do
  describe "run" do
    before :all do
      # TODO: Create a new server each time, when we can close one properly :(
      @server = Game::Server.new 50000
      @enet_server = @server.instance_variable_get :@server
    end

    after :each do
      @server.close
    end

    describe "clients" do
      it "should initially be empty" do
        @server.clients.should eq Hash.new
      end
    end

    describe "update" do
      it "should update the server with no timeout" do
        mock(@enet_server).update 0
        @server.update
      end
    end

    describe "flush" do
      it "should flush to enet" do
        mock(@enet_server).flush
        @server.flush
      end
    end

    describe "close" do
      it "should close all open connections" do
        @server.connections_handler 0, "1.2.3.4"
        @server.connections_handler 1, "4.5.6.7"

        mock(@enet_server).broadcast_packet "Player 0 (1.2.3.4) disconnected", true, 1
        mock(@enet_server).broadcast_packet "Player 1 (4.5.6.7) disconnected", true, 1

        @server.close
        @server.clients.should be_empty
      end

      it "should close the server itself" do
        pending "implementation of ENet::Server#close"
      end
    end

    describe "connections_handler" do
      it "should accept a new client" do
        @server.connections_handler 1, "1.2.3.4"

        @server.clients.keys.first.should eq 1
        client = @server.clients.values.first
        client.should be_kind_of Game::Server::PlayerClient
        client.id.should eq 1
        client.ip.should eq "1.2.3.4"
      end

      it "should inform already connected players when a client connects" do
        mock(@enet_server).broadcast_packet "Player 2 (4.5.6.7) connected", true, 1

        @server.connections_handler 2, "4.5.6.7"
      end
    end

    describe "send_packet" do
      it "should send via enet (defaulting to reliably)" do
        mock(@enet_server).send_packet 1, "fred", true, 0

        @server.send_packet 1, "fred", 0
      end

      it "should send via enet unreliably" do
        mock(@enet_server).send_packet 1, "fred", false, 0

        @server.send_packet 1, "fred", 0, guaranteed: false
      end
    end

    describe "broadcast_packet" do
      it "should broadcast via enet (defaulting to reliably)" do
        mock(@enet_server).broadcast_packet "fred", true, 0

        @server.broadcast_packet "fred", 0
      end

      it "should broadcast via enet unreliably" do
        mock(@enet_server).broadcast_packet "fred", false, 0

        @server.broadcast_packet "fred", 0, guaranteed: false
      end
    end

    describe "packets_handler" do
      it "should accept a packet and pass it to the on_receive handler" do
        @server.connections_handler 1, "1.2.3.4"
        mock(@server).on_receive 1, "bleh", 0

        @server.packets_handler 1, "bleh", 0
      end
    end

    describe "disconnections_handler" do
      it "should tell all players about the disconnection" do
        @server.connections_handler 1, "1.2.3.4"

        mock(@enet_server).broadcast_packet "Player 1 (1.2.3.4) disconnected", true, 1

        @server.disconnections_handler 1
      end
    end
  end
end