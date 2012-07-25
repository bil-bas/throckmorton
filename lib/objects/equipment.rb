module Game
  class Equipment < Chingu::BasicGameObject
    CONFIG_PATH = File.expand_path"../../../config/equipment.yml", __FILE__
    SHOOT_OFFSET = 14 # Pixels from center to create the projectile.

    class << self
      def config
        @config ||= begin
          config = YAML.load_file CONFIG_PATH
          # Convert to more friendly color objects.
          config.each_value do |c|
            c[:color] = Color.rgba *c[:color]
          end

          config
        end
      end
    end

    def energy_cost; @config[:cost][:energy] || 0 end

    def initialize(type, owner, options = {})
      @type = type
      @config = self.class.config[@type]
      raise "No such equipment as #{@type.inspect} in #{@config.keys}" unless @config
      @owner = owner

      super options
    end

    def can_fire?; @owner.energy >= energy_cost end
    def skirmish_range; @config[:skirmish_range] end

    def fire
      @owner.energy -= energy_cost if energy_cost > 0

      x, y, angle = @owner.x, @owner.y, @owner.angle

      options = {
          collision_type: @owner.is_a?(Player) ? :player_projectile : :enemy_projectile,
          group:          @owner.is_a?(Player) ? :player_projectiles : :enemy_projectiles,
      }.merge! @config

      num_projectiles = @config[:num_projectiles] || 1

      if num_projectiles == 1
        create_bullet x, y, angle, options
      else
        bullet_spacing = 360.0 / num_projectiles
        (0...360).step(bullet_spacing) do |i|
          create_bullet x, y, angle + i, options
        end
      end
    end

    def create_bullet(x, y, angle, options)
      bullet = Projectile.new @type,
                              x + offset_x(angle, SHOOT_OFFSET),
                              y + offset_y(angle, SHOOT_OFFSET),
                              angle,
                              options
      parent.add_object bullet
    end
  end
end