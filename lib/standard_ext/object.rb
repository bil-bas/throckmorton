class Object
  # Set up logging
  class << self
    def logger(source = nil)
      source = "-" if source == "Object"

      unless @loggers.has_key? source
        @loggers[source] = Log4r::Logger.new source
        @loggers[source].outputters << @std_outputter if @std_outputter
        @loggers[source].outputters << @file_outputter if @file_outputter
      end

      @loggers[source]
    end

    def init_logging
      @loggers = {}
      formatter = Log4r::PatternFormatter.new pattern: "%6l %d [%C] %m"

      # Don't echo to screen if running from an executable.
      unless defined? OCRA_EXECUTABLE
        @std_outputter = Log4r::Outputter.stdout
        @std_outputter.formatter = formatter
      end

      @file_outputter = Log4r::FileOutputter.new 'game_log', filename:  'game.log'
      @file_outputter.formatter = formatter
    end
  end

  init_logging

  # Call #debug, #info, #warn, #error on any object to log a message.
  [:debug, :info, :warn, :error, :fatal].each do |level|
    define_method level do |*args, &block|
      Object.logger(self.class.name).send(level, *args, &block)
    end
  end
end