require_relative 'message'

module Game
  class Messages::CreateMap < Messages::Message
    class << self
      def process(state, tile_data, object_data)
         state.map.create_tiles_from_data tile_data
         state.map.create_objects_from_data object_data
      end

      protected
      def create_data(tile_data, object_data)
        [tile_data, object_data]
      end
    end
  end
end