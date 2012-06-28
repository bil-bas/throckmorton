require_relative 'message'

module Game
  class Messages::CreateItem < Messages::Message
    class << self
      def process(state, type, x, y, options = {})
        state.add_object Item.const_get(type).new(x, y, options)
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