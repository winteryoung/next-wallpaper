require 'rake'

Gem::Specification.new do |s|
  s.name        = 'next_wallpaper'
  s.version     = '0.0.0'
  s.date        = '2016-03-24'
  s.summary     = "Next wallpaper"
  s.description = "Switch to next wallpaper"
  s.authors     = [ "Winter Young" ]
  s.email       = '513805252@qq.com'
  s.files       = FileList.new "lib/*.rb"
  s.homepage    = 'https://github.com/winteryoung/next-wallpaper'
  s.license     = 'Apache-2.0'
  s.executables = [ "next_wallpaper" ]
  s.add_runtime_dependency "ffi", ["~> 1.9"]
  s.add_runtime_dependency "watir-webdriver", ["~> 0.9"]
  s.add_runtime_dependency "fastimage", ["~> 1.9"]
  s.add_development_dependency "winter_rakeutils", ["~> 0.3", ">= 0.3.1"]
end
