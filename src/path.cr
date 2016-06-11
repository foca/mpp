class Path
  getter :absolute
  getter :relative

  def initialize(@absolute : String, @relative : String)
  end

  def initialize(absolute)
    initialize(absolute, absolute)
  end

  def ==(other)
    absolute == other.absolute && relative == other.relative
  end

  def to_s(io)
    @relative.to_s(io)
  end
end
