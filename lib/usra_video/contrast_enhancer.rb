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
  # FIXME: No progress output
  def enhance(video:, output_dir: video.video_dir + '_enhanced/')
    frames = get_frames(video.frame_dir)
    frames.each_slice(num_procs).with_index(i) do |elements, i|
      elements.each do |frame|
        fork do
          image = enhance_frame(frame)
          image.write(output_dir + frame)
        end
      end
      Process.waitall
    end
    export_video
  end

  private

  attr_accessor :frames

  # FIXME: this method knows about the frame numbering scheme, tightly coupled and poor design
  # SEMVideo has a frame_numbering scheme
  # IMO best option would be to move video_from_frames to SEMVideo class, to be called when just give a frame_directory
  def export_video
    `ffmpeg -framerate #{average_fps} -i #{output_dir + 'frame_%3d.png'} -pix_fmt yux420p #{video.name + '_enhanced'}`
  end

  def average_fps
    frames.size / video.duration
  end
  
  def get_frames(dir)
    Dir.entries(dir).reject { |f| File.directory? f }
  end

  def enhance_frame(frame)
    image = MiniMagick::Image.open(video.frame_dir + '/' + frame)
    # Square color values to improve contrast, get_pixels returns array of rows, containing array
    colors = image.get_pixels.flatten
    colors.map! { |color| color**2 / 255 }
    blob = colors.pack('C*') # Recreate the original image, credit to stackoverflow.com/questions/53764046
    image = MiniMagick::Image.import_pixels(blob, image.width, image.height, 8, 'rgb')
    image = image.statistic('mean', '3x3')
    image = image.threshold(threshold_percent)
    image.statistic('mean', '6x6') # Replace with object discard below set size
  end

  def threshold_percent=(val)
    raise InvalidPercentFormatError, "The value #{val} is not a percent" unless percent?(val)

    @threshold_percent = val
  end

  # TODO: Guard against very large values of num_procs by confirming the input and warning it may crash the system
  def num_procs=(val)
    raise InvalidIntegerFormatError, "The value #{val} is not an integer" unless val.to_i
    raise InvalidIntegerFormatError, "The value #{val} is not > 1" unless val.to_i.positive?

    @num_procs = val
  end

  # TODO: Consider creating a validation module, as both Input and ContrastEnhancer use the same logic. (DRY)
  # Don't want ContrastEnhancer to call Input module's method (Minimize dependencies + Law of Demeter)
  # Perhaps change input from class methods to an actual module mixin
  def percent?(val)
    /[0-9][0-9]%/.match? val
  end
end
