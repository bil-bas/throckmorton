module Game
  class Play < Chingu::GameState
    attr_reader :time, :frame_time
    attr_reader :pixel
       
    def initialize
      super
      
      @time = Time.now.to_f

      @objects = []   
      
      @pixel = TexPlay.create_image $window, 1, 1, color: :white
      
      
      @map = Map.new 100
      
      @player = Player.new *@map.start_position
    end
       
    def update      
      @frame_time = Time.now.to_f - @time
      @time = Time.now.to_f
      
      @player.update
      @objects.each {|o| o.update }
      
      super
    end
    
    def add_object(object)
      @objects << object
    end
    
    def remove_object(object)
      @objects.delete object
    end

    def draw
      $window.scale 2 do
        $window.translate 160 - @player.x.round, 120 - @player.y.round do
          @map.draw         
          @objects.each {|o| o.draw }        
          @player.draw
        end          
      end
      
      draw_map_overlay if holding? :tab  

      super      
    end
    
    def draw_map_overlay
      $window.flush
      
      pixel.draw 0, 0, 0, $window.width, $window.height, Color.rgba(0, 0, 0, 200)
      
      $window.scale Map::MINI_SCALE do         
        $window.translate ($window.width / Map::MINI_SCALE) * 0.5 - (@map.width / 2),
                          ($window.height / Map::MINI_SCALE) * 0.5 - (@map.height / 2) do
                          
          pixel.draw -8, -8, 0, @map.width + 16, @map.height + 16, Color::BLACK   
          
          @map.draw_mini 
          @objects.each {|o| o.draw_mini }
          @player.draw_mini
        end
      end
    end
  end
end