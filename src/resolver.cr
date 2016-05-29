class Resolver
  class NotFound < Errno
    def initialize(path, search_paths)
      super("Can't find `#{path}` in `#{search_paths}`")
    end
  end

  @search_paths = [] of String
  @cache = Hash(String, String).new

  getter :search_paths

  def resolve(path)
    @cache[path] ||= find(path)
  end

  def add(*paths : String)
    add(paths.to_a)
  end

  def add(paths : Array(String))
    @search_paths.concat(paths.map { |path| File.expand_path(path) })
  end

  private def find(path)
    return path if path.starts_with?('/') && File.file?(path)

    search_paths.each do |prefix|
      file_path = File.join(prefix, path)
      return file_path if File.file?(file_path)
    end

    raise NotFound.new(path, search_paths)
  end
end
