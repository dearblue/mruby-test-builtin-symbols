#!ruby

MRuby::Build.new do |conf|
  toolchain :gcc
  conf.build_dir = "host"
  enable_debug
  enable_test
  cc.defines << %w(MRB_USE_ETEXT_EDATA)

  #gembox "full-core"
  gem core: "mruby-sprintf"
  gem core: "mruby-print"
  #gem core: "mruby-array-ext"
  gem core: "mruby-symbol-ext"
  gem core: "mruby-bin-mrbc"
  gem core: "mruby-bin-mirb"
  gem core: "mruby-bin-mruby"
end

require "yaml"

config = YAML.load(<<CONFIG)
build:
  host-O:
    test: true
    flags: -O
  host-O+use_etext_edata:
    test: true
    flags: -O
    defines: MRB_USE_ETEXT_EDATA
  host-O+builtin-symbols:
    test: true
    flags: -O
    defines: [MRB_ENABLE_BUILTIN_SYMBOLS]
  host-O+use_etext_edata+builtin-symbols:
    test: true
    flags: -O
    defines: [MRB_USE_ETEXT_EDATA, MRB_ENABLE_BUILTIN_SYMBOLS]
  host-O+builtin-symbols+force-inline:
    test: true
    flags: -O
    defines: [MRB_ENABLE_BUILTIN_SYMBOLS, MRB_ENABLE_FORCE_INLINE]
  host-O+use_etext_edata+builtin-symbols+force-inline:
    test: true
    flags: -O
    defines: [MRB_USE_ETEXT_EDATA, MRB_ENABLE_BUILTIN_SYMBOLS, MRB_ENABLE_FORCE_INLINE]
  host-Os:
    test: true
    flags: -Os
  host-Os+use_etext_edata:
    test: true
    flags: -Os
    defines: MRB_USE_ETEXT_EDATA
  host-Os+builtin-symbols:
    test: true
    flags: -Os
    defines: [MRB_ENABLE_BUILTIN_SYMBOLS]
  host-Os+use_etext_edata+builtin-symbols:
    test: true
    flags: -Os
    defines: [MRB_USE_ETEXT_EDATA, MRB_ENABLE_BUILTIN_SYMBOLS]
  host-Os+builtin-symbols+force-inline:
    test: true
    flags: -Os
    defines: [MRB_ENABLE_BUILTIN_SYMBOLS, MRB_ENABLE_FORCE_INLINE]
  host-Os+use_etext_edata+builtin-symbols+force-inline:
    test: true
    flags: -Os
    defines: [MRB_USE_ETEXT_EDATA, MRB_ENABLE_BUILTIN_SYMBOLS, MRB_ENABLE_FORCE_INLINE]
common:
  gems:
  - :core: mruby-sprintf
  - :core: mruby-print
  - :core: mruby-bin-mruby
  - :github: dearblue/mruby-bin-mrbstat
CONFIG

config["build"].each_pair do |name, spec|
  MRuby::Build.new(name) do |conf|
    toolchain :gcc

    conf.build_dir = conf.name

    enable_debug if spec["debug"]
    enable_test if spec["test"]

    cc.defines << (spec["defines"] || [])
    cc.flags << (spec["flags"] || [])

    config.dig("common", "gems").each do |*mgem|
      gem *mgem
    end
  end
end
