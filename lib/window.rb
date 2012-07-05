module Game
 class Window < Chingu::Window
   attr_reader :potential_fps
   BASE_WIDTH = 800
   BASE_HEIGHT = 600

    def initialize(fullscreen)
      if fullscreen
        scale = screen_height.fdiv(BASE_HEIGHT)
        super screen_width, screen_height
      else
        scale = 1
        super (BASE_WIDTH * scale).to_i, (BASE_HEIGHT * scale).to_i, false
      end
      
      enable_undocumented_retrofication

      scale = (scale * 2).floor

      info { "Starting with rendering scale x#{scale}" }
      
      push_game_state Play.new(scale)
      
      init_fps

      self.caption = "Game of Scones (by Spooner) --- WASD or Arrows to move; Mouse to aim and fire; Hold TAB to view map; ESC to restart"
    end  
    

    def update
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