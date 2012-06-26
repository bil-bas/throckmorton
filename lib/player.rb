module Game
  class Player < Chingu::GameObject 
    DIAGONAL = 0.785
  
    def initialize(x, y)
      @@image ||= TexPlay.create_image $window, 8, 8, color: :black
      
      @speed = 100      
      @facing_x, @facing_y = 1, 0
      
      super x: x, y: y, rotation_center: :center_center, image: @@image, zorder: ZOrder::PLAYER
      
      on_input :space do
        parent.add_object Projectile.new(self.x, self.y, @facing_x, @facing_y, rotation_speed: 5)        
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