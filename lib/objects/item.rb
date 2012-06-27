module Game
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

    def update
      #parent.map.lighting_overlay.set_pixel tile.grid_x, tile.grid_y, color: :alpha if tile.seen?

      super
    end
  end
end