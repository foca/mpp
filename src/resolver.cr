require "./path"

class Resolver
  class NotFound < Errno
    def initialize(path, search_paths)
      super("Can't find `#{path}` in `#{search_paths}`")
    end
  end

  @search_paths = [] of String
  @cache = Hash(String, Path).new

  getter :search_paths

  def resolve(path : String)
    @cache[path] ||= find(path)
  end

  def add(*paths : String)
    add(paths.to_a)
  end

  def add(paths : Array(String))
    paths.each do |path|
      Dir.glob(path) do |dir|
        @search_paths << File.expand_path(dir) if File.directory?(dir)
      end
    end
  end

  private def find(path)
    search_paths.each do |prefix|
      file_path = File.join(prefix, path)
      return Path.new(file_path, path) if File.file?(file_path)
    end

    raise NotFound.new(path, search_paths)
  end
end
