module Game
  class Enemy < Entity
    WIDTH = 17
    SHOOT_OFFSET = 14

    attr_reader :damage, :type
    def short_name; "#{type}#{id_string}" end

    class << self
      def config
          @config ||= YAML.load_file(File.expand_path("../../../config/enemies.yml", __FILE__))
      end
    end

    def initialize(type, x, y)
      @type = type
      config = self.class.config[type]
      raise [@type, config].inspect unless config

      @ranged = config[:ranged]
      @damage = config[:melee][:damage] || raise
      @facing_x, @facing_y = 1, 0

      unless defined? @@image
        @@image = TexPlay.create_image $window, WIDTH, WIDTH
        @@image.circle WIDTH / 2, WIDTH / 2, WIDTH / 2, color: :red, fill: true
        @@image.set_pixel WIDTH / 2 - 1, 1
        @@image.set_pixel WIDTH / 2 + 1, 1
      end

      super x: x, y: y, scale: config[:scale], health: config[:health],
            image: @@image, zorder: ZOrder::ENEMY,
            collision_type: :enemy, speed: config[:speed]

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
      if rand() <= @ranged[:fire_chance] && line_of_sight?(parent.player.tile)
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
        @image.draw_rot x, y, zorder, angle, 0.5, 0.5, scale, scale
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