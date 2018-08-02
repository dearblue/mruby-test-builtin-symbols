#!ruby

def print_memstat(*mrubies)
  total = []
  sep = nil

  mrubies.each do |mruby|
    total << stat = { mruby: mruby }

    puts "#{sep}$ readelf -S #{mruby}"
    sep ||= "\n"

    IO.popen(%W(readelf -S #{mruby}), "r") do |readelf|
      puts out = readelf.read
      out.scan(/\.(text|rodata)\b.+\n\s*(\w+)/) do |(name, size)|
        stat[name.to_sym] = size.to_i(16)
      end
    end

    puts "\n$ valgrind #{mruby} -e \"\""

    IO.popen(%W(valgrind #{mruby} -e ""), "r", err: [:child, :out]) do |valgrind|
      puts out = valgrind.read
      out.scan(/total heap usage: (\d+(?:,\d+)*) allocs, (\d+(?:,\d+)*) frees, (\d+(?:,\d+)*) bytes allocated/) do |(allocs, frees, allocated)|
        stat.merge!(
          allocs: allocs.gsub(?,, "").to_i,
          frees: frees.gsub(?,, "").to_i,
          allocated: allocated.gsub(?,, "").to_i)
      end
    end
  end

  puts <<-HEADER

========================================================================

text       rodata        malloc   (allocs)  binary

  HEADER

  total.each do |stat|
    printf "%<text>8d + %<rodata>8d with %<allocated>8d (%<allocs>6d)  %<mruby>s\n", stat
  end
end

if $0 == __FILE__
  if ARGV.empty?
    ARGV << Dir.glob("host-O*/bin/mruby").sort_by { |e| e.gsub(?/, ?\0) }
  end

  print_memstat(*ARGV)
end
