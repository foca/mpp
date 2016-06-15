require "../processor"

class Processor::Output < Processor
  def initialize(@directives = Hash(String, String).new)
    @buffer = String::Builder.new
  end

  def on_define(key, val)
    @directives[key] = val
  end

  def on_line(line)
    @buffer << @directives.reduce(line) do |line, (key, val)|
      line.gsub(key, val)
    end
  end

  def to_s
    @buffer.to_s
  end
end
