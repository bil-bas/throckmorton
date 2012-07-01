module Game
  class Projectile < PhysicsObject
    COLOR = Color.rgb(0, 255, 255)
    WIDTH = 5 # TODO: Need to make this more useful a value.

    attr_reader :damage, :type

    def short_name; "#{type}#{id_string}" end
    
    def initialize(type, x, y, direction, options = {})
      options = {
        rotation_speed: 0.0,
        speed: 100,
        rotation_center: :center_center,
        zorder: ZOrder::PROJECTILES,
        color: Color::CYAN,
        damage: 1,
      }.merge! options

      @type = type
      @speed = options[:speed]
      @damage = options[:damage]
      @duration = options[:duration]
      @rotation_speed = options[:rotation_speed]

      image = TexPlay.create_image $window, 3, 12, color: options[:color]

      super options.merge(x: x, y: y, image: image, angle: direction)

      if tile.blocks_attack?
        destroy # Prevent
      else
        info { "Created #{short_name} at #{tile.grid_position}" }
      end

      @created_at = time

      move offset_x(direction, 1), offset_y(direction, 1)
    end
    
    def update
      if time - @created_at > @duration
        destroy
      else
        self.angle += @rotation_speed
      end
    end

    def draw_mini    
      parent.pixel.draw_rot x, y, zorder, angle, 0.5, 0.5, 8, 8, COLOR
    end
  end
end