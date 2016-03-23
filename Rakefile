require 'winter_rakeutils'

include WinterRakeUtils

task :default => [ :local, :gitcommit ]

task :gitcommit do
  git_commit_push
end

task :local do
  target_dir = 'D:\DocSync\Bin'
  cp "next_wallpaper.bat", target_dir
  cp "next_wallpaper.rb", target_dir
end
