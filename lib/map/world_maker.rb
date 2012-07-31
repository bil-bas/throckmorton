module Game
  class WorldMaker
    include Mixins::Shaders

    SPAWN_SPACING = 40 # This many pixels wide being the largest object that can spawn.
    SPAWN_MARGIN = SPAWN_SPACING / 2 # Space around spawn required to be clear.

    NAVIGATION_SPACING = 1
    MAX_NAVIGATION_DISTANCE = SPAWN_SPACING
    DISTANCE_FIELD_SCALE = 1.0

    def initialize(map_texture, shadow_casters, seed, scale)
      @map_texture, @scale = map_texture, scale
      @rng = Random.new seed

      generate_navigation_nodes shadow_casters
    end

    def draw
      @recording ||= $window.record 1, 1 do
        @spawn_nodes.each do |x, y|
          $window.pixel.draw_rot x, y, 0, 0, 0.5, 0.5, 1, 1, Color::RED
        end
      end

      @signed_distance_field.draw 0, 0, 0
      @recording.draw 0, 0, 0, 0.5, 0.5
    end

    def position_clear?(x, y, radius)
      @signed_distance_field.position_clear? x / @scale, y / @scale, radius / @scale
    end

    def sample_distance(x, y)
      distance = @signed_distance_field.sample_distance x / @scale, y / @scale
      distance * @scale
    end

    def sample_normal(x, y)
      @signed_distance_field.sample_normal x / @scale, y / @scale
    end

    def line_of_sight_blocked_at(x1, y1, x2, y2)
      pos = @signed_distance_field.line_of_sight_blocked_at x1 / @scale, y1 / @scale, x2 / @scale, y2 / @scale
      if pos
        [pos[0] * @scale, pos[1] * @scale]
      else
        nil
      end
    end

    # Nodes indicate the distance from themselves to a blockage. 0 if the node is in scenery.
    def generate_navigation_nodes(shadow_casters)
      t = Time.now

      @signed_distance_field = Ashton::SignedDistanceField.new shadow_casters.width,
                                                               shadow_casters.height,
                                                               MAX_NAVIGATION_DISTANCE,
                                                               scale: DISTANCE_FIELD_SCALE do
        shadow_casters.draw 0, 0, 0
      end

      info "Navigation nodes plotted out in #{((Time.now - t).to_f * 1000).to_i}ms"
    end

    # Spawn nodes are places where something could spawn.
    def generate_spawn_nodes
      @spawn_nodes = []

      (0...(@map_texture.width * @scale)).step(SPAWN_SPACING) do |x|
        (0...(@map_texture.height * @scale)).step(SPAWN_SPACING) do |y|
          @spawn_nodes << [x, y] if position_clear? x, y, SPAWN_MARGIN
        end
      end

      @spawn_nodes.shuffle! random: @rng
    end

    def generate_object_data
      generate_spawn_nodes

      positions = @spawn_nodes.dup

      objects = []

      objects.push *generate_objects("Enemy", Enemy.config, positions.pop(150))
      objects.push *generate_objects("Item", Item.config, positions.pop(150))

      objects
    end

    def generate_objects(klass_name, types, positions)
      # Work out the total frequencies to pick from.
      total_frequencies = types.each_value.inject(0) {|m, t| m + t[:frequency] }

      positions.each.with_object [] do |position, objects|
        # Target marks which type to choose.
        target = @rng.rand total_frequencies
        type = types.find {|t| target -= t[1][:frequency]; target < 0 }
        objects << [klass_name, type[0], position]
      end
    end
  end
end