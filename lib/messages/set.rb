require_relative 'message'

module Game
  class Messages::Set < Messages::Message
    VALUES = Set.new [:health, :energy]

    class << self
      def process(state, id, attribute, value)
        if VALUES.include? attribute.to_sym
          state.map.find_object(id).send("#{attribute}=", value)
        else
          error { "Server tried to set illegal attribute, #{attribute} on object##{id}" }
        end
      end

      protected
      def create_data(object, attribute, value)
        raise "Tried to set illegal attribute #{attribute} on #{object.short_name}" unless VALUES.include? attribute

        [
            object.id,
            attribute,
            value,
        ]
      end
    end
  end
end