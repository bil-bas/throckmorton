module Game
  class Tile < Chingu::GameObject
    WIDTH = 32

    attr_reader :map, :grid_x, :grid_y, :type

    def seen?; @seen end
    def blocks_movement?; @blocks_movement end
    def blocks_sight?; @blocks_sight end
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
        when :wall
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

          @body = @shape = nil

          color = Color.rgb 110, 100, 100

        when :water
          @blocks_movement = false
          @blocks_sight = false

          color = Color.rgb 0, 50, 100

        when :wall
          @blocks_movement = true
          @blocks_sight = true

          color = Color.rgb 60, 30, 10

        when :rocks
          @blocks_movement = true
          @blocks_sight = false

          color = Color.rgb 110, 100, 100
      end

      @@images ||= {}
      unless @@images.has_key? @type
        @@images[@type] = TexPlay.create_image $window, WIDTH, WIDTH, color: color
        @@images[@type].clear color_control: lambda {|c|
          c[0..2].map {|c| c + rand(-5..5) * 0.003 }
        }

        if @type == :rocks
          30.times do
            rock_x, rock_y, radius = rand(4..28), rand(4..28), rand(3..5)
            #@shape = CP::Shape::Circle.new(@@body, radius,
            #                               CP::Vec2.new(x - WIDTH / 2 + rock_x,
            #                                            y - WIDTH / 2 + rock_y))
            @@images[@type].circle rock_x, rock_y, radius, color: Color.rgb(rand(80..120), rand(30..50), 10), fill: true
          end
        end
      end

      super x: x, y: y, zorder: ZOrder::TILES, image: @@images[@type], angle: [0, 90, 180, 270].sample

      if @shape
        @shape.group = 1
        @shape.object = self

        case @type
          when :wall
            @shape.collision_type = :wall
          when :rocks
            @shape.collision_type = :obstacle
        end

        parent.space.add_shape @shape
      end
    end

    def to_s
      "#{self.class} (#{@grid_x}, #{@grid_y}) #{blocks_movement? ? "" : "no move"}"
    end
  end
end