module Game
  module LineOfSight
    def manhattan_distance(tile)
      (tile.grid_x - self.tile.grid_x).abs + (tile.grid_y - self.tile.grid_y).abs
    end

    def line_of_sight?(target_tile)
      line_of_sight_blocked_by(target_tile).nil?
    end

    # Returns the tile that blocks sight, otherwise nil.
    # Implements 'Bresenham's line algorithm'
    # @return [Tile, Wall, nil]
    def line_of_sight_blocked_by(target_tile)
      raise unless target_tile.is_a? Tile

      # Check for the special case of looking diagonally.
      x1, y1 = tile.grid_x, tile.grid_y
      x2, y2 = target_tile.grid_x, target_tile.grid_y

      step_x = x1 < x2 ? 1 : -1
      step_y = y1 < y2 ? 1 : -1
      dx, dy = (x2 - x1).abs, (y2 - y1).abs

      if dx == dy
        # Special case of the diagonal line, which has to run either
        # .45      ..5
        # 23.  OR  .34
        # 1..      12.
        # Blocked only if BOTH are blocked - return blockage from just one if both are blocked.
        blockage1 = zig_zag_blocked_by(tile, step_x, step_y, dx - 1, true)
        blockage2 = zig_zag_blocked_by(tile, step_x, step_y, dx - 1, false)
        if blockage1 && blockage2
          # Choose the blockage that is closest to us, since the other is irrelevant.
          [blockage1, blockage2].min_by do |blockage|
            manhattan_distance blockage
          end
        elsif blockage1
          blockage1
        else
          blockage2
        end
      else
        ray_trace_blocked_by tile, step_x, step_y, dx, dy
      end
    end

    protected
    def zig_zag_blocked_by(from, step_x, step_y, length, x_first)
      current = from
      x, y = from.grid_x, from.grid_y
      map = parent.map

      length.times do
        if x_first
          x += step_x
        else
          y += step_y
        end

        current = map.tile_at_grid(x, y)
        return current if current.blocks_sight?

        if x_first
          y += step_y
        else
          x += step_x
        end

        current = map.tile_at_grid(x, y)
        return current if current.blocks_sight?
      end

      nil
    end

    protected
    def ray_trace_blocked_by(from, step_x, step_y, dx, dy)
      map = parent.map
      x, y = from.grid_x, from.grid_y

      # General case, ray-trace.
      error = dx - dy

      # Ensure that all tiles are visited that the sight-line passes over,
      # not just those that create a "drawn" line.
      dx *= 2
      dy *= 2

      length = ((dx + dy + 1) / 2)

      (length - 1).times do
        # Note that this ignores the special case of error == 0
        if error > 0
          error -= dy
          x += step_x
        else
          error += dx
          y += step_y
        end

        # Look at the next tile and see which wall is in the way.
        current = map.tile_at_grid(x, y)
        return current if current.blocks_sight?
      end

      nil
    end
  end
end