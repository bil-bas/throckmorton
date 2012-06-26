module Chingu
  class GameObject
    def draw
      @image.draw_rot(x, y, @zorder, angle, @center_x, @center_y, @factor_x, @factor_y, @color, @mode)  if @image
    end
  end
end