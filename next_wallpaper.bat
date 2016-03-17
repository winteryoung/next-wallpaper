date /t >> %userprofile%\logs\next_wallpaper.log
time /t >> %userprofile%\logs\next_wallpaper.log
ruby %~dp0next_wallpaper.rb 2>&1 | tee -a %userprofile%\logs\next_wallpaper.log
