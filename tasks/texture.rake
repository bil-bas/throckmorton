desc "Generate all textures"
task texture: [:texture_floor, :texture_lava, :texture_wall, :texture_water]


[:floor, :wall, :water, :lava].each do |type|
  task :"texture_#{type}" do
    TextureGen.new type
  end
end


class TextureGen
  DIR = "media/images/textures"
  WIDTH, HEIGHT = 200, 200
  FRAMES = 5

  def initialize(type)
    require 'perlin'
    require 'texplay'

    $window ||= Gosu::Window.new(10, 10, false)

    print "Generating #{type} texture..."
    t = Time.now

    image = TexPlay.create_image $window, WIDTH, HEIGHT
    send type, image

    puts "completed in #{Time.now - t}s"
  end

  def floor(image)
    midi = Perlin::Generator.new 128, 0.5, 1
    midi_noise = midi.chunk 0, 0, WIDTH, HEIGHT, 0.03
    macro = Perlin::Generator.new 35, 0.5, 1
    macro_noise = macro.chunk 0, 0, WIDTH, HEIGHT, 0.007
    micro = Perlin::Generator.new 145, 0.5, 1
    micro_noise = micro.chunk 0, 0, WIDTH, HEIGHT, 0.5

    moss = Perlin::Generator.new 123, 0.5, 1
    moss_noise = moss.chunk 0, 0, WIDTH, HEIGHT, 0.05

    image.clear color: Gosu::Color.rgb(60, 80, 100)
    image.clear color_control: lambda {|color, x, y|
      color = color[0..2].map do |c|
        c + micro_noise[x][y] * 0.03 +
            midi_noise[x][y] * 0.04 * -macro_noise[x][y] +
            macro_noise[x][y] * 0.05
      end
      if moss_noise[x][y] < macro_noise[x][y] - 0.4
        color[1] -= moss_noise[x][y] * 0.1
      end
      color
    }
    image.save File.expand_path("floor_0.png", DIR)
  end

  def wall(image)
    generator = Perlin::Generator.new 12, 1, 2
    noise = generator.chunk 0, 0, WIDTH, HEIGHT, 2

    image.clear color: Gosu::Color.rgb(60, 30, 10)
    image.clear color_control: lambda {|c, x, y|
      c[0..2].map {|c| c + noise[x][y] * 0.04 }
    }
    image.save File.expand_path("wall_0.png", DIR)
  end

  def water(image)
    generator = Perlin::Generator.new 99, 1, 1

    FRAMES.times do |time|
      noise = generator.chunk 0, 0, time * 0.1, WIDTH, HEIGHT, 1, 0.2
      image.clear color: Gosu::Color.rgb(0, 60, 90)
      image.clear color_control: lambda {|color, x, y|
        color = color[0..2].map {|c| c + noise[x][y][0] * 0.02 }
        color
      }
      image.save File.expand_path("water_#{time}.png", DIR)
    end
  end

  def lava(image)
    lava = Perlin::Generator.new 34525, 0.4, 1
    crust = Perlin::Generator.new 123, 0.8, 4
    crust_noise = crust.chunk 0, 0, WIDTH, HEIGHT, 0.2

    FRAMES.times do |time|
      lava_noise = lava.chunk 0, 0, time * 0.1, WIDTH, HEIGHT, 1, 0.2
      image.clear color: Gosu::Color.rgb(200, 25, 0)
      image.clear color_control: lambda {|c, x, y|
        if crust_noise[x][y] > 0.15
          height = 0.2 - crust_noise[x][y] * 0.3
          [height, height / 2, height / 4, 1]
        else
          height = lava_noise[x][y][0]
          [c[0] - height * 0.1, c[1] - height * 0.2, c[2] + height * 0.02, 1] # Glow from below.
        end
      }

      image.save File.expand_path("lava_#{time}.png", DIR)
    end
  end
end
