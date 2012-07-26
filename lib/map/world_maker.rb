module Game
  class WorldMaker
    include Mixins::Shaders

    SPAWN_SPACING = 40 # This many pixels wide being the largest object that can spawn.
    SPAWN_MARGIN = SPAWN_SPACING / 2 # Space around spawn required to be clear.

    NAVIGATION_SPACING = 1
    MAX_NAVIGATION_DISTANCE = SPAWN_SPACING
    DISTANCE_MAP_SCALE = 1.0

    def initialize(map_texture, shadow_casters, seed)
      @map_texture = map_texture
      @rng = Random.new seed

      generate_navigation_nodes shadow_casters
    end

    def draw
      @recording ||= $window.record 1, 1 do
        @spawn_nodes.each do |x, y|
          $window.pixel.draw_rot x, y, 0, 0, 0.5, 0.5, 3, 3, Color::RED
        end
      end

      $window.scale DISTANCE_MAP_SCALE do
        @distance_map.draw 0, 0, 0, blend: :add
      end
      @recording.draw 0, 0, 0
    end

    def position_clear?(x, y, radius)
      # Could be checking any of red/blue/green.
      @distance_map.red(x / DISTANCE_MAP_SCALE, y / DISTANCE_MAP_SCALE) >= radius
    end

    # Nodes indicate the distance from themselves to a blockage. 0 if the node is in scenery.
    def generate_navigation_nodes(shadow_casters)
      t = Time.now

      shader = Ashton::Shader.new fragment: fragment_shader("distance_map"), uniforms: {
          step_size: NAVIGATION_SPACING,
          max_distance: MAX_NAVIGATION_DISTANCE,
          texture_size: [shadow_casters.width, shadow_casters.height].map(&:to_f),
      }

      @distance_map = Ashton::Framebuffer.new shadow_casters.width, shadow_casters.height
      shader.use do
        @distance_map.render do
          $window.scale 1.0 / DISTANCE_MAP_SCALE do
            shadow_casters.draw 0, 0, 0
          end
        end
      end

      info "Navigation nodes plotted out in #{((Time.now - t).to_f * 1000).to_i}ms"
    end

    # Spawn nodes are places where something could spawn.
    def generate_spawn_nodes
      @spawn_nodes = []

      (0...@map_texture.width).step(SPAWN_SPACING) do |x|
        (0...@map_texture.height).step(SPAWN_SPACING) do |y|
          @spawn_nodes << [x, y] if position_clear? x, y, SPAWN_MARGIN
        end
      end

      @spawn_nodes.shuffle! random: @rng
    end

    def generate_object_data
      generate_spawn_nodes

      positions = @spawn_nodes.dup

      objects = []

      enemy_types = Enemy.config.map {|k, v| [k] * v[:frequency] }.flatten.shuffle random: @rng

      enemy_types.size.times do
        objects << ["Enemy", enemy_types.pop, positions.pop]
      end

      item_types = Item.config.map {|k, v| [k] * v[:frequency] }.flatten.shuffle random: @rng
      item_types.size.times do
        objects << ["Item", item_types.pop, positions.pop]
      end

      objects
    end
  end
end