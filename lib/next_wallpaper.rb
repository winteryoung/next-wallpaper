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
    temp_file = download_image
    set_wallpaper temp_file.path
  end

  def set_wallpaper image_path
    p_image = FFI::MemoryPointer.from_string image_path
    win_ini = User32::SPIF_UPDATEINIFILE | User32::SPIF_SENDWININICHANGE
    if not User32.SystemParametersInfoA User32::SPI_SETDESKWALLPAPER, 0, p_image, win_ini
      raise "Setting wallpaper failed"
    end
    puts "Done setting wallpaper"
  end

  def extract_domain_part url
    m = /^(https?:\/\/.+?\/).*/.match url
    if m
      return m.captures[0]
    end
    return nil
  end

  def read_image_url url
    domain = extract_domain_part url
    unless domain
      raise "Cannot extract domain for #{url}"
    end
    open(url, "Referer" => domain).read
  end

  def try_image_url url, recur_level = 0
    if recur_level > 5
      puts "Exceeds max recursion level for trying image url"
      return nil
    end

    temp_file = Tempfile.new "next_wallpaper_temp_image"
    temp_file.write read_image_url(url)
    temp_file.close

    puts "Try image: #{url}"
    width, height = FastImage.size temp_file.path
    if width == nil
      puts "HTML backend for image url"
      b = new_browser
      begin
        b.goto url
        img = b.element :css, "img"
        img.wait_until_present
        img_src = img.attribute_value("src")
        if img_src == url
          puts "Same url, stop trying image"
          return nil
        end
      ensure
        b.close
      end
      return try_image_url img.attribute_value("src"), recur_level + 1
    elsif width != @width or height != @height
      puts "Incorrect image size: [#{width}, #{height}]"
      return nil
    else
      return url
    end
  end

  def new_browser
    proxy = '127.0.0.1:7777'
    switches = [ "--proxy-server=#{proxy}", "--start-maximized" ]
    return Watir::Browser.new :chrome, :switches => switches
  end

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
      puts "read image #{image_index}"
      img.wait_until_present
      img.click
      puts "after click img"

      view_image_btn = b.element :css, "#irc_cc > div:nth-child(2) > div.irc_b.i8152 > div._cjj > div.irc_butc > table._Ccb.irc_but_r > tbody > tr > td:nth-child(2) > a"
      view_image_btn.wait_until_present
      url = view_image_btn.attribute_value "href"
      url = try_image_url url

      if url == nil
        return nil
      end

      ext = url[url.rindex('.')..-1]
      temp_file = Tempfile.new ["next_wallpaper", ext]
      temp_file.binmode
      temp_file.write read_image_url(url)
      temp_file.close

      return temp_file
    rescue Exception => e
      puts "Error try writing image: #{e}"
      puts e.backtrace
      return nil
    end
  end

  def download_image
    b = new_browser
    begin
      b.goto "http://image.google.com"
      input = b.text_field :css, "#lst-ib"
      input.set "nature wallpapers #{@width}x#{@height}"
      input.send_keys :enter

      max_len = expand_gallery b
      puts "Max image: #{max_len}"

      retry_times = 0
      temp_file = nil
      while retry_times < 5
        if temp_file = try_writing_image(b, max_len)
          return temp_file
        end
        retry_times += 1
      end

      raise "Max retry exceeded"
    ensure
      b.close
    end
  end

  module User32
    extend FFI::Library

    ffi_lib 'user32'
    ffi_convention :stdcall

    SPI_SETDESKWALLPAPER = 0x0014
    SPIF_UPDATEINIFILE = 0x01
    SPIF_SENDWININICHANGE = 0x02

    attach_function :SystemParametersInfoA, [ :int, :int, :pointer, :int ], :int
  end
end
