module Game
  class MedicKit < PhysicsObject
    WIDTH = 9
    HEAL_VALUE = 25

    def initialize(x, y)
      image = TexPlay.create_image $window, WIDTH, WIDTH, color: :green

      super x: x, y: y,
            image: image, zorder: ZOrder::ITEM,
            collision_type: :item

      @shape.sensor = true
    end

    def activated_by(player)
      unless player.health == player.max_health
        player.health += HEAL_VALUE
        self.destroy
      end
    end

    def draw_mini
      tile = self.tile
      if tile and tile.seen?
        parent.pixel.draw_rot x.round, y.round, zorder, 0, 0.5, 0.5, 14, 14, Color.rgb(0, 255, 0)
      end
    end
  end
end