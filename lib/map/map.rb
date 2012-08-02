module Game
  class Map < BasicGameObject
    include Mixins::Shaders

    MINI_SCALE = 1 / 4.0
    LIGHTING_SCALE = 1 # Number of lighting cells in a tile.
    NO_LIGHT_COLOR = Color.rgba(90, 90, 90, 255) # Colour outside range of lighting.

    attr_reader :width, :height, :player, :objects
    attr_reader :lighting, :seed, :scale

    LIGHTING_UPDATE_INTERVAL = 1 / 10.0

    def initialize(seed)
      @seed = seed

      super()

      @scale = 2.0

      @texture_width, @texture_height = 1022, 1022

      @width, @height = @texture_width * @scale, @texture_height * @scale

      @objects = []
      @player = nil

      if parent.client?
        @lighting = Ashton::Lighting::Manager.new width: $window.width.fdiv(parent.world_scale).ceil,
                                                  height: $window.height.fdiv(parent.world_scale).ceil,
                                                  z: ZOrder::LIGHT

        @outline_shader ||= Ashton::Shader.new fragment: :outline, uniforms: {
            outline_color: Gosu::Color::BLACK,
            outline_width: 0.5,
        }
      end
    end

    def generate
      create_map_pixel_texture

      @world_maker = WorldMaker.new @map_pixel_buffer, @shadow_casters, seed, @scale

      object_data = @world_maker.generate_object_data
      create_objects_from_data object_data

      @player = Player.new width / 2 + 150, height / 2

      #Messages::CreateMap.broadcast object_data
    end

    def create_map_pixel_texture
      t = Time.now

      @map_pixel_buffer = Ashton::Texture.new @texture_width, @texture_height

      map_shader = Ashton::Shader.new fragment: fragment_shader("map"), uniforms: {
          cavern_floor: Game::Textures::CavernFloor.color,
          cavern_wall: Game::Textures::CavernWall.color,
          #lava: Game::Textures::Lava.color,
          seed: seed,
          texture_size: [@map_pixel_buffer.width.to_f, @map_pixel_buffer.height.to_f],
          margin: 32,
      }
      @terrain_shader = Ashton::Shader.new fragment: fragment_shader("terrain"), uniforms: {
          texture_size: [@texture_width, @texture_height].map(&:to_f),
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
      @shadow_casters = Ashton::Texture.new @texture_width, @texture_height
      @shadow_casters.render do
        walls.draw 0, 0, 0
      end

      info { "Rendered map pixel texture at #{@texture_width}x#{@texture_height} in #{((Time.now - t).to_f * 1000).to_i}ms"}
    end

    def position_clear?(x, y, radius)
      @world_maker.position_clear? x, y, radius
    end

    def sample_distance(x, y)
      @world_maker.sample_distance x, y
    end

    def sample_normal(x, y)
      @world_maker.sample_normal x, y
    end

    def line_of_sight_blocked_at(x1, y1, x2, y2)
      @world_maker.line_of_sight_blocked_at x1, y1, x2, y2
    end

    def create_objects_from_data(data)
      t = Time.now
      data.each do |class_name, type, (x, y)|
        klass = Game.const_get class_name

        # Type will be a string if it has been serialized.
        add_object klass.new(type.to_sym, x, y)
      end

      info "Objects created in #{((Time.now - t).to_f * 1000).to_i}ms"
    end

    def draw_shadow_casters
      @shadow_casters.draw 0, 0, 0
    end

    def terrain_at_coordinate(x, y)
      color = @map_pixel_buffer[x / @scale, y / @scale]
      # TODO: convert to class?/name?
      color
    end

    def update
      @player.update
      @objects.each {|o| o.update }

      if parent.server?
        Messages::Sync.broadcast [@player] + @objects.reject {|o| o.needs_sync? }
      end
    end
    
    def draw
      @terrain_shader.time = milliseconds.fdiv 1000
      $window.scale @scale do
        @map_pixel_buffer.draw 0, 0, ZOrder::TILES, shader: @terrain_shader
        @world_maker.draw if $window.debugging?
      end

      @outline_shader.use do
        # TODO: AABB this?
        player_x, player_y = @player.x, @player.y
        @objects.each do |o|
          o.draw if Gosu::distance(player_x, player_y, o.x, o.y) < 350
        end

        @player.draw
      end

      #@lighting.each do |light|
      #  parent.pixel.draw light.x * world_scale, light.y * world_scale, ZOrder::LIGHT, 2, 2, Gosu::Color::WHITE, :add
      #end

      #$window.translate @camera_x / 2.0, @camera_y / 2.0 do
      #@map.lighting.draw
      #end

      draw_debug if $window.debugging?
    end

    def draw_debug
      @objects.each do |object|
        object.draw_physics
        object.draw_name
      end

      @player.draw_physics if @player
    end

    def draw_mini
      $window.scale @scale do
        @map_pixel_buffer.draw 0, 0, ZOrder::TILES
      end

      @objects.each {|o| o.draw_mini }
      @player.draw_mini
    end

    def add_object(object)
      @objects << object
    end

    def remove_object(object)
      @objects.delete object
    end
  end
end