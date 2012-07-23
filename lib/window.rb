module Game
  class Window < Chingu::Window
    attr_reader :potential_fps, :physics_circle, :physics_rect
    BASE_WIDTH = 800
    BASE_HEIGHT = 600
    PHYSICS_COLOR = Color.rgba 255, 255, 0, 128 # For debug.

    def debugging?; @debugging end
   
    def initialize(fullscreen, debugging)
      if fullscreen
        scale = screen_height.fdiv BASE_HEIGHT
        super screen_width, screen_height
      else
        scale = 1
        super (BASE_WIDTH * scale).to_i, (BASE_HEIGHT * scale).to_i, false
      end

      enable_undocumented_retrofication

      @debugging = debugging
      if debugging?
        @physics_circle = Image.create 32, 32, color: :alpha
        @physics_circle.circle 15, 15, 15.5, color: PHYSICS_COLOR
        @physics_rect = Image.create 32, 32, color: :alpha
        @physics_rect.rect 0, 0, 31, 31, color: PHYSICS_COLOR
      end

      scale = (scale * 2).floor

      info { "Starting with rendering scale x#{scale}" }

      # Pre-load sound effects.
      Dir[File.expand_path("../../lib/sounds/*.ogg", __FILE__)].each do |sample|
        Sample[sample]
      end
      
      push_game_state Play.new(scale)
      
      init_fps

      self.caption = "Throckmorton (by Spooner) --- WASD or Arrows to move; Mouse to aim and fire; Hold TAB to view map; ESC to restart"
    end  
    

    def update
      $gosu_blocks.clear # Workaround for Gosu bug.

      start_at = Time.now
           
      super
      
      @used_time += (Time.now - start_at).to_f
      recalculate_fps

    rescue => ex
      fatal { "#{ex.class}: #{ex}\n#{ex.backtrace.join("\n")}" }
      exit
    end
    
    def draw
      start_at = Time.now
      
      super
      
      @used_time += (Time.now - start_at).to_f

    rescue => ex
      fatal { "#{ex.class}: #{ex}\n#{ex.backtrace.join("\n")}" }
      exit
    end
    
    def init_fps
      @fps_next_calculated_at = Time.now.to_f + 1
      @fps = @potential_fps = 0
      @num_frames = 0
      @used_time = 0
    end

    def recalculate_fps
      @num_frames += 1

      if Time.now.to_f >= @fps_next_calculated_at
       elapsed_time = @fps_next_calculated_at - Time.now.to_f + 1
       @fps = @num_frames / elapsed_time
       @potential_fps = @num_frames / [@used_time, 0.0001].max

       @num_frames = 0
       @fps_next_calculated_at = Time.now.to_f + 1
       @used_time = 0
      end
    end
  end
end