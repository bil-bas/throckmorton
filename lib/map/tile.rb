module Game
  class Tile < Chingu::GameObject
    WIDTH = 16

    def seen?; @seen; end
    def blocks_movement?; @blocks_movement; end
    def blocks_projectiles?; @blocks_projectiles; end
    def blocks_sight?; @blocks_sight; end

    def initialize(grid_x, grid_y)
      @grid_x, @grid_y = grid_x, grid_y

      @seen = true

      self.x, self.y = grid_x * WIDTH, grid_y * WIDTH

      color = ([:white] * 20 + [:blue] * 10).sample

      case color
        when :white
          @blocks_movement = false
          @blocks_projectiles = false
          @blocks_sight = false

          @body = @shape = nil

        when :blue
          @blocks_movement = true
          @blocks_projectiles = true
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

      image = TexPlay.create_image $window, WIDTH, WIDTH, color: color

      super x: x, y: y, zorder: ZOrder::TILES, image: image

      parent.space.add_shape @shape if @shape

      unless blocks_movement?
        parent.add_object Enemy.new(x, y) if rand(100) < 5
      end
    end

    def draw
      super if seen?
    end
  end
end