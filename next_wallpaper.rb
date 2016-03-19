require 'watir-webdriver'
require 'open-uri'
require 'ffi'
require 'openssl'
require 'fastimage'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
SCREEN_WIDTH = 1920
SCREEN_HEIGHT = 1080

def expand_gallery(browser)
  max_len = 0
  max_len_set = Time.now
  while true
    browser.execute_script("window.scrollBy(0,5000)")
    divs = browser.elements :css, "#rg_s > div"
    if divs.length > max_len
      max_len = divs.length
      max_len_set = Time.now
    else
      if Time.now - max_len_set > 2
        break
      end
    end
  end
  return max_len
end

def try_writing_image(b, max_len)
  image_index = rand(1..max_len)
  begin
    img = b.element :css, "#rg_s > div:nth-child(#{image_index}) > a > img"
    img.click

    view_image_btn = b.element :css, "#irc_cc > div:nth-child(3) > div.irc_b.i8152 > div._cjj > div.irc_butc > table._Ccb.irc_but_r > tbody > tr > td:nth-child(2) > a"
    view_image_btn.wait_until_present
    url = view_image_btn.attribute_value "href"
    puts "Image URL: #{url}"

    width, height = FastImage.size url
    if width != SCREEN_WIDTH or height != SCREEN_HEIGHT
      return nil
    end

    ext = url[url.rindex('.')..-1]
    image_path = "c:/windows/temp/next_wallpaper_wallpaper#{ext}"
    File.open(image_path, 'wb') do |f|
      f.write open(url).read
      puts "Image written to #{image_path}"
    end
    return image_path
  rescue Exception => e
    puts exception.backtrace
    return nil
  end
end

def download_image
  proxy = '127.0.0.1:7777'
  switches = [ "--proxy-server=#{proxy}", "--start-maximized" ]
  b = Watir::Browser.new :chrome, :switches => switches
  begin
    b.goto "http://image.google.com"
    input = b.text_field :css, "#lst-ib"
    input.set "nature wallpapers #{SCREEN_WIDTH}x#{SCREEN_HEIGHT}"
    input.send_keys :enter

    max_len = expand_gallery b

    retry_times = 0
    while retry_times < 5
      if image_path = try_writing_image(b, max_len)
        return image_path
      end
      retry_times += 1
    end

    if not image_path
      raise "Cannot download image"
    end
  ensure
    b.close
  end
end

module User32
  extend FFI::Library

  ffi_lib 'user32'
  ffi_convention :stdcall

  # BOOL SystemParametersInfo(UINT uiAction, UINT uiParam, PVOID pvParam, UINT fWinIni)
  attach_function :SystemParametersInfoA, [ :int, :int, :pointer, :int ], :int
end

SPI_SETDESKWALLPAPER = 0x0014
SPIF_UPDATEINIFILE = 0x01
SPIF_SENDWININICHANGE = 0x02
def set_wallpaper(image_path)
  p_image = FFI::MemoryPointer.from_string(image_path)
  win_ini = SPIF_UPDATEINIFILE | SPIF_SENDWININICHANGE
  if not User32.SystemParametersInfoA SPI_SETDESKWALLPAPER, 0, p_image, win_ini
    raise "Setting wallpaper failed"
  end
  puts "Done setting wallpaper"
end

image_path = download_image
set_wallpaper image_path
