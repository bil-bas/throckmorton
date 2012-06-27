module Game
  class Tile < Chingu::GameObject
    WIDTH = 32

    attr_reader :map, :grid_x, :grid_y

    def seen?; @seen; end
    def blocks_movement?; @blocks_movement; end
    def blocks_sight?; @blocks_sight; end

    def seen=(value)
      map.reveal self if value && !@seen
      @seen = value
    end

    def initialize(map, grid_x, grid_y, type)
      @map, @grid_x, @grid_y = map, grid_x, grid_y

      @seen = false

      self.x, self.y = grid_x * WIDTH, grid_y * WIDTH

      case type
        when :white
          @blocks_movement = false
          @blocks_sight = false

          @body = @shape = nil

        when :blue
          @blocks_movement = true
          @blocks_sight = true

          @@body ||= CP::Body.new_static
          @@body.pos = CP::Vec2.new(0, 0)

          vertices = [CP::Vec2.new(x - WIDTH / 2, y - WIDTH / 2),
                      CP::Vec2.new(x - WIDTH / 2, y + WIDTH / 2),
                      CP::Vec2.new(x + WIDTH / 2, y + WIDTH / 2),
                      CP::Vec2.new(x + WIDTH / 2, y - WIDTH / 2)]
          @shape = CP::Shape::Poly.new(@@body, vertices, CP::Vec2.new(0, 0))
          @shape.collision_type = :wall
          @shape.group = 1
          @shape.object = self
      end

      @@images ||= {}
      @@images[type] ||= TexPlay.create_image $window, WIDTH, WIDTH, color: type

      super x: x, y: y, zorder: ZOrder::TILES, image: @@images[type]

      parent.space.add_shape @shape if @shape


      unless blocks_movement? && distance(x, y, *map.start_position) > 20
        case rand(100)
          when 0..12
            parent.add_object Enemy.new(x, y)
          when 15..17
            parent.add_object HealthPack.new(x, y)
          when 18
            parent.add_object EnergyPack.new(x, y)
          when 20..26
            parent.add_object Treasure.new(x, y)
        end
      end
    end

    def to_s
      "#{self.class} (#{@grid_x}, #{@grid_y}) #{blocks_movement? ? "" : "no move"}"
    end
  end
end