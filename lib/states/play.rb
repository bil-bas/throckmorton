module Game
  class Play < Chingu::GameState
    attr_reader :time, :frame_time
    attr_reader :pixel
    attr_reader :world_scale
    attr_reader :space
    attr_reader :map

    PHYSICS_STEP = 0.00001 # Just to force collisions.
    MAP_MARGIN = 32

    def server?; true end #@server end
    def client?; true end #!@server end
    def player; @map.player end
       
    def initialize(scale)
      super

      init_physics
      
      @time = Time.now.to_f
      @server = true

      PhysicsObject.reset_ids

      @world_scale = scale.to_f

      seed = 1000 # TODO: enter this on the command line or randomise on default.

      @map = Map.new seed
      @map.generate if server?

      if client?
        @pixel = Image.create 1, 1, color: :white

        on_input :escape do
          pop_game_state
          push_game_state self.class.new(scale)
        end

        @camera_x, @camera_y = 0, 0
      end

      Messages::Message.parent = self

      update # Ensure that everything is in the right place before the first draw.
    end

    def init_physics
      # Set up Chipmunk physics.
      @space = CP::Space.new
      @space.damping = 0.05

      @space.on_collision(:player, :enemy) do |player, enemy|
        if server?
          damage = rand enemy.melee_damage
          debug { "Player took #{damage} damage from meleeing with #{enemy.short_name}" }
          player.health -= damage
          Sample["player_meleed.ogg"].play 0.7
          enemy.destroy
        end
        false
      end

      @space.on_collision(:player, :enemy_projectile) do |player, projectile|
        if server?
          damage = rand projectile.damage
          debug { "Player took #{damage} damage from a projectile" }
          player.health -= damage
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
        player.body.vel *= 0.97
        if server?
          player.health -= 0.2
        end
        false
      end

      # fire_beetle doesn't care about lava and just runs through!
      @space.on_collision(:enemy, :lava) do |entity, lava|
        entity.type != :lava_beetle
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
        player.body.vel *= 0.98
        false
      end

      @space.on_collision([:player_projectile, :enemy_projectile], :water) do |entity, water|
        false
      end

      # Ticks are afraid of the water, but can pass though small places.
      @space.on_collision(:enemy, :water) do |entity, water|
        case entity.type
          when :skitter
            true # Can't enter
          when :spawn
            false # Good swimmers.
          when :lava_beetle
            entity.body.vel *= 0.92 # Very bad swimmers.
            false
          else
            entity.body.vel *= 0.98 # Bad swimmers.
            false
        end
      end

      @space.on_collision(:enemy, :obstacle) do |entity, water|
        entity.type != :skitter
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
    end
       
    def update      
      @frame_time = [Time.now.to_f - @time, 0.1].min
      @time = Time.now.to_f

      unless @paused
        @space.step PHYSICS_STEP

        @map.update # Will move the player.

        # Offset to the center of the screen.
        @camera_x = (@map.player.x - ($window.width / (world_scale * 2.0)))
        @camera_y = (@map.player.y - ($window.height / (world_scale * 2.0)))

        if client?
          @map.lighting.camera_x, @map.lighting.camera_y = @camera_x / world_scale, @camera_y / world_scale
          #@map.lighting.update_shadow_casters do
          #  @map.draw_shadow_casters
          #end

          #@map.lighting.each do |light|
          #  light.send :save_buffers
          #  exit
          #end
        end

        super
      end
    end

    def draw
      if client?
        $window.scale world_scale do
          $window.translate -@camera_x, -@camera_y do
            @map.draw
          end
        end

        if holding? :tab
          @paused = true

          # Draw a shaded background.
          pixel.draw 0, 0, Float::INFINITY, $window.width, $window.height, Color.rgba(0, 0, 0, 150)

          draw_map_overlay
        else
          @paused = false

          $window.scale 0.25 do
            draw_map_overlay
          end
        end

        player.draw_gui

        # Debug info.
        objects = map.objects
        num_mobs = objects.count {|o| o.is_a? Enemy }
        info =  "Objects: #{objects.size - num_mobs} Mobs: #{num_mobs} -- FPS: #{$window.fps.round} [#{$window.potential_fps.round}]  "
        Font[24].draw_rel info, $window.width, 0, 0, 1, 0

        cursor_color = Color.rgba 255, 0, 255, 150
        pixel.draw_rot $window.mouse_x, $window.mouse_y, ZOrder::CURSOR, 45, 0.5, 0.5, 16, 16, cursor_color
        pixel.draw_rot $window.mouse_x, $window.mouse_y, ZOrder::CURSOR, 0, 0.5, 0.5, 3, 3, Color::BLACK

        super
      end
    end

    def draw_map_overlay
      $window.flush

      $window.scale Map::MINI_SCALE do
        $window.translate ($window.width / Map::MINI_SCALE) * 0.5 - (@map.width / 2),
                          ($window.height / Map::MINI_SCALE) * 0.5 - (@map.height / 2) do
                          
          pixel.draw -MAP_MARGIN, -MAP_MARGIN, 0, @map.width + MAP_MARGIN * 2, @map.height + MAP_MARGIN * 2, Color.rgb(150, 150, 150)

          @map.draw_mini

          screen_outline_color = Color.rgba 200, 200, 0, 100

          [
              [@camera_x, @camera_y],
              [@camera_x + $window.width / @map.scale, @camera_y],
              [@camera_x + $window.width / @map.scale, @camera_y + $window.height / @map.scale],
              [@camera_x, @camera_y + $window.height / @map.scale],
              [@camera_x, @camera_y],
          ].each_cons(2) do |(x1, y1), (x2, y2)|
            $window.draw_line x1, y1, screen_outline_color,
                              x2, y2, screen_outline_color,
                              0
          end

          $window.translate @camera_x / 2, @camera_y / 2 do
            #@map.lighting.draw
          end
        end
      end
    end
  end
end