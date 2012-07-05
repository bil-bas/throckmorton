module Game
  class SpriteSheet
    extend Forwardable

    def_delegators :@sprites, :map, :each

    class << self
      def [](file, width, height, tiles_wide = 0)
        @cached_sheets ||= Hash.new do |h, k|
           h[k] = new(*k)
        end
        @cached_sheets[[file, width, height, tiles_wide]]
      end
    end

    def initialize(file, width, height, tiles_wide = 0)
      @sprites = Image.load_tiles($window, File.expand_path(file, Image.autoload_dirs[0]), width, height, false)
      @tiles_wide = tiles_wide
    end

    def [](x, y = 0)
      @sprites[y * @tiles_wide + x]
    end

    def map!
      raise unless block_given?

      @sprites.map! {|s| yield s }

      nil
    end

    def map(&block)
      raise unless block_given?
      copy = dup
      copy.instance_variable_set :@sprites, @sprites.dup
      copy.map! &block
      copy
    end
  end
end