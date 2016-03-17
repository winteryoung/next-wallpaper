task :default => [ :local, :gitcommit ]

task :gitcommit do
  sh "git add -A"
  `git status`.lines.each do |line|
    if line.index "Your branch is up-to-date"
      next
    end
  end
  sh "git commit -m auto"
  sh "git push"
end

task :local do
  target_dir = 'D:\DocSync\Bin'
  cp "next_wallpaper.bat", target_dir
  cp "next_wallpaper.rb", target_dir
end
