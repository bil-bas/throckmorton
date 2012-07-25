require 'set'

module Game
  class Player < Entity
    DIAGONAL = 0.785
    WIDTH = 12

    INFO_BAR_HEIGHT = 24
    STAT_BAR_HEIGHT = 16

    trait :timer

    attr_accessor :max_energy, :score
    attr_reader :energy

    def short_name; "player"; end

    def energy=(value)
      @energy = value
      Messages::Set.broadcast(self, :energy, @energy) if parent.server?
      @energy
    end

    def initialize(x, y)
      @score = 0

      @health_per_second = 0.5

      @max_energy = 100
      @energy = @max_energy
      @energy_per_second = 4
      @primary_weapon = Equipment.new :zap, self
      @secondary_weapon = Equipment.new :blast, self

      self.width, self.height = WIDTH, WIDTH

      super x: x, y: y, max_health: 100, speed: 800,
            zorder: ZOrder::PLAYER, width: WIDTH,
            collision_type: :player

      if parent.client?
        self.image = Image["player.png"]
      end

      debug { "Created #{short_name} at #{position}" }

      if parent.client?
        scale = parent.world_scale
        radius = 150.0 # See for N pixels radius full tiles around.
        @light = parent.map.lighting.create_light x / scale, y / scale, zorder, radius, color: Color::WHITE
        debug { "Player 'light' created at #{[@light.x, @light.y]}" }

        on_input :left_mouse_button do
          @primary_weapon.fire if @primary_weapon.can_fire?
        end

        on_input :right_mouse_button do
          @secondary_weapon.fire if @secondary_weapon.can_fire?
        end
      end
    end

    def update
      if parent.server?
        @energy = [@energy + @energy_per_second * parent.frame_time, @max_energy].min
        self.health += @health_per_second * parent.frame_time
      end

      move_angle =  if holding_any? :up, :w
                      if holding_any? :left, :a
                        305
                      elsif holding_any? :right, :d
                        45
                      else
                        0
                      end

                    elsif holding_any? :down, :s
                      if holding_any? :left, :a
                        225
                      elsif holding_any? :right, :d
                        135
                      else
                        180
                      end

                    elsif holding_any? :left, :a
                      270

                    elsif holding_any? :right, :d
                      90
                    end


      if move_angle
        move offset_x(move_angle, 1), offset_y(move_angle, 1)
      end

      if parent.client?
        scale = parent.world_scale
        self.angle = Gosu::angle($window.width / scale, $window.height / scale, $window.mouse_x, $window.mouse_y)
        @light.x, @light.y = x / scale, y / scale
      end
      
      super
    end
    
    def draw
      @image.draw_rot x, y, zorder, angle, 0.5, 0.5
    end
    
    def draw_mini
      parent.pixel.draw_rot x.round, y.round, zorder, 0, 0.5, 0.5, 32, 32,
                            Color.rgb(0, Math::sin(milliseconds / 100.0) * 50 + 125, 0)
    end

    def draw_gui
      $window.translate 0, $window.height - INFO_BAR_HEIGHT / 2 do
        parent.pixel.draw_rot 0, 0, ZOrder::GUI, 0, 0, 0.5,
                          $window.width, INFO_BAR_HEIGHT, Color.rgba(0, 0, 0, 100)

        Font[20].draw_rel score.to_s, $window.width / 2, 0, ZOrder::GUI,
                          0.5, 0.5

        bar_length = $window.width * 0.4
        parent.pixel.draw_rot 0, 0, ZOrder::GUI, 0, 0.0, 0.5,
                              bar_length, STAT_BAR_HEIGHT, Color::BLACK
        parent.pixel.draw_rot 0, 0, ZOrder::GUI, 0, 0.0, 0.5,
                              health.fdiv(max_health) * bar_length, STAT_BAR_HEIGHT, Color::RED

        parent.pixel.draw_rot $window.width, 0, ZOrder::GUI, 0, 1.0, 0.5,
                              bar_length, STAT_BAR_HEIGHT, Color::BLACK
        parent.pixel.draw_rot $window.width, 0, ZOrder::GUI, 0, 1.0, 0.5,
                              energy.fdiv(max_energy) * bar_length, STAT_BAR_HEIGHT, Color::CYAN
      end
    end
  end
end