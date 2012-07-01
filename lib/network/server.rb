module Game
  class Server
    DEFAULT_PORT = 7500

    module Channel
      DATA, CHAT = *(0..100)
      COUNT = CHAT + 1 # Number of channels required.
    end

    MAX_PLAYERS = 4

    class PlayerClient
      attr_reader :id, :ip

      def initialize(id, ip)
        @id, @ip = id, ip
      end

      def to_s
        "Player #{id} (#{ip})"
      end
    end

    attr_reader :clients

    def initialize(port)
      @clients = {}

      @server = ENet::Server.new(port, MAX_PLAYERS, Channel::COUNT, 0, 0)

      @server.on_connection method(:connections_handler)
      @server.on_packet_receive method(:packets_handler)
      @server.on_disconnection method(:disconnections_handler)

      info { "Server listening on port #{port} (max #{@server.max_clients} players)" }
    end

    # Wrap this to get callbacks.
    def on_receive(id, packet, channel)
      raise NotImplementedError
    end

    def send_packet(id, packet, channel, options = {})
      options = {
          guaranteed: true,
      }.merge! options

      @server.send_packet id, packet, options[:guaranteed], channel
    end

    def broadcast_packet(packet, channel, options = {})
      options = {
          guaranteed: true,
      }.merge! options

      @server.broadcast_packet packet, options[:guaranteed], channel
    end

    def update
      @server.update 0
    end

    def flush
      @server.flush
    end

    def close
      @clients.each_value do |client|
        @server.disconnect_client client.id
      end
    end

    # handlers (used internally)

    def connections_handler(id, ip)
      @clients[id] = PlayerClient.new id, ip
      @server.broadcast_packet "#{@clients[id]} connected", true, Channel::CHAT

      info { "#{@clients[id]} connected" }
      info { "Players connected: #{@server.clients_count} of #{@server.max_clients}" }
    end

    def packets_handler(id, data, channel)
      info { "Packet from #{@clients[id]} on channel #{channel} -> #{data}" }

      on_receive id, data, channel
    end

    def disconnections_handler(id)
      info { "Player #{@clients[id]} disconnected!" }

      @server.broadcast_packet "#{@clients[id]} disconnected", true, Channel::CHAT
      @clients.delete id

      info { "Players connected: #{@server.clients_count} of #{@server.max_clients}" }
    end
  end
end