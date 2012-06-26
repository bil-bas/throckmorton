module Game
  class Player < PhysicsObject
    DIAGONAL = 0.785
    WIDTH = 9
    SHOOT_OFFSET = 10 # Pixels from center to create the projectile.

    trait :timer

    attr_accessor :health, :energy, :score

    def initialize(x, y)
      @speed = 75
      @facing_x, @facing_y = 1, 0 # Start off facing right.

      @score = 0
      @health = 100
      @energy = 100

      image = TexPlay.create_image $window, WIDTH, WIDTH
      image.circle WIDTH / 2, WIDTH / 2, WIDTH / 2, color: Color.rgb(50, 50, 50), fill: true

      super x: x, y: y, rotation_center: :center_center,
            image: image, zorder: ZOrder::PLAYER,
            collision_type: :player
      
      on_input :space do
        if energy >= 5
          self.energy -= 5
          bullet = Projectile.new self.x + @facing_x * SHOOT_OFFSET, self.y + @facing_y * SHOOT_OFFSET,
                                  @facing_x, @facing_y,
                                  rotation_speed: 5,
                                  collision_type: :player_projectile,
                                  group: :player_projectiles
          parent.add_object bullet
        end
      end
    end
        
    def update
      @energy = [@energy + parent.frame_time, 100].min

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
      
      super
    end

    def tile_blocked?(x, y)
      tile = parent.map.tile_at_coordinate self.x + x, self.y + y

      tile.nil? || tile.blocks_movement?
    end
    
    def draw
      @image.draw_rot x.round, y.round, zorder, 0, 0.5, 0.5
    end
    
    def draw_mini
      parent.pixel.draw_rot x.round, y.round, zorder, 0, 0.5, 0.5, 14, 14, Color.rgb(0, 0, 0)
    end

    def draw_gui
      @font ||= Font[24]
      parent.pixel.draw 0, 0, Float::INFINITY, $window.width, 24, Color.rgba(0, 0, 0, 150)
      @font.draw "Health: #{health.floor}  Energy: #{energy.floor}  Score: #{score}", 0, 0, Float::INFINITY
    end
  end
end