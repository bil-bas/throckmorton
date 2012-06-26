module Game
  class Projectile < Chingu::GameObject
    def time; parent.time; end    
    def frame_time; parent.frame_time; end
    
    def initialize(x, y, direction_x, direction_y, options = {})
      options = {
        rotation_speed: 0,
        duration: 0.75,
        speed: 3,
      }.merge! options
      
      @speed = options[:speed]
      @duration = options[:duration]
      @rotation_speed = options[:rotation_speed]   
    
      @direction_x, @direction_y = direction_x, direction_y            
      
      @@image ||= TexPlay.create_image $window, 2, 6, color: Color.rgb(0, 255, 255)
           
      super x: x, y: y, rotation_center: :center_center, image: @@image, zorder: 0
      
      @created_at = time
      
      @speed = 3     
    end
    
    def destroy
      parent.remove_object self
      super
    end
    
    def update
      if time - @created_at > @duration
        destroy
      else
        self.x += @direction_x * @speed
        self.y += @direction_y * @speed
        self.angle += @rotation_speed
      end
    end  

    def draw_mini    
      parent.pixel.draw_rot x, y, zorder, 0, 0.5, 0.5
    end
  end
end