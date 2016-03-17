task :default => [ :local, :gitcommit ]

task :gitcommit do
  sh "git add -A"
  `git status`.lines.each do |line|
    if not line.index "Your branch is up-to-date"
      sh "git commit -m auto"
      sh "git push"
    end
  end
end

task :local do
  target_dir = 'D:\DocSync\Bin'
  cp "next_wallpaper.bat", target_dir
  cp "next_wallpaper.rb", target_dir
end
