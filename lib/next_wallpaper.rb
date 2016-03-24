require 'watir-webdriver'
require 'open-uri'
require 'ffi'
require 'openssl'
require 'fastimage'
require 'tempfile'

class NextWallpaper
  def initialize width, height
    @width = width
    @height = height
  end

  def invoke
    image_path = nil
    begin
      image_path = download_image
      set_wallpaper image_path
    ensure
      if image_path
        File.delete image_path
      end
    end
  end

  private

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
    image_path = nil
    begin
      img = b.element :css, "#rg_s > div:nth-child(#{image_index}) > a > img"
      img.click

      view_image_btn = b.element :css, "#irc_cc > div:nth-child(3) > div.irc_b.i8152 > div._cjj > div.irc_butc > table._Ccb.irc_but_r > tbody > tr > td:nth-child(2) > a"
      view_image_btn.wait_until_present
      url = view_image_btn.attribute_value "href"
      puts "Image URL: #{url}"

      width, height = FastImage.size url
      if width != @width or height != @height
        return nil
      end

      ext = url[url.rindex('.')..-1]
      image_path = Tempfile.new "next_wallpaper_wallpaper#{ext}"
    rescue Exception => e
      puts "Error try writing image: #{e}"
      return nil
    end

    File.open(image_path, 'wb') do |f|
      f.write open(url).read
      puts "Image written to #{image_path}"
    end
  end

  def download_image
    proxy = '127.0.0.1:7777'
    switches = [ "--proxy-server=#{proxy}", "--start-maximized" ]
    b = Watir::Browser.new :chrome, :switches => switches
    begin
      b.goto "http://image.google.com"
      input = b.text_field :css, "#lst-ib"
      input.set "nature wallpapers #{@width}x#{@height}"
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

    attach_function :SystemParametersInfoA, [ :int, :int, :pointer, :int ], :int
  end

  def set_wallpaper(image_path)
    p_image = FFI::MemoryPointer.from_string(image_path)
    if not User32.SystemParametersInfoA 0x0014, 0, p_image, 0x03
      raise "Setting wallpaper failed"
    end
    puts "Done setting wallpaper"
  end
end
