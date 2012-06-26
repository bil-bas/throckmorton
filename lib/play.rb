module Game
  class Play < Chingu::GameState
    attr_reader :time, :frame_time
    attr_reader :pixel
       
    def initialize
      super
      
      @time = Time.now.to_f

      @objects = []   
      
      @pixel = TexPlay.create_image $window, 1, 1, color: :white
      
      
      @map = Map.new 16
      
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
      
      if holding? :tab 
        $window.scale Map::MINI_SCALE do
          @map.draw_mini 
          @objects.each {|o| o.draw_mini }
          @player.draw_mini
        end
      end    

      super      
    end
  end
end