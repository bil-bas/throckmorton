module Game
  class Tile < Chingu::GameObject
    WIDTH = 32
    SCALE = 0.5 # Textures are 16x16, but blown up to 32x32 (compared to the non-terrain objects)

    include Mixins::LightSource

    attr_reader :map, :grid_x, :grid_y, :type

    def seen?; @seen end
    def blocks_movement?; @blocks_movement end
    def blocks_sight?; @blocks_sight end
    def blocks_attack?; @blocks_attack end
    def grid_position; [@grid_x, @grid_y] end
    def spawn_object?; @type == :floor end

    def seen=(value)
      map.reveal self if value && !@seen
      @seen = value
    end

    def initialize(map, grid_x, grid_y, type)
      @map, @grid_x, @grid_y, @type = map, grid_x, grid_y, type

      @seen = false

      self.x, self.y = grid_x * WIDTH, grid_y * WIDTH

      @@body ||= CP::Body.new_static
      @@body.pos = CP::Vec2.new(0, 0)

      case @type
        when :wall, :lava, :water
          vertices = [CP::Vec2.new(-WIDTH / 2, -WIDTH / 2),
                      CP::Vec2.new(-WIDTH / 2, +WIDTH / 2),
                      CP::Vec2.new(+WIDTH / 2, +WIDTH / 2),
                      CP::Vec2.new(+WIDTH / 2, -WIDTH / 2)]
          @shape = CP::Shape::Poly.new(@@body, vertices, CP::Vec2.new(x, y))

        when :rocks
          @shape = CP::Shape::Circle.new(@@body, 15, CP::Vec2.new(x, y))
      end

      case @type
        when :floor
          @blocks_movement = false
          @blocks_sight = false
          @blocks_attack = false

          @body = @shape = nil

        when :water
          @blocks_movement = false
          @blocks_sight = false
          @blocks_attack = false

        when :lava
          @blocks_movement = false
          @blocks_sight = false
          @blocks_attack = false

        when :wall
          @blocks_movement = true
          @blocks_sight = true
          @blocks_attack = true

        when :rocks
          @blocks_movement = true
          @blocks_sight = false
          @blocks_attack = true
        else
          raise @type.inspect
      end

      if @type == :rocks
        image = TexPlay.create_image $window, 16, 16, clear: :alpha
        20.times do
          rock_x, rock_y, radius = rand(4..28), rand(4..28), rand(2..4)
          #@shape = CP::Shape::Circle.new(@@body, radius,
          #                               CP::Vec2.new(x - WIDTH / 2 + rock_x,
          #                                            y - WIDTH / 2 + rock_y))
          image.circle rock_x, rock_y, radius, fill: true,
                       color: Color.rgb(rand(80..120), rand(30..50), 10)
        end
      else
        self.width = self.height = WIDTH
        image = nil
      end

      super x: x, y: y, zorder: ZOrder::TILES, image: image

      if @shape
        @shape.group = 1
        @shape.object = self

        case @type
          when :wall
            @shape.collision_type = :wall
          when :rocks
            @shape.collision_type = :obstacle
          when :lava
            @shape.collision_type = :lava
          when :water
            @shape.collision_type = :water
        end

        parent.space.add_shape @shape
      end
    end

    def self.floor_layer; @@floor_layer; end
    def self.static_layer; @@static_layer; end

    def draw
      image.draw x * SCALE, y * SCALE, zorder if image
    end

    def to_s
      "#{self.class} (#{@grid_x}, #{@grid_y})#{blocks_movement? ? "" : " no move"}"
    end
  end
end