require "../spec_helper"
require "../../src/processor/output"

describe Processor::Output do
  it "makes replacements from #define directives when processing a line" do
    processor = Processor::Output.new
    processor.on_define("foo", "bar")
    processor.on_line("this is foo:\n")
    processor.on_line("it's very much foo!\n")

    processor.to_s.should eq("this is bar:\nit's very much bar!\n")
  end

  it "produces no output if no lines are processed" do
    processor = Processor::Output.new
    processor.to_s.should eq("")
  end

  it "produces verbatim output when no replacements are defined" do
    processor = Processor::Output.new
    processor.on_line("hello world\n")

    processor.to_s.should eq("hello world\n")
  end

  it "produces verbatim output when no defined replacements are encountered" do
    processor = Processor::Output.new
    processor.on_define("foo", "bar")
    processor.on_line("hello world\n")

    processor.to_s.should eq("hello world\n")
  end

  it "doesn't retroactively apply #define replacements" do
    processor = Processor::Output.new
    processor.on_line("this is foo:\n")
    processor.on_define("foo", "bar")
    processor.on_line("it's very much foo!\n")

    processor.to_s.should eq("this is foo:\nit's very much bar!\n")
  end

  it "accepts an initial set of user-defined replacements" do
    processor = Processor::Output.new({ "foo" => "bar" })
    processor.on_line("this is foo\n")

    processor.to_s.should eq("this is bar\n")
  end

  it "applies multiple replacements in order if applicable" do
    processor = Processor::Output.new
    processor.on_define("hello", "foo")
    processor.on_define("foo", "bar")
    processor.on_define("{name}", "world")

    processor.on_line("hello {name}\n")

    processor.to_s.should eq("bar world\n")
  end
end
