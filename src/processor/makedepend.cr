require "../processor"

class Processor::MakeDepend < Processor
  @@current_dir : String = Dir.current + "/"

  def initialize
    @dependencies = Hash(String, Array(String)).new do |hash, path|
      hash[path] = Array(String).new
    end
  end

  def on_include(template_path, included_path)
    template_path = template_path.sub(@@current_dir, "")
    included_path = included_path.sub(@@current_dir, "")
    @dependencies[template_path] << included_path
  end

  def to_s
    rules = @dependencies.select { |_, deps| deps.any? }.map do |file, deps|
      "%s: %s\n\t@touch $@" % [file, deps.join(" ")]
    end

    rules << "" if rules.any?

    rules.join("\n\n")
  end
end
