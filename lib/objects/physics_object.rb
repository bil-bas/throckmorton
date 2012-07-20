module Game
  class PhysicsObject < Chingu::GameObject
    extend Forwardable

    def_delegators :"@body.pos", :x, :y, :x=, :y=
    def_delegators :"@body", :reset_forces

    MARGIN = 2

    class << self
      attr_accessor :next_id
    end
    self.next_id = 0

    attr_reader :speed, :id, :body, :shape
    attr_accessor :velocity_x, :velocity_y

    def needs_sync?; true; end
    def time; parent.time; end
    def frame_time; parent.frame_time; end
    def exists?; !destroyed? end
    def destroyed?; !@shape.object end
    def tile; parent.map.tile_at_coordinate x, y end
    def id_string; id ? "##{id}" : "" end

    def initialize(options = {})
      options = {
          rotation_center: :center_center,
      }.merge! options

      @velocity_x, @velocity_y = 0, 0 # TODO: Use these!

      @speed = options[:speed]

      @id = PhysicsObject.next_id
      PhysicsObject.next_id += 1

      @body = CP::Body.new(1000, Float::INFINITY)

      super options

      init_physics options
    end

    def init_physics(options)
      # rectangular
      #vertices = [CP::Vec2.new(-width / 2 - MARGIN, -height / 2 - MARGIN),
      #            CP::Vec2.new(-width / 2 - MARGIN, height / 2 + MARGIN),
      #            CP::Vec2.new(width / 2 + MARGIN, height / 2 + MARGIN),
      #            CP::Vec2.new(width / 2 + MARGIN, -height / 2 - MARGIN)]
      #@shape = CP::Shape::Poly.new(@body, vertices, CP::Vec2.new(0, 0))

      @shape = CP::Shape::Circle.new(@body,
                                     scale * options[:width] + MARGIN,
                                     CP::Vec2.new(0, 0))

      @shape.collision_type = options[:collision_type]
      @shape.group = options[:group] if options.has_key? :group
      @shape.object = self

      parent.space.add_body @body
      parent.space.add_shape @shape
    end

    def move(right, down)
      push(x + right, y + down, speed)
    end

    def draw
      @image.draw_rot x, y, zorder, angle, 0.5, 0.5
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

      Messages::Destroy.broadcast(self) if parent.server?

      debug { "Destroyed #{short_name} at #{tile.grid_position}" }
    end

    def draw_physics
      width, height = shape.bb.r - shape.bb.l, shape.bb.t - shape.bb.b

      case shape
        when CP::Shape::Circle
          $window.physics_circle.draw_rot x, y, ZOrder::PHYSICS, 0, 0.5, 0.5,
                                          width / 32.0, height / 32.0
        when CP::Shape::Poly
          $window.physics_rect.draw_rot x, y, ZOrder::PHYSICS, 0, 0.5, 0.5,
                                        width / 32.0, height / 32.0
      end
    end

    def draw_name
      Font[6].draw_rel short_name[/[^:]+$/], x, y,
                       ZOrder::PHYSICS, 0.5, 0.5
    end
  end
end