require 'set'

module Game
  class Player < Entity
    DIAGONAL = 0.785
    WIDTH = 12
    SHOOT_OFFSET = 14 # Pixels from center to create the projectile.

    INFO_BAR_HEIGHT = 24
    STAT_BAR_HEIGHT = 16

    trait :timer

    attr_accessor :max_energy, :score
    attr_reader :energy

    def fire_primary?; energy >= @fire_primary_cost end
    def fire_secondary?; energy >= @fire_secondary_cost end
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
      @fire_primary_cost = 4
      @fire_secondary_cost = 25

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
          if fire_primary?
            self.energy -= @fire_primary_cost
            bullet = Projectile.new :zap,
                                    self.x + offset_x(angle, SHOOT_OFFSET),
                                    self.y + offset_y(angle, SHOOT_OFFSET),
                                    angle,
                                    speed: 1500,
                                    rotation_speed: 30,
                                    collision_type: :player_projectile,
                                    group: :player_projectiles,
                                    duration: 0.5,
                                    damage: 5..15
            parent.add_object bullet
          end
        end

        on_input :right_mouse_button do
          if fire_secondary?
            self.energy -= @fire_secondary_cost
            (0...360).step(30) do |angle|
              bullet = Projectile.new :burst,
                                      self.x + offset_x(angle, SHOOT_OFFSET),
                                      self.y + offset_y(angle, SHOOT_OFFSET),
                                      angle,
                                      speed: 900,
                                      rotation_speed: 5,
                                      collision_type: :player_projectile,
                                      group: :player_projectiles,
                                      duration: 0.4,
                                      damage: 25..40

              parent.add_object bullet
            end
          end
        end
      end
    end

    def update
      if parent.client?
        scale = parent.world_scale
        self.angle = Gosu::angle($window.width / scale, $window.height / scale, $window.mouse_x, $window.mouse_y)
        @light.x, @light.y = x / scale, y / scale
      end

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
      
      super
    end
    
    def draw
      @image.draw_rot x.round, y.round, zorder, angle, 0.5, 0.5
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