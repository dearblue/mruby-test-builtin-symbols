#!ruby

def print_mrbstat(*mrubies)
  total = []
  sep = nil

  mrubies.each do |mruby|
    total << stat = { name: mruby, builtin_symbols: 0 }

    puts "#{sep}$ #{mruby}"
    sep ||= "\n"

    if x = IO.popen(mruby, "r") { |io| puts log = io.read; log }.slice(/memory stat - after mrb_full_gc\(\).*/m)
      namemap = {
        "count of malloc"     => :"mallocs",
        "realloc"             => :"reallocs",
        "count of free"       => :"frees",
        "allocated memory"    => :"allocated",
        "realloc delta"       => :"realloc_delta",
        "absolute total"      => :"absolute_delta",
        "runtime symbols"     => :"runtime_symbols",
        "builtin symbols"     => :"builtin_symbols",
        "symbol capacity"     => :"symbol_capacity",
        "sizeof mrb->symtbl"  => :"sizeof_symtbl",
      }

      x.scan(/\b(#{namemap.keys.join("|")}):\s*(\d+)/) do
        stat.merge!(namemap[$1] => $2.to_i)
      end
    end
  end

  puts <<-HEADER

========================================================================

current  malloc   realloc  realloc  runtime  builtin  symbol   sizeof
  malloc    times    times    delta  symbols  symbols capacity   symtbl  binary

  HEADER

  total.each do |stat|
    printf "%<allocated>8d %<mallocs>8d %<reallocs>8d %<realloc_delta>8d " \
           "%<runtime_symbols>8d %<builtin_symbols>8d %<symbol_capacity>8d " \
           "%<sizeof_symtbl>8d  %<name>s\n", stat
  end
end

if $0 == __FILE__
  if ARGV.empty?
    ARGV << Dir.glob("host-O*/bin/mruby").sort_by { |e| e.gsub(?/, ?\0) }
  end

  print_mrbstat(*ARGV)
end
