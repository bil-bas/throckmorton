module Game
  class PhysicsObject < Chingu::GameObject
    extend Forwardable

    def_delegators :"@body.pos", :x, :y, :x=, :y=
    def_delegators :"@body", :reset_forces

    attr_reader :speed

    def exists?; !destroyed?; end
    def destroyed?; !@shape.object; end

    def initialize(options = {})
      @body = CP::Body.new(1000, Float::INFINITY)

      super options

      init_physics options
    end

    def init_physics(options)
      vertices = [CP::Vec2.new(-width / 2, -height / 2), CP::Vec2.new(-width / 2, height / 2), CP::Vec2.new(width / 2, height / 2), CP::Vec2.new(width / 2, -height / 2)]
      @shape = CP::Shape::Poly.new(@body, vertices, CP::Vec2.new(0, 0))
      @shape.collision_type = options[:collision_type]
      @shape.group = options[:group] if options.has_key? :group
      @shape.object = self

      parent.space.add_body @body
      parent.space.add_shape @shape
    end

    def move(right, down)
      push(x + right, y + down, speed)
    end

    # Push towards a particular position (negative force to pull).
    def push(x, y, push_force)
      angle = Gosu::angle(self.x, self.y, x, y)
      distance = distance(self.x, self.y, x, y)
      x_offset = offset_x(angle, distance)
      y_offset = offset_y(angle, distance)

      @body.apply_force(CP::Vec2.new((x_offset / distance) * push_force * 20000, (y_offset / distance) * push_force * 20000),
                              CP::Vec2.new(0, 0))
    end

    def destroy
      parent.remove_object self

      parent.space.remove_body @body
      parent.space.remove_shape @shape

      @shape.object = nil

      super
    end
  end
end