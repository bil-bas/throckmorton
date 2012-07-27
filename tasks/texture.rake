require_relative "../lib/main"

include Game::Mixins::Shaders

desc "Generate all textures"
task texture: Game::Textures::TYPES.map {|t| :"texture:#{t}" }

Game::Textures::TYPES.each do |type|
  task :"texture:#{type}" do
    mkdir_p "textures"

    $window ||= Gosu::Window.new 800, 800, false

    render_and_save type
  end
end

def render_and_save(type)
  texture = Game::Textures::const_get type.to_s.split("_").map(&:capitalize).join

  print "Generating #{type} texture..."
  t = Time.now

  terrain_shader = Ashton::Shader.new fragment: fragment_shader("terrain"), uniforms: {
      cavern_floor: Game::Textures::CavernFloor.color,
      cavern_wall: Game::Textures::CavernWall.color,
      water: Game::Textures::Water.color,
      lava: Game::Textures::Lava.color,
      seed: 1000,
  }

  buffer_base = Ashton::Texture.new 800, 800
  buffer_out = Ashton::Texture.new 800, 800

  buffer_base.clear color: texture.color

  terrain_shader.use do
    buffer_out.render do
      buffer_base.draw 0, 0, 0
    end
  end

  buffer_out.to_image.save "textures/#{type}.png"

  puts "Image created in #{Time.now - t}s"
end

desc "Create a map layout"
task :map do
  $window ||= Gosu::Window.new 800, 800, false

  print "Generating base map texture..."
  t = Time.now
  size = [800.0, 800.0]
  seed = 100

  map_shader = Ashton::Shader.new fragment: fragment_shader("map"), uniforms: {
      cavern_floor: Game::Textures::CavernFloor.color,
      cavern_wall: Game::Textures::CavernWall.color,
      #lava: Game::Textures::Lava.color,
      seed: seed,
      texture_size: size,
      margin: 32,
  }

  terrain_shader = Ashton::Shader.new fragment: fragment_shader("terrain"), uniforms: {
      cavern_floor: Game::Textures::CavernFloor.color,
      cavern_wall: Game::Textures::CavernWall.color,
      lava: Game::Textures::Lava.color,
      seed: seed,
  }

  buffer_base = Ashton::Texture.new *size
  buffer_out = Ashton::Texture.new *size

  map_shader.use do
    buffer_out.render do
      buffer_base.draw 0, 0, 0
    end
  end

  buffer_out.to_image.save "textures/map.png"
  buffer_out, buffer_base = buffer_base, buffer_out

  terrain_shader.use do
    buffer_out.render do
      buffer_base.draw 0, 0, 0
    end
  end

  buffer_out.to_image.save "textures/map_with_terrain.png"

  puts "Image created in #{Time.now - t}s"
end



