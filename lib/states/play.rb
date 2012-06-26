module Game
  class Play < Chingu::GameState
    attr_reader :time, :frame_time
    attr_reader :pixel
    attr_reader :world_scale
    attr_reader :space
    
    DEFAULT_WORLD_SCALE = 3.0
    PHYSICS_STEP = 1 / 240.0
       
    def initialize
      super

      init_physics
      
      @time = Time.now.to_f

      @objects = []   
      
      @pixel = TexPlay.create_image $window, 1, 1, color: :white
      @world_scale = DEFAULT_WORLD_SCALE
      
      @map = Map.new 100
      
      @player = Player.new *@map.start_position
    end

    def init_physics
      # Set up Chipmunk physics.
      @space = CP::Space.new
      @space.damping = 0.05

      @space.on_collision(:player, :enemy) do |player, enemy|
        # TODO: weaken player and enemy
        p "player touched enemy"
        enemy.destroy
        true
      end

      @space.on_collision(:player, :enemy_projectile) do |player, projectile|
        # TODO: weaken player
        p "enemy projectile touched player"
        projectile.destroy
        true
      end

      @space.on_collision(:enemy, :player_projectile) do |enemy, projectile|
        # TODO: weaken enemy
        p "player projectile touched enemy"
        enemy.destroy
        projectile.destroy
        true
      end

      @physics_time = 0.0 # The amount of time we have backlogged for physics.
    end
       
    def update      
      @frame_time = Time.now.to_f - @time
      @time = Time.now.to_f

      update_physics
      
      @player.update
      @objects.each {|o| o.update }
      
      super
    end

    def update_physics
      #@objects.each {|o| o.reset_forces }

      @physics_time += frame_time
      num_steps = (@physics_time / PHYSICS_STEP).round
      @physics_time -= num_steps * PHYSICS_STEP
      num_steps.times { @space.step PHYSICS_STEP }
    end
    
    def add_object(object)
      @objects << object
    end
    
    def remove_object(object)
      @objects.delete object
    end   

    def draw
      $window.scale world_scale do
        $window.translate ($window.width / (world_scale * 2)) - @player.x.round, ($window.height / (world_scale * 2))  - @player.y.round do
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