module Game
  class WorldMaker
    SPAWN_SPACING = 32
    SPAWN_MARGIN = SPAWN_SPACING / 2 # Space around spawn required to be clear.

    NAVIGATION_SPACING = 8
    NAVIGATION_MARGINS = [32, 24, 16, 8]

    def initialize(map_texture, seed)
      @map_texture = map_texture
      @rng = Random.new seed

      generate_navigation_nodes
    end

    def draw
      @recording ||= $window.record 1, 1 do
        @navigation_nodes.each_with_index do |column, x|
          column.each_with_index do |navigable_margin, y|
            if navigable_margin
              size = navigable_margin.fdiv NAVIGATION_SPACING
              $window.pixel.draw_rot x * NAVIGATION_SPACING, y * NAVIGATION_SPACING,
                                     0, 0, 0.5, 0.5, size, size, Color::YELLOW
            end
          end
        end

        @spawn_nodes.each do |x, y|
          $window.pixel.draw_rot x, y, 0, 0, 0.5, 0.5, 3, 3, Color::RED
        end
      end

      @recording.draw 0, 0, 0
    end

    # Nodes indicate the distance from themselves to a blockage. 0 if the node is in scenery.
    # TODO: should definitely be done in a shader :)
    def generate_navigation_nodes
      t = Time.now

      @navigation_nodes = Array.new(@map_texture.width / NAVIGATION_SPACING) do |x|
        Array.new(@map_texture.height / NAVIGATION_SPACING) do |y|
          distance = NAVIGATION_MARGINS.find do |margin|
            valid_position? x * NAVIGATION_SPACING, y * NAVIGATION_SPACING, margin
          end

          distance || 0
        end
      end

      info "Navigation nodes plotted out in #{((Time.now - t).to_f * 1000).to_i}ms"
    end

    # Spawn nodes are places where something could spawn.
    def generate_spawn_nodes
      @spawn_nodes = []

      (0...@map_texture.width).step(SPAWN_SPACING) do |x|
        (0...@map_texture.height).step(SPAWN_SPACING) do |y|
          distance_to_blockage = @navigation_nodes[x / NAVIGATION_SPACING][y / NAVIGATION_SPACING]
          if distance_to_blockage >= SPAWN_MARGIN
            @spawn_nodes << [x, y]
          end
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

    def valid_position?(x, y, margin)
      return false if @map_texture[x, y] == Textures::CavernWall.color

      # Step out else, for large margins, we might see past a blockage.
      (NAVIGATION_SPACING..margin).step NAVIGATION_SPACING do |distance|
        diagonal_distance = distance * 0.7
        colors = [
            # Orthogonals.
            @map_texture[x + distance, y],
            @map_texture[x - distance, y],
            @map_texture[x, y + distance],
            @map_texture[x, y - distance],

            # Diagonals.
            @map_texture[x + diagonal_distance, y + diagonal_distance],
            @map_texture[x - diagonal_distance, y + diagonal_distance],
            @map_texture[x - diagonal_distance, y - diagonal_distance],
            @map_texture[x + diagonal_distance, y - diagonal_distance],
        ]

        return false if colors.include? Textures::CavernWall.color
      end

      return true
    end
  end
end