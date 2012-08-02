require_relative 'message'

module Game
  class Messages::CreateEnemy < Messages::Message
    class << self
      def process(state, type, x, y)
        state.map.add_object Enemy.new(type, x, y)
      end

      protected
      def create_data(enemy)
        [
            enemy.type,
            enemy.x,
            enemy.y,
            id: enemy.id,
            health: enemy.health,
        ]
      end
    end
  end
end