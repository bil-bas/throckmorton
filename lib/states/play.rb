module Game
  class Play < Chingu::GameState
    attr_reader :time, :frame_time
    attr_reader :pixel
    attr_reader :world_scale
    attr_reader :space
    attr_reader :map, :player
    
    DEFAULT_WORLD_SCALE = 2
    PHYSICS_STEP = 1 / 60.0
       
    def initialize
      super

      init_physics
      
      @time = Time.now.to_f

      @objects = []   
      
      @pixel = TexPlay.create_image $window, 1, 1, color: :white
      @world_scale = DEFAULT_WORLD_SCALE

      @map = Map.new 30
      @player = Player.new *@map.start_position

      on_input :escape do
        pop_game_state
        push_game_state self.class
      end
    end

    def init_physics
      # Set up Chipmunk physics.
      @space = CP::Space.new
      @space.damping = 0.05

      @space.on_collision(:player, :enemy) do |player, enemy|
        player.health -= 5
        enemy.destroy
        false
      end

      @space.on_collision(:player, :enemy_projectile) do |player, projectile|
        player.health -= 1
        projectile.destroy
        false
      end

      @space.on_collision(:enemy, :player_projectile) do |enemy, projectile|
        enemy.health -= 1
        projectile.destroy
        false
      end

      # No friendly fire.
      @space.on_collision(:enemy, :enemy_projectile) do |enemy, projectile|
        false
      end

      @space.on_collision(:player_projectile, :enemy_projectile) do |p1, p2|
        p1.destroy
        p2.destroy
        false
      end

      @space.on_collision(:player, :item) do |player, item|
        item.activated_by player
        false
      end

      @physics_time = 0.0 # The amount of time we have backlogged for physics.
    end
       
    def update      
      @frame_time = [Time.now.to_f - @time, 0.1].min
      @time = Time.now.to_f

      unless @paused
        @player.reset_forces
        #@objects.each {|o| o.reset_forces }

        @physics_time += frame_time
        num_steps = (@physics_time / PHYSICS_STEP).round
        @physics_time -= num_steps * PHYSICS_STEP
        num_steps.times { @space.step PHYSICS_STEP }

        @map.update # Clear lighting.
        @player.update
        @objects.each {|o| o.update }

        super
      end
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

      if holding? :tab
        draw_map_overlay
        @paused = true
      else
        @paused = false
      end

      player.draw_gui

      cursor_color = player.fire_primary? ?  Color.rgba(255, 0, 255, 150) : Color.rgba(100, 0, 100, 100)
      pixel.draw_rot $window.mouse_x, $window.mouse_y, ZOrder::CURSOR, 0, 0.5, 0.5, 8, 8, cursor_color

      super    
    end

    def draw_map_overlay
      $window.flush
      
      pixel.draw 0, 0, 0, $window.width, $window.height, Color.rgba(0, 0, 0, 150)
      
      $window.scale Map::MINI_SCALE do         
        $window.translate ($window.width / Map::MINI_SCALE) * 0.5 - (@map.width / 2),
                          ($window.height / Map::MINI_SCALE) * 0.5 - (@map.height / 2) do
                          
          pixel.draw -Tile::WIDTH, -Tile::WIDTH, 0, @map.width + Tile::WIDTH, @map.height + Tile::WIDTH, Color.rgb(150, 150, 150)
          
          @map.draw_mini 
          @objects.each {|o| o.draw_mini }
          @player.draw_mini
        end
      end
    end
  end
end