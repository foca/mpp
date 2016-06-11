require "../spec_helper"
require "../../src/processor/makedepend"
require "../../src/path"

describe Processor::MakeDepend do
  it "tracks dependencies through #include macros" do
    processor = Processor::MakeDepend.new
    processor.on_include(Path.new("root.css"), Path.new("foo.css"))
    processor.on_include(Path.new("foo.css"), Path.new("bar.css"))
    processor.on_include(Path.new("root.css"), Path.new("bar.css"))
    processor.on_include(Path.new("root.css"), Path.new("baz.css"))

    processor.to_s.should eq <<-OUTPUT
      root.css: foo.css bar.css baz.css
      \t@touch $@

      foo.css: bar.css
      \t@touch $@


      OUTPUT
  end

  it "converts paths to be relative from the working directory" do
    make_path = ->(path : String) do
      Path.new(File.join(Dir.current, "css", path), File.join("css", path))
    end

    processor = Processor::MakeDepend.new
    processor.on_include(make_path.call("root.css"), make_path.call("foo.css"))

    processor.to_s.should eq <<-OUTPUT
      css/root.css: css/foo.css
      \t@touch $@


      OUTPUT
  end

  it "produces no output if no #include macros are encountered" do
    processor = Processor::MakeDepend.new
    processor.to_s.should eq("")
  end
end
