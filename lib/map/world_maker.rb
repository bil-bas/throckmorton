module Game
  class WorldMaker
    SPAWN_SPACING = 32
    SPAWN_MARGIN = SPAWN_SPACING / 2 # Space around spawn required to be clear.

    NAVIGATION_SPACING = 16
    NAVIGATION_MARGIN = NAVIGATION_SPACING / 2

    def initialize(map_texture)
      @map_texture = map_texture
      generate_navigation_nodes
      generate_spawn_nodes
    end

    def draw
      @recording ||= $window.record 1, 1 do
        @spawn_nodes.each do |x, y|
          $window.pixel.draw_rot x, y, 0, 0, 0.5, 0.5, 3, 3, Color::RED
        end

        @navigation_nodes.each_with_index do |row, y|
          row.each_with_index do |navigable, x|
            if navigable
              $window.pixel.draw_rot x * NAVIGATION_SPACING, y * NAVIGATION_SPACING,
                                     0, 0, 0.5, 0.5, 1, 1, Color::YELLOW
            end
          end
        end
      end

      @recording.draw 0, 0, 0
    end

    def generate_navigation_nodes
      @navigation_nodes = Array.new(@map_texture.height / NAVIGATION_SPACING) do |y|
        Array.new(@map_texture.width / NAVIGATION_SPACING)  do |x|
          valid_position? x * NAVIGATION_SPACING, y * NAVIGATION_SPACING, NAVIGATION_MARGIN
        end
      end
    end

    def generate_spawn_nodes
      @spawn_nodes = []

      (0...@map_texture.width).step(SPAWN_SPACING) do |x|
        (0...@map_texture.height).step(SPAWN_SPACING) do |y|
          @spawn_nodes << [x, y]
        end
      end

      select_valid_positions @spawn_nodes, SPAWN_MARGIN
      @spawn_nodes.shuffle!
    end

    def generate_object_data(seed)
      positions = @spawn_nodes.dup

      objects = []


      enemy_types = Enemy.config.map {|k, v| [k] * v[:frequency] }.flatten.shuffle

      enemy_types.size.times do
        objects << [Enemy.name[/[^:]+$/], *positions.pop, enemy_types.pop]
      end

      20.times do
        objects << [EnergyPack.name[/[^:]+$/], *positions.pop]
      end

      15.times do
        objects << [HealthPack.name[/[^:]+$/], *positions.pop]
      end

      30.times do
        objects << [Treasure.name[/[^:]+$/], *positions.pop]
      end

      objects
    end

    def select_valid_positions(positions, margin)
      positions.select! do |x, y|
        valid_position? x, y, margin
      end
    end

    def valid_position?(x, y, margin)
      colors = [
          @map_texture[x, y],
          @map_texture[x + margin, y],
          @map_texture[x - margin, y],
          @map_texture[x, y + margin],
          @map_texture[x, y - margin],
      ]

      colors.none? { |c| c == Textures::CavernWall.color }
    end
  end
end