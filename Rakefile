require 'rake/clean'

APP_NAME = "next_wallpaper"
TARGET_DIR = "target"

require 'winter_rakeutils'
WinterRakeUtils.load_git_tasks
WinterRakeUtils.load_gem_tasks

task :default => [ :local, :gitcommit ]

task :local => [ :clobber, :local_gem ]
