require "./spec_helper"
require "../src/resolver"
require "../src/path"

describe Resolver do
  project_dir = File.expand_path(File.join(__FILE__, "../.."))

  it "finds files relative to one of the added search paths" do
    resolver = Resolver.new

    Dir.cd(project_dir) do
      resolver.add("example")
      path = resolver.resolve("assets/css/foo.css")

      path.absolute.should eq(File.join(project_dir, "example/assets/css/foo.css"))
      path.to_s.should eq("assets/css/foo.css")
    end
  end

  it "raises an error if no file can't be found" do
    resolver = Resolver.new

    Dir.cd(project_dir) do
      resolver.add("example")
      expect_raises(Resolver::NotFound) do
        resolver.resolve("nope_this_is_not_an_actual_file.css")
      end
    end
  end

  it "raises an error if no search paths have been added" do
    resolver = Resolver.new

    Dir.cd(project_dir) do
      expect_raises(Resolver::NotFound) do
        resolver.resolve("example/css/foo.css")
      end
    end
  end
end
