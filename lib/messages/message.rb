module Game
  class Messages::Message
    GUARANTEED = true

    class << self
      attr_accessor :identifier

      def name; self.class.name[/\w+$/] end

      # Process incoming data.
      def process(state, *data)
        raise NotImplementedError
      end

      def send(*data)
        # TODO: Send data across network!
        packet = [identifier, create_data(*data)].to_msgpack
        #debug { [packet.length, packet] }
      end

      protected
      # Save data to send (implement on sub-classes)
      def create_data(*data)
        raise NotImplementedError
      end
    end
  end
end
