module Game
  class Player < Chingu::GameObject 
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
        self.y -= @speed * parent.frame_time
        @facing_x, @facing_y = 0, -1
      elsif holding_any? :down, :s
        self.y += @speed * parent.frame_time
        @facing_x, @facing_y = 0, 1
      elsif holding_any? :left, :a
        self.x -= @speed * parent.frame_time
        @facing_x, @facing_y = -1, 0
      elsif holding_any? :right, :d
        self.x += @speed * parent.frame_time
        @facing_x, @facing_y = +1, 0
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