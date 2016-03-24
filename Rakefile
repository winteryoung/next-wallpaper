require 'rake/clean'
require "rubygems"
require "winter_rakeutils"

include WinterRakeUtils

app_name = "next_wallpaper"

gem_spec = Gem::Specification::load("#{app_name}.gemspec")
ver = gem_spec.version
gem_source_files = FileList.new "lib/*", "bin/*", "#{app_name}.gemspec"
gem_file = FileList.new "target/#{app_name}-#{ver}.gem"

task :default => [ :local, :gitcommit ]

CLOBBER.include "target"
directory "target"

rule /target\/.+?\.gem/ => ['target', *gem_source_files] do |t|
  sh "gem build #{app_name}.gemspec"
  mv "#{app_name}-#{ver}.gem", "target/"
end

task :gitcommit do
  git_commit_push
end

task :build => ['target', "target/#{app_name}-#{ver}.gem"]

task :local => [ :clobber, :build, 'target' ] do
  sh "gem uninstall -ax #{app_name}"
  within_dir "target" do
    sh "gem install #{app_name}-#{ver}.gem"
  end
end

task :test do
  tests = FileList.new "test/**/*_test.rb"
  tests.each do |test|
    system "ruby #{test}"
  end
end
