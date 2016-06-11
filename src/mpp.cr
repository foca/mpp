require "option_parser"

require "./parser"
require "./processor/output"
require "./processor/makedepend"
require "./resolver"
require "./version"

resolver = Resolver.new
directives = Hash(String, String).new
mode = :process

parser = OptionParser.parse! do |parser|
  name = File.basename($0)

  parser.banner = "Usage: #{name} [options] files...\n"

  parser.on("-I DIR", "--include DIR", "Include directory in the search path") do |dir|
    # Accept "-I foo:bar:baz" to be backwards compatible with older mpp versions
    resolver.add(dir.split(":"))
  end

  parser.on("-D NAME=VAL", "--define NAME=VAL", "Define a directive") do |directive|
    if directive.includes?("=")
      var, value = directive.split("=")
      directives[var] = value
    else
      abort "Malformed directive: `#{directive}` (expected `NAME=VALUE`)"
    end
  end

  parser.on("-M", "--make", "Output template dependencies for a Makefile") do
    mode = :make
  end

  parser.on("-v", "--version", "Print the version of #{name}") do
    puts "#{name} version #{MPP_VERSION}"
    exit 0
  end

  parser.on("-h", "--help", "Show this help message") do
    puts parser
    exit 0
  end
end

if ARGV.empty?
  puts parser
  exit 0
end

resolver.add(Dir.current)

processor = case mode
            when :process
              Processor::Output.new(directives)
            when :make
              Processor::MakeDepend.new
            else
              # You can't get to here, so this just keeps the compiler happy.
              abort "Unknown processing mode."
            end

parser = Parser.new(resolver, processor)
parser.process(ARGV)
puts parser.to_s
