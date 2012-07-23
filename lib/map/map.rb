module Game
  class Map < BasicGameObject
    include Mixins::Shaders

    MINI_SCALE = 1 / 2.0
    LIGHTING_SCALE = 1 # Number of lighting cells in a tile.
    NO_LIGHT_COLOR = Color.rgba(90, 90, 90, 255) # Colour outside range of lighting.

    attr_reader :width, :height
    attr_reader :lighting, :seed

    LIGHTING_UPDATE_INTERVAL = 1 / 10.0

    def initialize(seed)
      @seed = seed

      super()

      @width, @height = 1022, 1022

      if parent.client?
        @lighting = Ashton::Lighting::Manager.new width: $window.width.fdiv(parent.world_scale).ceil,
                                                  height: $window.height.fdiv(parent.world_scale).ceil,
                                                  z: ZOrder::LIGHT
      end
    end

    def generate
      create_map_pixel_texture

      @world_maker = WorldMaker.new @map_pixel_buffer, seed

      object_data = @world_maker.generate_object_data
      create_objects_from_data object_data

      #Messages::CreateMap.broadcast object_data
    end

    def create_map_pixel_texture
      t = Time.now

      @map_pixel_buffer = Ashton::Framebuffer.new width, height

      map_shader = Ashton::Shader.new fragment: fragment_shader("map"), uniforms: {
          cavern_floor: Game::Textures::CavernFloor.color,
          cavern_wall: Game::Textures::CavernWall.color,
          #lava: Game::Textures::Lava.color,
          seed: seed,
          texture_size: [width.to_f, height.to_f],
          margin: 32,
      }
      @terrain_shader = Ashton::Shader.new fragment: fragment_shader("terrain"), uniforms: {
          cavern_floor: Textures::CavernFloor.color,
          cavern_wall: Textures::CavernWall.color,
          lava: Textures::Lava.color,
          seed: seed,
      }

      map_shader.use do
        @map_pixel_buffer.render do
          @map_pixel_buffer.draw 0, 0, 0
        end
      end

      # Just want the walls, as they are the only things that cast shadows.
      walls = @map_pixel_buffer.to_image
      walls.clear dest_ignore: Textures::CavernWall.color.to_opengl, tolerance: 0.02
      walls.refresh_cache
      @shadow_casters = Ashton::Framebuffer.new width, height
      @shadow_casters.render do
        walls.draw 0, 0, 0
      end

      info { "Rendered map pixel texture at #{@map_pixel_buffer.width}x#{@map_pixel_buffer.height} in #{((Time.now - t).to_f * 1000).to_i}ms"}
    end

    def create_objects_from_data(data)
      t = Time.now
      data.each do |class_name, type, (x, y)|
        klass = Game.const_get class_name

        # Type will be a string if it has been serialized.
        parent.add_object klass.new(type.to_sym, x, y)
      end

      info "Objects created in #{((Time.now - t).to_f * 1000).to_i}ms"
    end

    def draw_shadow_casters
      @shadow_casters.draw 0, 0, 0
    end

    def clear_at?(x, y)
      @shadow_casters.transparent? x, y
    end

    def blocked_at?(x, y)
      !@shadow_casters.transparent?(x, y)
    end

    def terrain_at_coordinate(x, y)
      color = @map_pixel_buffer[x, y]
      # TODO: convert to class?/name?
      color
    end
    
    def draw
      @terrain_shader.time = milliseconds.fdiv 1000
      @map_pixel_buffer.draw 0, 0, ZOrder::TILES, shader: @terrain_shader
      @world_maker.draw if $window.debugging?
    end

    def draw_mini
      @map_pixel_buffer.draw 0, 0, ZOrder::TILES
    end
  end
end