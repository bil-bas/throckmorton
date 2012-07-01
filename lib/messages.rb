module Game
  module Messages
  end

  %w{create_enemy create_item create_map destroy set sync}.each do |message|
    require_relative "messages/#{message}"

    # Make sure the eiginclass knows the name of the class.
    # TODO: use a numeric ID instead.
    Messages.const_get(Inflector.camelize(message)).identifier = Inflector.camelize(message)
  end
end
