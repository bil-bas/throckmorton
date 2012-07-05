module Game
  class Enemy < Entity
    SPRITE_WIDTH = 16
    SHOOT_OFFSET = 14

    attr_reader :damage, :type
    def short_name; "#{type}#{id_string}" end

    class << self
      def config
        @config ||= YAML.load_file(File.expand_path("../../../config/enemies.yml", __FILE__))
      end
      def sprites
        @sprites ||= SpriteSheet["enemy.png", SPRITE_WIDTH, SPRITE_WIDTH, 8].map do |sprite|
          sprite.thin_outlined
        end
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
        position = config[:spritesheet_position]
        self.image = self.class.sprites[position[:x], position[:y]]
      end

      Messages::CreateEnemy.broadcast(self) if parent.server?

      info { "Created #{short_name} at #{tile.grid_position}" }
    end

    def update
      reset_forces

      # Skirmish or advance
      range = distance(x, y, parent.player.x, parent.player.y)
      if @ranged and @ranged[:skirmish].include? range
        fire_ranged
      elsif @ranged and range < @ranged[:skirmish].min
        push -parent.player.x, -parent.player.y, speed
      else
        push parent.player.x, parent.player.y, speed
      end

      self.angle = Gosu::angle(x, y, parent.player.x, parent.player.y)



      super
    end

    def fire_ranged
      if rand() <= @ranged[:fire_chance] && line_of_attack?(parent.player.tile)
        angle = Gosu::angle(x, y, parent.player.x, parent.player.y)
        bullet = Projectile.new :arrow,
                                x + offset_x(angle, SHOOT_OFFSET),
                                y + offset_y(angle, SHOOT_OFFSET),
                                angle,
                                speed: @ranged[:speed],
                                collision_type: :enemy_projectile,
                                group: :enemy_projectiles,
                                duration: @ranged[:duration],
                                color: Color::BLACK
        parent.add_object bullet
      end
    end

    def draw
      tile = self.tile
      if tile && tile.seen? && parent.player.can_see?(tile)
        @image.draw_rot x, y, zorder, angle, 0.5, 0.5
      end
    end

    def draw_mini
      tile = self.tile
      if tile && tile.seen?
        parent.pixel.draw_rot x.round, y.round, zorder, 0, 0.5, 0.5, 10 * scale, 10 * scale, Color.rgb(255, 0, 0)
      end
    end
  end
end