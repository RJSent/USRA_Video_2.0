# frozen_string_literal: true

require 'mini_magick'
require 'pathname'
require 'etc' # I don't remember typing this...

# This class is meant to enhance a given video at a given threshold percent (converting greyscale to black and white)
class ContrastEnhancer
  attr_reader :threshold_percent, :num_procs

  def initialize(threshold_percent:, num_procs: Etc.nprocessors)
    self.threshold_percent = threshold_percent
    self.num_procs = num_procs
  end

  # FIXME: This method is very big... Try to split up
  # FIXME: DRY, frame_dir_setup contains the same code as this
  def enhance(video:, output_dir: append_enhanced(File.join(video.base_dir, video.name_no_ext)),
              make_content_frames: false,
              output_content_dir: append_content(File.join(video.base_dir, video.name_no_ext)))
    frames = get_frames(video.frame_dir)
    frame_dir_setup(output_dir)
    frame_dir_setup(output_content_dir) if make_content_frames
    output_content_dir = nil unless make_content_frames
    frames.each_slice(num_procs).with_index(1) do |elements, i|
      elements.each do |frame|
        fork do
          combined_file = Pathname.new('').join(output_dir, File.basename(frame))
          content_file = Pathname.new('').join(output_content_dir, File.basename(frame))
          enhance_frame(frame: frame, footer_height: video.footer_height,
                        content_file: content_file, combined_file: combined_file)
        end
      end
      Process.waitall
      print "\tEnhancing frames from #{video.name}: #{(i * elements.size / frames.size.to_f * 100).truncate(1)}%\r"
    end
    puts
    output_name = append_enhanced(video.name_no_ext) + video.extension
    output_content_name = append_enhanced(video.name_no_ext) + '_content' + video.extension
    video.class.frames_to_video(frame_dir: output_dir, duration: video.duration, name: output_name)
    video.class.frames_to_video(frame_dir: output_content_dir, duration: video.duration, name: output_content_name)
    # TODO: Return both SEMVideo objects
  end

  private

  attr_accessor :frames

  def average_fps
    frames.size / video.duration
  end

  def frame_dir_setup(dir)
    if Dir.exist?(dir)
      Dir.each_child(dir) { |f| File.delete(File.join(dir, f)) }
    else
      Dir.mkdir(dir)
    end
  end

  def get_frames(dir)
    Dir.entries(dir).reject { |f| File.directory? f }.map do |f|
      File.absolute_path(f, dir)
    end
  end

  # Enhances MiniMagick image, content of SEM video
  def enhance_image(image)
    colors = image.get_pixels.flatten
    colors.map! { |color| color**2 / 255 }
    blob = colors.pack('C*') # Recreate the original image, credit to stackoverflow.com/questions/53764046
    image = MiniMagick::Image.import_pixels(blob, image.width, image.height, 8, 'rgb')
    image.statistic('mean', '3x3')
    image.threshold(threshold_percent)
    image.statistic('median', '6x6') # Replace with object discard below set size
  end

  # Splits frame into two images, enhances one, recombines
  # Files combined file always, content file if provided
  def enhance_frame(frame:, footer_height: 0, content_file: nil, combined_file:)
    base = MiniMagick::Image.open(frame)
    content = base.crop "#{base.width}x#{base.height - footer_height}+0+0"
    footer = create_footer(frame, footer_height)
    content = enhance_image(content)

    tempfile = Tempfile.new(['', '.png'])
    combined = append_images(content, footer, tempfile)
    content.write(content_file.to_s) unless content_file.nil?
    combined.write(combined_file.to_s)
  end

  def threshold_percent=(val)
    raise ArgumentError, "The value #{val} is not a percent" unless percent?(val)

    @threshold_percent = val
  end

  # Vertically appends image2 to image1, storing in file
  # If image2 is nil, returns an image with identical content to image1
  # FIXME: Errors out if image2 is nil (no decode delegate for this image format)
  # Running same command from command line does not have an issue
  def append_images(image1, image2, file)
    image2path = image2.nil? ? nil : image2.path
    MiniMagick::Tool::Convert.new do |convert|
      convert << image1.path << image2path
      convert.append file.path
    end
    MiniMagick::Image.open(file.path) # Returns File object if we use Image.open. ????
  end

  def create_footer(frame, footer_height)
    return nil unless footer_height.positive?

    base = MiniMagick::Image.open(frame)
    if footer_height > base.height
      raise "The footer height #{footer_height} is larger than the image height #{base.height}"
    end

    base.crop "#{base.width}x#{footer_height}+0+#{base.height - footer_height}"
  end

  # TODO: Guard against very large values of num_procs by confirming the input and warning it may crash the system
  def num_procs=(val)
    raise ArgumentError, "The value #{val} is not an integer" unless val.to_i
    raise ArgumentError, "The value #{val} is not > 1" unless val.to_i.positive?

    @num_procs = val
  end

  # TODO: Consider creating a validation module, as both Input and ContrastEnhancer use the same logic. (DRY)
  # Don't want ContrastEnhancer to call Input module's method (Minimize dependencies + Law of Demeter)
  # Perhaps change input from class methods to an actual module mixin

  def append_enhanced(string)
    string.to_s + '_enhanced'
  end

  def append_content(string)
    string.to_s + '_content'
  end

  def percent?(val)
    /[0-9][0-9]%/.match? val
  end
end
