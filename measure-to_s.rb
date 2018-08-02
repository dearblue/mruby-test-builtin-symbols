#!ruby

require "benchmark"

expr = %(10000000.times { :a.to_s })

Benchmark.bm(ARGV.max_by { |mruby| mruby.size }&.size || 0) do |bm|
  meas = 5.times.map {
    ARGV.map { |mruby|
       bm.report(mruby) {
        system *%W(#{mruby} -e #{expr})
      }
    }
  }

  meas = meas.transpose
  meas.each do |mm|
    mm.sort_by! { |m| m.total }
  end

  puts
  meas.each do |mm|
    puts "#{mm[2].to_s.chomp!}  #{mm[2].label}\n"
  end
end
