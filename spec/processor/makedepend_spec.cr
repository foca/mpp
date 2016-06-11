require "../spec_helper"
require "../../src/processor/makedepend"

describe Processor::MakeDepend do
  it "tracks dependencies through #include macros" do
    processor = Processor::MakeDepend.new
    processor.on_include("root.css", "foo.css")
    processor.on_include("foo.css", "bar.css")
    processor.on_include("root.css", "bar.css")
    processor.on_include("root.css", "baz.css")

    processor.to_s.should eq <<-OUTPUT
      root.css: foo.css bar.css baz.css
      \t@touch $@

      foo.css: bar.css
      \t@touch $@


      OUTPUT
  end

  it "converts paths to be relative from the working directory" do
    prefix = ->(path : String) { File.join(Dir.current, "css", path) }

    processor = Processor::MakeDepend.new
    processor.on_include(prefix.call("root.css"), prefix.call("foo.css"))

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
