module Game
  class Enemy < PhysicsObject
    DIAGONAL = 0.785
    WIDTH = 9

    def initialize(x, y)
      @speed = 50
      @facing_x, @facing_y = 1, 0

      image = TexPlay.create_image $window, WIDTH, WIDTH
      image.circle WIDTH / 2, WIDTH / 2, WIDTH / 2, color: :red, fill: true

      super x: x, y: y, rotation_center: :center_center,
            image: image, zorder: ZOrder::PLAYER,
            collision_type: :enemy
    end

    def update
      reset_forces
      push parent.player.x, parent.player.y, 5
      super
    end

    def draw_mini
      tile = self.tile
      if tile and tile.seen?
        parent.pixel.draw_rot x.round, y.round, zorder, 0, 0.5, 0.5, 14, 14, Color.rgb(255, 0, 0)
      end
    end
  end
end