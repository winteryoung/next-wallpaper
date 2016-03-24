require_relative '../lib/next_wallpaper'
require 'open-uri'

nw = NextWallpaper.new 1920, 1080
temp = Tempfile.new ["nwall", ".jpeg"]
temp.binmode
temp.write open("https://www.planwallpaper.com/static/images/butterfly-wallpaper.jpeg").read
temp.close
puts temp.path
nw.set_wallpaper temp.path
