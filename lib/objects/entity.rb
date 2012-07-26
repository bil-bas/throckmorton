module Game
  class Entity < PhysicsObject
    attr_reader :health, :max_health

    def initialize(options = {})
      @max_health = options[:max_health]
      @health = options[:health] || options[:max_health] || raise
      super(options)
    end

    def line_of_sight_blocked_at(other)
      parent.map.line_of_sight_blocked_at x, y, other.x, other.y
    end

    def health=(value)
      return if @health == 0
      @health = [[value, 0].max, max_health].min
      Messages::Set.broadcast(self, :health, @health) if parent.server?
      if @health <= 0
        Sample["enemy_killed.ogg"].play 0.8
        destroy
      end
      @health
    end
  end
end