module Game
  class Enemy < Entity
    DIAGONAL = 0.785
    WIDTH = 17
    SHOOT_OFFSET = 14

    attr_reader :damage

    def initialize(x, y)
      @speed = 125
      @facing_x, @facing_y = 1, 0

      unless defined? @@image
        @@image = TexPlay.create_image $window, WIDTH, WIDTH
        @@image.circle WIDTH / 2, WIDTH / 2, WIDTH / 2, color: :red, fill: true
        @@image.set_pixel WIDTH / 2 - 1, 1
        @@image.set_pixel WIDTH / 2 + 1, 1
      end

      @archer = rand(100) < 20
      if @archer
        scale = 0.6 # goblin archer?
        health = 10
        @damage = 2
      else
        scale = [0.9, 0.9, 0.9, 1.2].sample # orcs and ogre?
        if scale > 1
          health =  40
          @damage = 10
        else
          health = 18
          @damage = 4
        end
      end

      super x: x, y: y, scale: scale, health: health,
            image: @@image, zorder: ZOrder::ENEMY,
            collision_type: :enemy
    end

    def update
      reset_forces
      push parent.player.x, parent.player.y, (@archer ? 3 : 5)
      self.angle = Gosu::angle(x, y, parent.player.x, parent.player.y)

      if @archer && rand(100) == 0 && line_of_sight?(parent.player.tile)
        angle = Gosu::angle(x, y, parent.player.x, parent.player.y)
        bullet = Projectile.new x + offset_x(angle, SHOOT_OFFSET),
                                y + offset_y(angle, SHOOT_OFFSET),
                                angle,
                                speed: 35,
                                collision_type: :enemy_projectile,
                                group: :enemy_projectiles,
                                duration: 0.5,
                                color: Color::BLACK
        parent.add_object bullet
      end

      super
    end

    def draw
      tile = self.tile
      if tile && tile.seen? && parent.player.can_see?(tile)
        @image.draw_rot x, y, zorder, angle, 0.5, 0.5, scale, scale
      end
    end

    def draw_mini
      tile = self.tile
      if tile && tile.seen?
        parent.pixel.draw_rot x.round, y.round, zorder, 0, 0.5, 0.5, 10 * scale, 10 * scale, Color.rgb(255, 0, 0)
      end
    end
  end
end