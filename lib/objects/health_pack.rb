module Game
  class HealthPack < Item
    WIDTH = 12
    HEAL_VALUE = 25

    def initialize(x, y)
      image = Item.sprites[1, 0]
      super x: x, y: y, image: image, width: WIDTH
    end

    def activated_by(player)
      unless player.health == player.max_health
        player.health += HEAL_VALUE
        Sample["chewing.ogg"].play 0.7
        self.destroy
      end
    end

    def draw_mini
      parent.pixel.draw_rot x.round, y.round, zorder, 0, 0.5, 0.5, 14, 14, Color.rgb(0, 255, 0)
    end
  end
end