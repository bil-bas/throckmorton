module Game
  class Enemy < PhysicsObject
    DIAGONAL = 0.785

    def initialize(x, y)
      @speed = 75
      @facing_x, @facing_y = 1, 0

      image = TexPlay.create_image $window, 8, 8, color: :red

      super x: x, y: y, rotation_center: :center_center,
            image: image, zorder: ZOrder::PLAYER,
            collision_type: :enemy
    end

    def draw
      @image.draw_rot x, y, zorder, 0, 0.5, 0.5
    end

    def draw_mini
      parent.pixel.draw_rot x.round, y.round, zorder, 0, 0.5, 0.5, 14, 14, Color.rgb(255, 0, 0)
    end
  end
end