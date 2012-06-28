module Game
  class Entity < PhysicsObject

    include LineOfSight

    attr_reader :health, :max_health

    def initialize(options = {})
      @max_health = @health = options[:health] || raise
      super(options)

    end

    def health=(value)
      return if @health == 0
      @health = [[value, 0].max, max_health].min
      destroy if @health <= 0
      @health
    end
  end
end