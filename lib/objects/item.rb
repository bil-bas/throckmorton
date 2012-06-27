module Game
  # Items are picked up by the player.
  class Item < PhysicsObject
    def initialize(options)
      options = {
          zorder: ZOrder::ITEM,
          collision_type: :item,
      }.merge! options

      super options

      @shape.sensor = true
    end

    def draw
      tile = self.tile
      if tile and tile.seen?
        @image.draw_rot x, y, zorder, angle, 0.5, 0.5
      end
    end
  end
end