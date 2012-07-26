module Game
  class Enemy < Entity
    SPRITE_WIDTH = 48

    LINE_OF_SIGHT_BLOCKED_COLOR = Color.rgba 255, 0, 0, 50
    LINE_OF_SIGHT_COLOR = Color.rgba 0, 0, 255, 50

    include Mixins::LightSource

    attr_reader :melee_damage, :type
    def short_name; "#{type}#{id_string}" end

    class << self
      def config
        @config ||= YAML.load_file(File.expand_path("../../../config/enemies.yml", __FILE__))
      end
      def sprites
        @sprites ||= SpriteSheet["enemy.png", SPRITE_WIDTH, SPRITE_WIDTH, 8]
      end
    end

    def can_fire?; !!@ranged_weapon end

    def initialize(type, x, y, options = {})
      @type = type
      config = self.class.config[type]
      raise [@type, config].inspect unless config

      @ranged_weapon, @fire_chance = if config.has_key? :ranged_weapon
        [
            Equipment.new(config[:ranged_weapon][:type], self),
            config[:ranged_weapon][:fire_chance],
        ]
      else
        [nil, nil]
      end

      @melee_damage = config[:melee][:damage] || raise

      super x: x, y: y,
            width: config[:collision_width], height: config[:collision_width],
            max_health: config[:max_health], health: options[:health],
            zorder: ZOrder::ENEMY, illumination_range: config[:illumination_range],
            collision_type: :enemy, speed: config[:speed]

      if parent.client?
        sheet_position = config[:spritesheet_position]
        self.image = self.class.sprites[sheet_position[:x], sheet_position[:y]]
      end

      Messages::CreateEnemy.broadcast(self) if parent.server?

      debug { "Created #{short_name} at #{position}" }
    end

    def update
      reset_forces

      @player_blocked_at = line_of_sight_blocked_at parent.player

      # turn to face the player or skirmish or advance.
      unless @player_blocked_at
        self.angle = Gosu::angle(x, y, parent.player.x, parent.player.y)

        range = distance_to parent.player
        if can_fire? and @ranged_weapon.skirmish_range.include? range
          if rand() <= @fire_chance
            @ranged_weapon.fire
          end
        elsif @ranged_weapon and range < @ranged_weapon.skirmish_range.min
          move_away_from parent.player
        else
          move_towards parent.player
        end
      end

      super
    end

    def draw
      @image.draw_rot x, y, zorder, angle, 0.5, 0.5
    end

    def draw_physics
      super

      # Draw a sight line, as far as it can go, towards the player.
      color, position = if @player_blocked_at
        [LINE_OF_SIGHT_BLOCKED_COLOR, @player_blocked_at]
      else
        [LINE_OF_SIGHT_COLOR, [parent.player.x, parent.player.y]]
      end

      $window.draw_line x, y, color,
                        *position, color,
                        zorder
    end

    def draw_mini
      parent.pixel.draw_rot x.round, y.round, zorder, 0, 0.5, 0.5, 20, 20, Color.rgb(255, 0, 0)
    end
  end
end