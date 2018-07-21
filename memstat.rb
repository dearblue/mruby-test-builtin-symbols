#!ruby

def print_memstat(*mrubies)
  puts "%-6s   %-6s      %-6s  %s\n" % %w(text rodata malloc binary)

  mrubies.each do |mruby|
    stat = { mruby: mruby }

    IO.popen(%W(readelf -S #{mruby}), "r") do |readelf|
      readelf.read.scan(/\.(text|rodata)\b.+\n\s*(\w+)/) do |(name, size)|
        stat[name.to_sym] = size.to_i(16)
      end
    end

    IO.popen(%W(valgrind #{mruby} -e #{""}), "r", err: [:child, :out]) do |valgrind|
      valgrind.read.scan(/total heap usage: (\d+(?:,\d+)*) allocs, (\d+(?:,\d+)*) frees, (\d+(?:,\d+)*) bytes allocated/) do |(allocs, frees, allocated)|
        stat.merge!(
          allocs: allocs.gsub(?,, "").to_i,
          frees: frees.gsub(?,, "").to_i,
          allocated: allocated.gsub(?,, "").to_i)
      end
    end

    printf "%<text>6d + %<rodata>6d with %<allocated>6d  %<mruby>s\n", stat
  end
end

if $0 == __FILE__
  if ARGV.empty?
    ARGV << Dir.glob("host-O*/bin/mruby").sort_by { |e| e.gsub(?/, ?\0) }
  end

  print_memstat(*ARGV)
end
