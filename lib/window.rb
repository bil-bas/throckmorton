module Game
 class Window < Chingu::Window
    def initialize
      super 640, 480, false
      
      enable_undocumented_retrofication
      
      push_game_state Play
    end  
    

    def update
      self.caption = "#{current_game_state.class.name} FPS: #{fps}"
      super
    end
  end
end