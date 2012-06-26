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

      color = ([:white] * 20 + [:blue] * 10).sample

      case color
        when :white
          @blocks_movement = false
          @blocks_projectiles = false
          @blocks_sight = false

        when :blue
          @blocks_movement = true
          @blocks_projectiles = true
          @blocks_sight = true
      end

      image = TexPlay.create_image $window, WIDTH, WIDTH, color: color

      super x: grid_x * WIDTH, y: grid_y * WIDTH, zorder: ZOrder::TILES,
            image: image

      unless blocks_movement?
        parent.add_object Enemy.new(x, y) if rand(100) < 5
      end
    end

    def draw
      super if seen?
    end
  end
end