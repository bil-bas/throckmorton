require_relative "../lib/map/textures"

desc "Generate all textures"
task texture: Game::Textures::TYPES.map {|t| :"texture:#{t}" }

Game::Textures::TYPES.each do |type|
  task :"texture:#{type}" do
    require 'perlin'
    require 'texplay'

    mkdir_p "textures"

    $window ||= Gosu::Window.new(1022, 1022, false)

    render_and_save type
  end
end

def render_and_save(type)
  texture = Game::Textures::const_get type.to_s.split("_").map(&:capitalize).join

  print "Generating #{type} texture..."
  t = Time.now

  texture::FRAMES.times.map do |time|
    image = TexPlay.create_image $window, 200, 200
    gen = texture.new
    gen.render image, 0, 0, image.width, image.height

    image.save "textures/#{type}_#{time}.png"
  end

  puts "Image created in #{Time.now - t}s"
end



