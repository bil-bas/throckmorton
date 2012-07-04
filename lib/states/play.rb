module Game
  class Play < Chingu::GameState
    attr_reader :time, :frame_time
    attr_reader :pixel
    attr_reader :world_scale
    attr_reader :space
    attr_reader :map, :player, :objects

    PHYSICS_STEP = 1 / 60.0

    def server?; true end #@server end
    def client?; true end #!@server; end
       
    def initialize(scale)
      super

      init_physics
      
      @time = Time.now.to_f
      @server = true

      @objects = []
      @world_scale = scale

      seed = 1000 # TODO: enter this on the command line or randomise on default.

      @map = Map.new seed
      if server?
        @map.generate
        @player = Player.new @map.width / 2, @map.height / 2
      end

      if client?
        @pixel = TexPlay.create_image $window, 1, 1, color: :white

        on_input :escape do
          pop_game_state
          push_game_state self.class.new(scale)
        end
      end

      Messages::Message.parent = self
    end

    def init_physics
      # Set up Chipmunk physics.
      @space = CP::Space.new
      @space.damping = 0.05

      @space.on_collision(:player, :enemy) do |player, enemy|
        if server?
          player.health -= rand enemy.damage
          enemy.destroy
        end
        false
      end

      @space.on_collision(:player, :enemy_projectile) do |player, projectile|
        if server?
          player.health -= rand projectile.damage
          projectile.destroy
        end
        false
      end

      @space.on_collision(:enemy, :player_projectile) do |enemy, projectile|
        if server?
          enemy.health -= rand projectile.damage
          projectile.destroy
        end
        false
      end

      # Lava hurts you, but enemies just stand at the edge :)
      @space.on_collision(:player, :lava) do |player, lava|
        player.body.vel *= 0.96
        if server?
          player.health -= 0.2
        end
        false
      end

      # fire_beetle doesn't care about lava and just runs through!
      @space.on_collision(:enemy, :lava) do |entity, lava|
        entity.type != :fire_beetle
      end

      # No friendly fire.
      @space.on_collision(:enemy, :enemy_projectile) do
        false
      end
      @space.on_collision(:player, :player_projectile) do
        false
      end

      # Can fire over obstacles & lava (but can't walk through them).
      @space.on_collision([:player_projectile, :enemy_projectile], [:obstacle, :lava]) do
        false
      end

      # Most things can move through water happily.
      @space.on_collision(:player, :water) do |entity, water|
        player.body.vel *= 0.96
        false
      end

      @space.on_collision([:player_projectile, :enemy_projectile], :water) do |entity, water|
        false
      end

      # Ticks are afraid of the water, but can pass though small places.
      @space.on_collision(:enemy, :water) do |entity, water|
        case entity.type
          when :tick
            true # Can't enter
          when :goblin_archer
            false # Good swimmers.
          else
            entity.body.vel *= 0.98 # Bad swimmers.
            false
        end
      end

      @space.on_collision(:enemy, :obstacle) do |entity, water|
        entity.type != :tick
      end

      @space.on_collision(:player_projectile, :enemy_projectile) do |p1, p2|
        if server?
          p1.destroy
          p2.destroy
        end
        false
      end

      @space.on_collision(:player, :item) do |player, item|
        if server?
          item.activated_by player
        end
        false
      end

      @physics_time = 0.0 # The amount of time we have backlogged for physics.
    end
       
    def update      
      @frame_time = [Time.now.to_f - @time, 0.1].min
      @time = Time.now.to_f

      unless @paused
        @physics_time += frame_time
        num_steps = (@physics_time / PHYSICS_STEP).round
        @physics_time -= num_steps * PHYSICS_STEP
        num_steps.times { @space.step PHYSICS_STEP }

        @map.update # Clear lighting.
        @player.update
        @objects.each {|o| o.update }

        super

        if server?
          Messages::Sync.broadcast [@player] + @objects.reject {|o| o.needs_sync? }
        end
      end
    end
    
    def add_object(object)
      @objects << object
    end
    
    def remove_object(object)
      @objects.delete object
    end   

    def draw
      if client?
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
        pixel.draw_rot $window.mouse_x, $window.mouse_y, ZOrder::CURSOR, 45, 0.5, 0.5, 16, 16, cursor_color
        pixel.draw_rot $window.mouse_x, $window.mouse_y, ZOrder::CURSOR, 0, 0.5, 0.5, 3, 3, Color::BLACK

        super
      end
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