module Game
  class Treasure < Item
    WIDTH = 14
    SCORE_VALUES = [100, 500, 1000]

    def initialize(x, y)
      size = [0, 1, 2].sample
      @value = SCORE_VALUES[size]
      image = Item.sprites[0, size]

      super x: x, y: y, image: image, width: WIDTH
    end

    def activated_by(player)
      player.score += @value
      Sample["coins.ogg"].play 0.3
      self.destroy
    end

    def draw_mini
      tile = self.tile
      if tile && tile.seen?
        parent.pixel.draw_rot x.round, y.round, zorder, 0, 0.5, 0.5, 14, 14, Color.rgb(255, 255, 0)
      end
    end
  end
end