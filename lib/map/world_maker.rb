module Game
  class WorldMaker
    MARGIN = 4

    # Generate a new map (2d array of tile types).
    def generate_tile_data(width, height, seed)
      gen = Perlin::Generator.new seed, 1, 1
      noise = gen.chunk 0, 0, width, height, 0.4

      # Start off with an empty map.
      tiles = Array.new(width) { Array.new(height) }

      height.times do |y|
        width.times do |x|
          tile = if x < MARGIN || y < MARGIN ||
              x >= width - MARGIN || y >= height - MARGIN
            :cavern_wall
          else
            n = noise[y][x]
            close_to_player = distance(x, y, width / 2, height / 2) < 5

            if n < -0.5
              :water
            elsif n > 0.85 && !close_to_player
               :lava
            elsif n > -0.2 && n < 0.2 && !close_to_player
              :cavern_wall
            else
              :cavern_floor
            end
          end

          tiles[y][x] = tile if tile
        end
      end

      tiles
    end

    def start_position(tiles)
      [tiles.size / 2, tiles[0].size / 2]
    end

    def generate_object_data(tiles, seed)
      player_position = start_position tiles

      # TODO: Use seed to place objects.

      valid_tiles = tiles.flatten.select {|t| t.spawn_object? && distance(t.x, t.y, *player_position) > 20 }
      valid_tiles.map.with_object([]) do |tile, data|
        case rand(100)
          when 0..8
            @@possibilities ||= Enemy.config.map {|k, v| [k] * v[:frequency] }.flatten
            data << [Enemy.name[/[^:]+$/], tile.x, tile.y, @@possibilities.sample]

          when 15..16
            data << [HealthPack.name[/[^:]+$/], tile.x, tile.y]
          when 18
            data <<[EnergyPack.name[/[^:]+$/], tile.x, tile.y]
          when 20..24
            data <<[Treasure.name[/[^:]+$/], tile.x, tile.y]
        end
      end
    end
  end
end