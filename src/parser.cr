require "./resolver"

class Parser
  def initialize(@resolver : Resolver, @processor : Processor)
    @visited = Set(String).new
  end

  def process(paths : Array(String))
    paths.each { |path| process(path) }
  end

  def process(path : String)
    path = @resolver.resolve(path)

    return "" if @visited.includes?(path)
    @visited.add(path)

    File.each_line(path) do |line|
      case line.strip
      when /^#include\s+/
        file = line.strip.sub(/^#include\s+/, "").gsub(/"/, "").gsub(/'/, "")
        file = @resolver.resolve(file)
        @processor.on_include(path, file)
        process(file)
      when /^#define\s+/
        var, val = line.strip.sub(/^#define\s+/, "").split(/\s+/, 2)
        @processor.on_define(var, val)
      else
        @processor.on_line(line)
      end
    end
  rescue err : Resolver::NotFound
    abort err
  end

  def to_s
    @processor.to_s
  end
end
