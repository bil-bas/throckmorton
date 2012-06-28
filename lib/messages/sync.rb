require_relative 'message'

module Game
  class Messages::Sync < Messages::Message
    class << self
      def process(state, *data)
        data.each do |datum|
          object = state.map.find_object datum[0]
          object.x, object.y = datum[1], datum[2]
          object.velocity_x, object.velocity_y = datum[3], datum[4]
        end
      end

      protected
      def create_data(objects)
        objects.map do |object|
          [
              object.id,
              object.x.to_i,
              object.y.to_i,
              object.velocity_x.to_i,
              object.velocity_y.to_i,
          ]
        end
      end
    end
  end
  end

