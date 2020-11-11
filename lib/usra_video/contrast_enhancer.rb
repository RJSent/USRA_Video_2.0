# frozen_string_literal: true

require 'mini_magick'
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
  def enhance(video:, output_dir: append_enhanced(File.join(video.base_dir, video.name_no_ext)))
    frames = get_frames(video.frame_dir)
    frame_dir_setup(output_dir)
    frames.each_slice(num_procs).with_index(1) do |elements, i|
      elements.each do |frame|
        fork do
          image = enhance_frame(File.absolute_path(frame, video.frame_dir))
          image.write(File.join(output_dir, frame))
        end
      end
      Process.waitall
      print "\tEnhancing frames from #{video.name}: #{(i * elements.size / frames.size.to_f * 100).truncate(1)}%\r"
    end
    puts
    output_name = append_enhanced(video.name_no_ext) + video.extension
    video.class.frames_to_video(frame_dir: output_dir, duration: video.duration, name: output_name)
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
    Dir.entries(dir).reject { |f| File.directory? f }
  end

  def enhance_frame(frame)
    image = MiniMagick::Image.open(frame)
    colors = image.get_pixels.flatten
    colors.map! { |color| color**2 / 255 }
    blob = colors.pack('C*') # Recreate the original image, credit to stackoverflow.com/questions/53764046
    image = MiniMagick::Image.import_pixels(blob, image.width, image.height, 8, 'rgb')
    image.statistic('mean', '3x3')
    image.threshold(threshold_percent)
    image.statistic('median', '6x6') # Replace with object discard below set size
  end

  def threshold_percent=(val)
    raise ArgumentError, "The value #{val} is not a percent" unless percent?(val)

    @threshold_percent = val
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
  
  def percent?(val)
    /[0-9][0-9]%/.match? val
  end
end
