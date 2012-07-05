require 'set'

module Game
  class Player < Entity
    DIAGONAL = 0.785
    WIDTH = 12
    SHOOT_OFFSET = 14 # Pixels from center to create the projectile.

    trait :timer

    attr_accessor :max_energy, :score
    attr_reader :energy

    def fire_primary?; energy >= @fire_primary_cost end
    def fire_secondary?; energy >= @fire_secondary_cost end
    def can_see?(tile); @visible_tile_positions.include? [tile.grid_x, tile.grid_y] end
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

      super x: x, y: y, max_health: 100, speed: 18,
            zorder: ZOrder::PLAYER, width: WIDTH,
            collision_type: :player, illumination_range: 5

      if parent.client?
        self.image = Image["player16.png"].thin_outlined
      end

      info { "Created #{short_name} at #{tile.grid_position}" }

      if parent.client?
        on_input :left_mouse_button do
          if fire_primary?
            self.energy -= @fire_primary_cost
            bullet = Projectile.new :zap,
                                    self.x + offset_x(angle, SHOOT_OFFSET),
                                    self.y + offset_y(angle, SHOOT_OFFSET),
                                    angle,
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
                                      speed: 40,
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
        self.angle = Gosu::angle($window.width / 2, $window.height / 2, $window.mouse_x, $window.mouse_y)
      end

      if parent.server?
        @energy = [@energy + @energy_per_second * parent.frame_time, @max_energy].min
        self.health += @health_per_second * parent.frame_time
      end

      reset_forces

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
      else
        # Slow down quickly.
        @body.vel.x *= 0.9
        @body.vel.y *= 0.9
      end
      
      super
    end

    def tile_blocked?(x, y)
      tile = parent.map.tile_at_coordinate self.x + x, self.y + y

      tile.nil? || tile.blocks_movement?
    end
    
    def draw
      @image.draw_rot x.round, y.round, zorder, angle, 0.5, 0.5 #, 0.5, 0.5
    end
    
    def draw_mini
      parent.pixel.draw_rot x.round, y.round, zorder, 0, 0.5, 0.5, 14, 14, Color.rgb(0, 0, 0)
    end

    def draw_gui
      @font ||= Font[24]
      parent.pixel.draw 0, 0, ZOrder::GUI, $window.width, 24, Color.rgba(0, 0, 0, 150)

      objects = parent.objects
      @@num_lava ||= parent.map.tiles.flatten.count {|t| t.type == :lava }
      num_lights = 1 + @@num_lava + objects.count {|o| o.is_a?(Enemy) && o.type == :fire_beetle } # Note: Player isn't in objects (currently)
      num_mobs = objects.count {|o| o.is_a? Enemy}

      @font.draw "Health: #{health.floor}  Energy: #{energy.floor}  Score: #{score} -- Obj: #{objects.size} Mob: #{num_mobs} Light: #{num_lights} -- FPS: #{$window.fps.round} [#{$window.potential_fps.round}]", 0, 0, ZOrder::GUI
    end
  end
end