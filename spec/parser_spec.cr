require "./spec_helper"
require "../src/parser"
require "../src/processor/output"

class TestProcessor < Processor
  getter :lines
  getter :includes
  getter :defines

  def initialize
    @lines = Array(String).new
    @includes = Hash(String, Array(String)).new do |hash, path|
      hash[path] = [] of String
    end
    @defines = Hash(String, String).new
  end

  def on_line(line)
    @lines << line
  end

  def on_include(parent, child)
    @includes[parent.to_s] << child.to_s
  end

  def on_define(key, val)
    @defines[key] = val
  end

  def to_s
    ""
  end
end

describe Parser do
  project_dir = File.expand_path(File.join(__FILE__, "../.."))

  resolver = Resolver.new
  resolver.add(File.join(project_dir, "example/assets/css"))

  it "processes a simple file with no directives" do
    processor = TestProcessor.new

    parser = Parser.new(resolver, processor)
    parser.process("qux.css")

    processor.lines.should eq([".qux {", "  color: $color;", "}"])
    processor.includes.should eq(Hash(String, Array(String)).new)
    processor.defines.should eq(Hash(String, String).new)
  end

  it "proceses a file with an #include directive" do
    processor = TestProcessor.new

    parser = Parser.new(resolver, processor)
    parser.process("baz.css")

    processor.lines.should eq([
      ".qux {",
      "  color: $color;",
      "}",
      "",
      ".baz {",
      "  color: $color;",
      "}"
    ])
    processor.includes.should eq({ "baz.css" => ["qux.css"] })
    processor.defines.should eq(Hash(String, String).new)
  end

  it "processes a file with a #define directive" do
    processor = TestProcessor.new

    parser = Parser.new(resolver, processor)
    parser.process("variables.css")

    processor.lines.should eq([] of String)
    processor.includes.should eq(Hash(String, Array(String)).new)
    processor.defines.should eq({ "$color" => "\"red\"" })
  end

  it "processes a complex file with multiple recursive #includes and #defines" do
    processor = TestProcessor.new

    parser = Parser.new(resolver, processor)
    parser.process("root.css")

    processor.lines.should eq([
      ".qux {",
      "  color: $color;",
      "}",
      "",
      ".baz {",
      "  color: $color;",
      "}",
      "",
      ".foo {",
      "  color: $color;",
      "}",
      "",
      ".bar {",
      "  color: $color;",
      "}",
      "",
      ".root {",
      "  color: $color;",
      "}",
    ])

    processor.defines.should eq({ "$color" => "\"red\"" })

    processor.includes.should eq({
      "bar.css" => ["baz.css"],
      "baz.css" => ["qux.css"],
      "foo.css" => ["baz.css"],
      "root.css" => ["variables.css", "foo.css", "bar.css"]
    })
  end
end
