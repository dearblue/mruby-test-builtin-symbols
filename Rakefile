#!ruby

MRUBY_CONFIG ||= ENV["MRUBY_CONFIG"] || "test_config.rb"
ENV["MRUBY_CONFIG"] = MRUBY_CONFIG

Object.instance_eval { remove_const(:MRUBY_CONFIG) }

ENV["MRUBY_ROOT"] ||= MRUBY_ROOT || "@mruby"

Object.instance_eval { remove_const(:MRUBY_ROOT) } if Object.const_defined? :MRUBY_ROOT

ENV["INSTALL_DIR"] = File.join(File.dirname(__FILE__), "bin")

rakefile = "#{ENV["MRUBY_ROOT"]}/Rakefile"

unless File.exist? rakefile
  $stderr.puts <<-ERR
[[#{__FILE__}]]
\tNot found #{rakefile}.
\tLook again a configuration, and try rake.

\t* MRUBY_CONFIG=#{ENV["MRUBY_CONFIG"]}
\t* MRUBY_ROOT=#{ENV["MRUBY_ROOT"]}
\t* INSTALL_DIR=#{ENV["INSTALL_DIR"]}
  ERR

  abort 1
end

load rakefile

task "memsize" do#=> "default" do
  # for i in host-O*/bin/mruby; do readelf -S $i | ruby -e 'puts "\n%<text>6d + %<rodata>6d  %<bin>s" % $stdin.read.scan(/\.(text|rodata)\b.+\n\s*(\w+)/).reduce({}){|a, (name, size)| a[name.to_sym] = size.to_i(16); a }.merge!(bin: ARGV[0])' -- $i; valgrind $i -e '' 2>&1 | grep 'total heap usage:'; done
  require_relative "memstat"

  mrubyies = Dir.glob("host-O*/bin/mruby").sort_by { |e| e.gsub(?/, ?\0) }
  print_memstat(*mrubyies)
end
