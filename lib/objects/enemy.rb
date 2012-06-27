module Game
  class Enemy < PhysicsObject
    DIAGONAL = 0.785
    WIDTH = 9
    SHOOT_OFFSET = 7

    def initialize(x, y)
      @speed = 50
      @facing_x, @facing_y = 1, 0

      image = TexPlay.create_image $window, WIDTH, WIDTH
      image.circle WIDTH / 2, WIDTH / 2, WIDTH / 2, color: :red, fill: true

      super x: x, y: y,
            image: image, zorder: ZOrder::ENEMY,
            collision_type: :enemy

      @archer = rand(100) < 20
      image.set_pixel WIDTH / 2, WIDTH / 2 if @archer
    end

    def update
      reset_forces
      push parent.player.x, parent.player.y, (@archer ? 3 : 5)

      if @archer and rand(100) == 0
        angle = Gosu::angle(x, y, parent.player.x, parent.player.y)
        bullet = Projectile.new x + offset_x(angle, SHOOT_OFFSET),
                                y + offset_y(angle, SHOOT_OFFSET),
                                angle,
                                collision_type: :enemy_projectile,
                                group: :enemy_projectiles,
                                duration: 0.5,
                                color: Color::BLACK
        parent.add_object bullet
      end

      super
    end

    def draw_mini
      tile = self.tile
      if tile and tile.seen?
        parent.pixel.draw_rot x.round, y.round, zorder, 0, 0.5, 0.5, 14, 14, Color.rgb(255, 0, 0)
      end
    end
  end
end