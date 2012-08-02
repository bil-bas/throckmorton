require_relative 'message'

module Game
  class Messages::CreateItem < Messages::Message
    class << self
      def process(state, type, x, y)
        state.map.add_object Game.const_get(type).new(x, y)
      end

      protected
      def create_data(item)
        [
            item.class.name[/\w+$/],
            item.x,
            item.y,
            id: item.id,
        ]
      end
    end
  end
end