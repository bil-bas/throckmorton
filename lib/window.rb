module Game
 class Window < Chingu::Window
    def initialize
      super 640, 480, false
      
      enable_undocumented_retrofication
      
      push_game_state Play
      
      init_fps
      
    end  
    

    def update
      start_at = Time.now
            
      super
      
      @used_time += (Time.now - start_at).to_f
      recalculate_fps
      
      self.caption = "#{current_game_state.class.name} FPS: #{fps.round} [#{@potential_fps.round}]"
    end
    
    def draw
      start_at = Time.now
      
      super
      
      @used_time += (Time.now - start_at).to_f
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