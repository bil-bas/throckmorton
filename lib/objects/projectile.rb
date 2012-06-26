module Game
  class Projectile < PhysicsObject
    COLOR = Color.rgb(0, 255, 255)
  
    def time; parent.time; end    
    def frame_time; parent.frame_time; end
    
    def initialize(x, y, direction_x, direction_y, options = {})
      options = {
        rotation_speed: 0.0,
        duration: 0.5,
        speed: 50,
        rotation_center: :center_center,
        zorder: ZOrder::PROJECTILES,
      }.merge! options
      
      @speed = options[:speed]
      @duration = options[:duration]
      @rotation_speed = options[:rotation_speed]   
    
      @direction_x, @direction_y = direction_x, direction_y

      image = TexPlay.create_image $window, 2, 6, color: COLOR

      super options.merge(x: x, y: y, image: image)

      @created_at = time

      move @direction_x, @direction_y
    end
    
    def update
      if time - @created_at > @duration
        destroy
      else
        self.angle += @rotation_speed
      end
    end

    def draw_mini    
      parent.pixel.draw_rot x, y, zorder, 0, 0.5, 0.5, 8, 8, COLOR
    end
  end
end