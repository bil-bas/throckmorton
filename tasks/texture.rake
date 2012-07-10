require_relative "../lib/map/textures"

desc "Generate all textures"
task texture: Game::Textures::TYPES.map {|t| :"texture:#{t}" }

Game::Textures::TYPES.each do |type|
  task :"texture:#{type}" do
    require 'perlin'
    require 'texplay'

    mkdir_p "textures"

    $window ||= Gosu::Window.new 10, 10, false

    render_and_save type
  end
end

def render_and_save(type)
  texture = Game::Textures::const_get type.to_s.split("_").map(&:capitalize).join

  print "Generating #{type} texture..."
  t = Time.now

  gen = texture.new rand 1..10000

  images = gen.num_frames.times.map do
    Image.create 200, 200
  end

  gen.render images, 0, 0, images[0].width, images[0].height
  images.each_with_index do |image, i|
    image.force_sync [0, 0, image.width, image.height]
    image.save "textures/#{type}_#{i}.png"
  end

  puts "Image created in #{Time.now - t}s"
end



