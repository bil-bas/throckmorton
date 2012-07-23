module Game
  module LineOfSight
    def line_of_sight?(target_tile)
      line_blocked_by(target_tile, :blocks_sight?).nil?
    end

    def line_of_attack?(target_tile)
      line_blocked_by(target_tile, :blocks_attack?).nil?
    end

    def line_of_sight_blocked_by(target_tile)
      line_blocked_by(target_tile, :blocks_sight?)
    end

    def line_of_attack_blocked_by(target_tile)
      line_blocked_by(target_tile, :blocks_attack?)
    end

    # Returns the tile that blocks sight, otherwise nil.
    # Implements 'Bresenham's line algorithm'
    # @return [Tile, Wall, nil]
    protected
    def line_blocked_by(target_tile, type)
      return false

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

        dx -= 1 if target_tile.blocks_movement? # Prevent view through diagonal "hole"

        # Blocked only if BOTH are blocked - return blockage from just one if both are blocked.
        blockage1 = zig_zag_blocked_by(tile, step_x, step_y, dx, true, type)
        blockage2 = zig_zag_blocked_by(tile, step_x, step_y, dx, false, type)
        if blockage1 && blockage2
          # Choose the blockage that is closest to us, since the other is irrelevant.
          [blockage1, blockage2].min_by do |blockage|
            manhattan_distance blockage
          end
        end
      else
        ray_trace_blocked_by tile, step_x, step_y, dx, dy, type
      end
    end

    protected
    def zig_zag_blocked_by(from, step_x, step_y, length, x_first, type)
      return nil

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
        return current if current.send type

        if x_first
          y += step_y
        else
          x += step_x
        end

        current = map.tile_at_grid(x, y)
        return current if current.send type
      end

      nil
    end

    protected
    def ray_trace_blocked_by(from, step_x, step_y, dx, dy, type)
      return nil

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
        return current if current.send type
      end

      nil
    end
  end
end
