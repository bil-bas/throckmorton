require 'set'

module Game
  class Player < PhysicsObject
    DIAGONAL = 0.785
    WIDTH = 17
    SHOOT_OFFSET = 14 # Pixels from center to create the projectile.

    include LineOfSight

    trait :timer

    attr_accessor :health, :max_health, :energy, :max_energy, :score
    attr_reader :visual_range

    def fire_primary?; energy >= @fire_primary_cost end
    def fire_secondary?; energy >= @fire_secondary_cost end
    def can_see?(tile); @visible_tile_positions.include? [tile.grid_x, tile.grid_y] end

    def initialize(x, y)
      @speed = 150

      @score = 0

      @max_health = 100
      @health = @max_health
      @health_per_second = 0.5

      @max_energy = 100
      @energy = @max_energy
      @energy_per_second = 4
      @fire_primary_cost = 5
      @fire_secondary_cost = 25

      @visual_range = 5

      image = TexPlay.create_image $window, WIDTH, WIDTH
      image.circle WIDTH / 2, WIDTH / 2, WIDTH / 2, color: Color.rgb(50, 50, 50), fill: true
      image.set_pixel WIDTH / 2 - 1, 1
      image.set_pixel WIDTH / 2 + 1, 1

      super x: x, y: y,
            image: image, zorder: ZOrder::PLAYER,
            collision_type: :player
      
      on_input :left_mouse_button do
        if fire_primary?
          self.energy -= @fire_primary_cost
          bullet = Projectile.new self.x + offset_x(angle, SHOOT_OFFSET),
                                  self.y + offset_y(angle, SHOOT_OFFSET),
                                  angle,
                                  rotation_speed: 30,
                                  collision_type: :player_projectile,
                                  group: :player_projectiles,
                                  duration: 0.5
          parent.add_object bullet
        end
      end

      on_input :right_mouse_button do
        if fire_secondary?
          self.energy -= @fire_secondary_cost
          (0...360).step(30) do |angle|
            bullet = Projectile.new self.x + offset_x(angle, SHOOT_OFFSET),
                                    self.y + offset_y(angle, SHOOT_OFFSET),
                                    angle,
                                    speed: 40,
                                    rotation_speed: 5,
                                    collision_type: :player_projectile,
                                    group: :player_projectiles,
                                    duration: 0.4

            parent.add_object bullet
          end
        end
      end
    end

    def update
      self.angle = Gosu::angle($window.width / 2, $window.height / 2, $window.mouse_x, $window.mouse_y)
      @energy = [@energy + @energy_per_second * parent.frame_time, @max_energy].min
      @health = [@health + @health_per_second * parent.frame_time, @max_health].min

      if holding_any? :up, :w
        if holding_any? :left, :a
          @facing_x, @facing_y = -DIAGONAL, -DIAGONAL
        elsif holding_any? :right, :d
          @facing_x, @facing_y = DIAGONAL, -DIAGONAL
        else          
          @facing_x, @facing_y = 0, -1
        end
        
      elsif holding_any? :down, :s
        if holding_any? :left, :a
          @facing_x, @facing_y = -DIAGONAL, DIAGONAL
        elsif holding_any? :right, :d
          @facing_x, @facing_y = DIAGONAL, DIAGONAL
        else          
          @facing_x, @facing_y = 0, +1
        end
        
      elsif holding_any? :left, :a
        @facing_x, @facing_y = -1, 0
        
      elsif holding_any? :right, :d
        @facing_x, @facing_y = +1, 0
      end     
      
      if holding_any? :w, :a, :s, :d,
                      :up, :down, :left, :right
        move_x = @facing_x * @speed * parent.frame_time
        move_y = @facing_y * @speed * parent.frame_time

        if move_x != 0
          if move_x > 0
            blocked_tr = tile_blocked? width / 2 + move_x, -height / 2
            blocked_br = tile_blocked? width / 2 + move_x, height / 2

            unless blocked_tr or blocked_br
              self.x += move_x
            end
          elsif move_x < 0
            blocked_tl = tile_blocked? -width / 2 + move_x, -height / 2
            blocked_bl = tile_blocked? -width / 2 + move_x, height / 2

            unless blocked_tl or blocked_bl
              self.x += move_x
            end
          end
        end

        if move_y != 0
          if move_y > 0
            blocked_bl = tile_blocked? -width / 2, height / 2 + move_y
            blocked_br = tile_blocked? width / 2,  height / 2 + move_y

            unless blocked_bl or blocked_br
              self.y += move_y
            end
          elsif move_y < 0
            blocked_tl = tile_blocked? -width / 2, -height / 2 + move_y
            blocked_tr = tile_blocked? width / 2,  -height / 2 + move_y

            unless blocked_tl or blocked_tr
              self.y += move_y
            end
          end
        end
      end

      see_tiles
      
      super
    end

    def see_tiles
      map = parent.map
      tile = map.tile_at_coordinate x, y
      tile_x, tile_y = tile.grid_x, tile.grid_y
      @visible_tile_positions = Set.new # Store list of [x, y] that are visible.

      ((tile_y - @visual_range)..(tile_y + @visual_range)).each do |offset_y|
        ((tile_x - @visual_range)..(tile_x + @visual_range)).each do |offset_x|
          if distance(tile_x, tile_y, offset_x, offset_y) <= @visual_range
            tile = map.tile_at_grid offset_x, offset_y
            if tile && line_of_sight?(tile)
              @visible_tile_positions << [tile.grid_x, tile.grid_y]
              tile.seen = true unless tile.seen?
            end
          end
        end
      end

      update_lighting
    end

    def update_lighting
      player_x, player_y = x / Tile::WIDTH, y / Tile::WIDTH
      periodic_brightness = Math::sin(milliseconds / 200.0) * 0.05 + 0.05
      scale_i = Map::LIGHTING_SCALE
      scale_f = scale_i.to_f
      parent.map.lighting_overlay.circle player_x * scale_i, player_y * scale_i,
                                         visual_range * scale_i, fill: true,
                                         color_control: lambda {|c, x, y|

        if @visible_tile_positions.include? [x / scale_i, y / scale_i]
          distance = distance(player_x, player_y, x / scale_f, y / scale_f)
          [0.1, 0.1, 0, Math::log((2 * distance) / visual_range) + periodic_brightness]
        else
          Map::NO_LIGHT_COLOR
        end
      }
    end

    def tile_blocked?(x, y)
      tile = parent.map.tile_at_coordinate self.x + x, self.y + y

      tile.nil? || tile.blocks_movement?
    end
    
    def draw
      @image.draw_rot x.round, y.round, zorder, angle, 0.5, 0.5
    end
    
    def draw_mini
      parent.pixel.draw_rot x.round, y.round, zorder, 0, 0.5, 0.5, 14, 14, Color.rgb(0, 0, 0)
    end

    def draw_gui
      @font ||= Font[24]
      parent.pixel.draw 0, 0, ZOrder::GUI, $window.width, 24, Color.rgba(0, 0, 0, 150)
      @font.draw "Health: #{health.floor}  Energy: #{energy.floor}  Score: #{score} FPS: #{$window.fps.round} [#{$window.potential_fps.round}]", 0, 0, ZOrder::GUI
    end
  end
end