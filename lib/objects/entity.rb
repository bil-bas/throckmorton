module Game
  class Entity < PhysicsObject

    include LineOfSight

    attr_reader :health, :max_health

    def initialize(options = {})
      @max_health = options[:max_health]
      @health = options[:health] || options[:max_health] || raise
      super(options)

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