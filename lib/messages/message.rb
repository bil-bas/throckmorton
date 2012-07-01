module Game
  class Messages::Message
    GUARANTEED = true

    class << self
      attr_accessor :identifier, :parent

      # Process incoming data.
      def process(state, *data)
        raise NotImplementedError
      end

      def post(player_id, *data)
        # TODO: Send data across network!
        #@network.send_message player_id, packet(*data)
        create_data(*data) # Just throw it away!
        #process parent, *create_data(*data)
      end

      def broadcast(*data)
        # TODO: Send data across network!
        #@network.broadcast packet(*data)
        post 0, *data
      end

      def packet(*data)
        [identifier, create_data(*data)].to_msgpack
      end

      protected
      # Save data to send (implement on sub-classes)
      def create_data(*data)
        raise NotImplementedError
      end
    end
  end
end
