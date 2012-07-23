module Game
  class Enemy < Entity
    SPRITE_WIDTH = 32
    SHOOT_OFFSET = 14

    include Mixins::LightSource

    attr_reader :damage, :type
    def short_name; "#{type}#{id_string}" end

    class << self
      def config
        @config ||= YAML.load_file(File.expand_path("../../../config/enemies.yml", __FILE__))
      end
      def sprites
        @sprites ||= SpriteSheet["enemy.png", SPRITE_WIDTH, SPRITE_WIDTH, 8]
      end
    end


    def initialize(type, x, y, options = {})
      @type = type
      config = self.class.config[type]
      raise [@type, config].inspect unless config

      @ranged = config[:ranged]
      @damage = config[:melee][:damage] || raise
      @facing_x, @facing_y = 1, 0

      super x: x, y: y,
            width: config[:collision_width], height: config[:collision_width],
            max_health: config[:max_health], health: options[:health],
            zorder: ZOrder::ENEMY, illumination_range: config[:illumination_range],
            collision_type: :enemy, speed: config[:speed]

      if parent.client?
        sheet_position = config[:spritesheet_position]
        self.image = self.class.sprites[sheet_position[:x], sheet_position[:y]]
      end

      Messages::CreateEnemy.broadcast(self) if parent.server?

      debug { "Created #{short_name} at #{position}" }
    end

    def update
      reset_forces

      # Skirmish or advance
      range = distance(x, y, parent.player.x, parent.player.y)
      if @ranged and @ranged[:skirmish].include? range
        fire_ranged
      elsif @ranged and range < @ranged[:skirmish].min
        move_away_from parent.player
      else
        move_towards parent.player
      end

      self.angle = Gosu::angle(x, y, parent.player.x, parent.player.y)

      super
    end

    def fire_ranged
      if rand() <= @ranged[:fire_chance] && line_of_attack?(parent.player)
        angle = Gosu::angle(x, y, parent.player.x, parent.player.y)
        bullet = Projectile.new :arrow,
                                x + offset_x(angle, SHOOT_OFFSET),
                                y + offset_y(angle, SHOOT_OFFSET),
                                angle,
                                speed: @ranged[:speed],
                                collision_type: :enemy_projectile,
                                group: :enemy_projectiles,
                                damage: @ranged[:damage],
                                duration: @ranged[:duration],
                                color: Color::BLACK
        parent.add_object bullet
      end
    end

    def draw
      @image.draw_rot x, y, zorder, angle, 0.5, 0.5
    end

    def draw_mini
      parent.pixel.draw_rot x.round, y.round, zorder, 0, 0.5, 0.5, 20, 20, Color.rgb(255, 0, 0)
    end
  end
end