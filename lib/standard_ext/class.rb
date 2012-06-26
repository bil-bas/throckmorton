class Class
  def cattr_reader(*cvs)
    cvs.each do |cv|
      class_eval %Q[
        class << self
          attr_reader #{cv.inspect}
        end
        def #{cv}
          self.class.#{cv}
        end
      ]
    end
  end

  def cattr_writer(*cvs)
    cvs.each do |cv|
      class_eval %Q[
        class << self
          attr_writer #{cv.inspect}
        end
        def #{cv}=(value)
          self.class.#{cv} = value
        end
      ]
    end
  end

  def cattr_accessor(*cvs)
    cattr_reader *cvs
    cattr_writer *cvs
  end
end

