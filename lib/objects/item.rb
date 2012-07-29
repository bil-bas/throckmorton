module Game
  # Items are picked up by the player.
  class Item < PhysicsObject
    SPRITE_WIDTH = 32

    class << self
      def sprites
        @sprites ||= SpriteSheet["item.png", SPRITE_WIDTH, SPRITE_WIDTH, 8]
      end

      def config
        @config ||= YAML.load_file(File.expand_path("../../../config/items.yml", __FILE__))
      end
    end

    attr_reader :type

    def short_name; "#{type}#{id_string}" end
    def needs_sync?; false end

    def initialize(type, x, y, options = {})
      @type = type
      config = self.class.config[type]
      raise [@type, config].inspect unless config

      options = {
          zorder: ZOrder::ITEM,
          collision_type: :item,
          angle: rand(4) * 90,
          width: config[:collision_width],
          height: config[:collision_width],
          speed: 0,
          x: x,
          y: y,
      }.merge! options

      super options

      if parent.client?
        sheet_position = config[:spritesheet_position]
        self.image = self.class.sprites[sheet_position[:x], sheet_position[:y]]
      end

      Messages::CreateItem.broadcast(self) if parent.server?

      @minimap_color = Color.rgb *config[:minimap_color]
      @modify = config[:modify]
      @sound = config[:sound]

      debug { "Created #{short_name} at #{position}" }
    end

    def activated_by(player)
      picked_up = false

      if @modify.has_key?(:health) && player.health < player.max_health
        player.health += @modify[:health]
        picked_up = true
      end

      if @modify.has_key?(:energy) && player.energy < player.max_energy
        player.energy += @modify[:energy]
        picked_up = true
      end

      if @modify.has_key?(:score)
        player.score += @modify[:score]
        picked_up = true
      end

      if picked_up
        Sample[@sound[:file]].play @sound[:volume]
        self.destroy
      end

      nil
    end

    def draw_mini
      parent.pixel.draw_rot x.round, y.round, zorder, 0, 0.5, 0.5, 14, 14, @minimap_color
    end
  end
end