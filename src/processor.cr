abstract class Processor
  def on_line(line)
  end

  def on_include(template_path, included_path)
  end

  def on_define(name, replacement)
  end

  abstract def to_s : String
end
