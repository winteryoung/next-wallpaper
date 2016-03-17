task :default => :local

task :gitcommit do
  sh "git add -A"
  sh "git commit -m auto"
  sh "git push"
end

task :local do
  target_dir = 'D:\DocSync\Bin'
  cp "next_wallpaper.bat", target_dir
  cp "next_wallpaper.rb", target_dir
end
