module Game
  class Player < PhysicsObject
    DIAGONAL = 0.785
    WIDTH = 8
    SHOOT_OFFSET = 7 # Pixels from center to create the projectile.
  
    def initialize(x, y)
      @speed = 75      
      @facing_x, @facing_y = 1, 0

      image = TexPlay.create_image $window, WIDTH, WIDTH, color: Color.rgb(50, 50, 50)

      super x: x, y: y, rotation_center: :center_center,
            image: image, zorder: ZOrder::PLAYER,
            collision_type: :player
      
      on_input :space do
        bullet = Projectile.new self.x + @facing_x * SHOOT_OFFSET, self.y + @facing_y * SHOOT_OFFSET,
                                @facing_x, @facing_y,
                                rotation_speed: 5,
                                collision_type: :player_projectile,
                                group: :player_projectiles
        parent.add_object bullet
      end
    end
        
    def update                    
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
        self.x += @facing_x * @speed * parent.frame_time
        self.y += @facing_y * @speed * parent.frame_time
      end
      
      super
    end
    
    def draw
      @image.draw_rot x.round, y.round, zorder, 0, 0.5, 0.5
    end
    
    def draw_mini
      parent.pixel.draw_rot x.round, y.round, zorder, 0, 0.5, 0.5, 14, 14, Color.rgb(0, 0, 0)
    end 
  end
end