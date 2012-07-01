module Game
  # Items are picked up by the player.
  class Item < PhysicsObject
    def short_name; "#{self.class}#{id_string}" end
    def needs_sync?; false end

    def initialize(options)
      options = {
          zorder: ZOrder::ITEM,
          collision_type: :item,
      }.merge! options

      super options

      @shape.sensor = true

      Messages::CreateItem.broadcast(self) if parent.server?

      info { "Created #{short_name} at #{tile.grid_position}" }
    end

    def draw
      tile = self.tile
      if tile && tile.seen?
        @image.draw_rot x, y, zorder, angle, 0.5, 0.5
      end
    end
  end
end