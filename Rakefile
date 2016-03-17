task :default => [ :local, :gitcommit ]

def working_dir_clean
  `git status`.lines.each do |line|
    if line.index "Changes to be committed"
      return false
    end
  end
  return true
end

task :gitcommit do
  sh "git add -A"
  if not working_dir_clean
    sh "git commit -m auto"
    sh "git push"
  end
end

task :local do
  target_dir = 'D:\DocSync\Bin'
  cp "next_wallpaper.bat", target_dir
  cp "next_wallpaper.rb", target_dir
end
