using SnoopCompile

botconfig = BotConfig(
  "VarStructs";
  os = ["linux", "windows", "macos"],
  version = [v"1.4.1", v"1.3.1"],
  exhaustive = false,
)

snoopi_bot(
  botconfig,
  "$(@__DIR__)/example_script.jl",
)
