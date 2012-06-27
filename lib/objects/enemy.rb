module Game
  class Enemy < PhysicsObject
    DIAGONAL = 0.785
    WIDTH = 9
    SHOOT_OFFSET = 7

    include LineOfSight
    attr_reader :health

    def initialize(x, y)
      @speed = 50
      @facing_x, @facing_y = 1, 0

      image = TexPlay.create_image $window, WIDTH, WIDTH
      image.circle WIDTH / 2, WIDTH / 2, WIDTH / 2, color: :red, fill: true

      @archer = rand(100) < 20
      if @archer
        image.set_pixel WIDTH / 2, WIDTH / 2
        scale = 0.75 # goblin archer?
        @health = 1
      else
        scale = [0.9, 0.9, 0.9, 1.2].sample # orcs and ogre?
        @health = scale > 1 ? 4 : 2
      end

      super x: x, y: y, scale: scale,
            image: image, zorder: ZOrder::ENEMY,
            collision_type: :enemy
    end

    def health=(value)
      @health = [value, 0].max
      destroy if @health <= 0
      @health
    end

    def update
      reset_forces
      push parent.player.x, parent.player.y, (@archer ? 3 : 5)

      if @archer and rand(100) == 0 and line_of_sight?(parent.player.tile)
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
      if tile and tile.seen? and parent.player.can_see? tile
        @image.draw_rot x, y, zorder, angle, 0.5, 0.5, scale, scale
      end
    end

    def draw_mini
      tile = self.tile
      if tile and tile.seen?
        parent.pixel.draw_rot x.round, y.round, zorder, 0, 0.5, 0.5, 10 * scale, 10 * scale, Color.rgb(255, 0, 0)
      end
    end
  end
end