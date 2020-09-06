# frozen_string_literal: true

require 'mini_magick'
require 'etc'

# This class is meant to enhance a given video at a given threshold percent (converting greyscale to black and white)
class ContrastEnhancer
  attr_reader :threshold_percent, :num_procs
  
  def init(threshold_percent, num_procs = Etc.nprocessors)
    self.threshold_percent = threshold_percent
    self.num_procs = num_procs
  end

  def enhance(video)
    frames = get_frames(video.frame_dir)
    frames.each_slice(num_procs).with_index(i) do |elements, i|
      elements.each(&:enhance)
      Process.waitall
    end
  end

  private

  def get_frames(dir)
    Dir.entries(dir).reject { |f| File.directory? f }
  end

  def enhance_frame(frame)
    iamge = MiniMagick::Image.open()
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
