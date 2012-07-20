module Game
  class Map < BasicGameObject
    include Mixins::Shaders

    MINI_SCALE = 1 / 4.0
    LIGHTING_SCALE = 1 # Number of lighting cells in a tile.
    NO_LIGHT_COLOR = Color.rgba(90, 90, 90, 255) # Colour outside range of lighting.

    attr_reader :grid_width, :grid_height, :width, :height, :tiles
    attr_reader :lighting, :seed

    LIGHTING_UPDATE_INTERVAL = 1 / 10.0
    PIXELS_PER_TILE = 8

    def initialize(seed)
      @seed = seed

      super()

      if parent.client?
        @lighting = Ashton::Lighting::Manager.new width: $window.width.fdiv(parent.world_scale).ceil,
                                                  height: $window.height.fdiv(parent.world_scale).ceil,
                                                  z: ZOrder::LIGHT
      end
    end

    def generate
      maker = WorldMaker.new

      tile_data = maker.generate_tile_data 50, 50, seed # Largest, at 200x200, is 50, 50
      create_tiles_from_data tile_data

      object_data = maker.generate_object_data @tiles, seed
      create_objects_from_data object_data
      # TODO: send tile data to players.

      Messages::CreateMap.broadcast tile_data, object_data
    end

    # Create tiles from tile data (2d array of types - strings or )
    def create_tiles_from_data(data)
      t = Time.now

      @tiles_by_type = Hash.new {|h, k| h[k] = [] }
      @tiles = data.map.with_index do |row, y|
        row.map.with_index do |type, x|
          tile = Tile.new self, x, y, type.to_sym
          @tiles_by_type[type] << tile
          tile
        end
      end

      @grid_width, @grid_height = @tiles[0].size, @tiles.size
      @width, @height = grid_width * Tile::WIDTH, grid_height * Tile::WIDTH

      info "Creating map with #{grid_width}x#{grid_height} tiles"
      info "Tiles created in #{((Time.now - t).to_f * 1000).to_i}ms"

      render_tiles
    end

    def render_tiles
      t = Time.now

      create_map_pixel_texture

      info "Rendered tile map in #{((Time.now - t).to_f * 1000).to_i}ms"
    end

    def create_map_pixel_texture
      @map_pixel_buffer = Ashton::Framebuffer.new grid_width * PIXELS_PER_TILE, grid_height * PIXELS_PER_TILE

      @terrain_shader = Ashton::Shader.new fragment: fragment_shader("terrain"), uniforms: {
          cavern_floor: Textures::CavernFloor.color,
          cavern_wall: Textures::CavernWall.color,
          water: Textures::Water.color,
          lava: Textures::Lava.color,
          seed: seed,
      }

      @map_pixel_buffer.render do
        $window.scale PIXELS_PER_TILE do
          $window.pixel.draw 0, 0, 0, grid_width, grid_height, Textures::CavernFloor.color

          @tiles_by_type[:cavern_wall].each do |tile|
            $window.pixel.draw tile.grid_x, tile.grid_y, 0, 1, 1, Textures::CavernWall.color
          end

          @tiles_by_type[:rocks].each do |tile|
            # TODO: maybe make these into objects?
          end

          @tiles_by_type[:lava].each do |tile|
            $window.pixel.draw tile.grid_x, tile.grid_y, 0, 1, 1, Textures::Lava.color
          end

          @tiles_by_type[:water].each do |tile|
            $window.pixel.draw tile.grid_x, tile.grid_y, 0, 1, 1, Textures::Water.color
          end
        end
      end

      smooth_map

      # Just want the walls, as they are the only things that cast shadows.
      @shadow_casters = @map_pixel_buffer.to_image
      @shadow_casters.clear dest_ignore: Textures::CavernWall.color.to_opengl, tolerance: 0.02
      @shadow_casters.refresh_cache

      info { "Created map pixel texture at #{@map_pixel_buffer.width}x#{@map_pixel_buffer.height}"}
    end

    # TODO: why doesn't this do what we want it to?
    # Smooth out the square edges of the map by applying a shader as we draw it onto itself a couple of times.
    def smooth_map
      tmp = Ashton::Framebuffer.new grid_width * PIXELS_PER_TILE, grid_height * PIXELS_PER_TILE

      smooth_shader = Ashton::Shader.new fragment: fragment_shader("smooth")

      tmp.render do
        @map_pixel_buffer.draw 0, 0, 0, shader: smooth_shader
      end

      @map_pixel_buffer.render do
        tmp.draw 0, 0, 0, shader: smooth_shader
      end
    end

    def create_objects_from_data(data)
      t = Time.now
      data.each do |class_name, x, y, type|
        klass = Game.const_get class_name

        if type
          # Type will be a string if it has been serialized.
          parent.add_object klass.new(type.to_sym, x, y)
        else
          parent.add_object klass.new(x, y)
        end
      end
      info "Objects created in #{((Time.now - t).to_f * 1000).to_i}ms"
    end

    def draw_shadow_casters
      $window.scale Tile::WIDTH / PIXELS_PER_TILE do
        @shadow_casters.draw 0, 0, 0
      end
    end

    def tile_at_grid(x, y)
      return nil if x < 0 || y < 0
      @tiles[y][x] rescue nil
    end

    def tile_at_coordinate(x, y)
      return nil if x < 0 || y < 0
      @tiles[y.fdiv(Tile::WIDTH) + 0.5][x.fdiv(Tile::WIDTH) + 0.5]
    end
    
    def draw
      $window.scale Tile::WIDTH / PIXELS_PER_TILE do
        @terrain_shader.time = milliseconds.fdiv 1000
        @map_pixel_buffer.draw -PIXELS_PER_TILE / 2, -PIXELS_PER_TILE / 2, ZOrder::TILES, shader: @terrain_shader
      end
    end

    def draw_mini
      $window.scale Tile::WIDTH / PIXELS_PER_TILE do
        @map_pixel_buffer.draw -PIXELS_PER_TILE / 2, -PIXELS_PER_TILE / 2, ZOrder::TILES
      end
    end
  end
end