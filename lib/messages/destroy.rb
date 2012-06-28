require_relative 'message'

module Game
  # Destroy any type of object.
  class Messages::Destroy < Messages::Message
    class << self
      def process(state, id)
        state.map.find_object(id).destroy
      end

      protected
      def create_data(enemy)
        [
            enemy.id
        ]
      end
    end
  end
end