require "option_parser"

require "../src/parser"
require "../src/resolver"
require "../src/version"

search_path = Array(String).new
directives = Hash(String, String).new
mode = :process

parser = OptionParser.parse! do |parser|
  name = File.basename($0)

  parser.banner = "Usage: #{name} [options] files...\n"

  parser.on("-I DIR", "--include DIR", "Include directory in the search path") do |dir|
    # Accept "-I foo:bar:baz" to be backwards compatible with older mpp versions
    search_path.concat(dir.split(":"))
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

resolver = Resolver.new
resolver.add(Dir.current)
resolver.add(search_path)

parser = Parser.new(resolver, directives)
result = parser.process(ARGV)

case mode
when :process
  puts result
when :make
  puts parser.make_dependencies
end
