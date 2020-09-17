# frozen_string_literal: true

require 'streamio-ffmpeg'

# This class represents a video file taken from a SEM
class SEMVideo
  attr_reader :name, :frame_dir

  # FIXME: Not sure how to require just one of these two arguments. Can't assign default value to frame_dir since
  # it requires @name to be set
  def initialize(video_name:, frame_dir: nil)
    self.name = video_name
    if frame_dir.nil?
      self.frame_dir = video_dir + '/frames'
    else
      self.frame_dir = frame_dir
  end

  def extract_frames
    video = FFMPEG::Movie.new(video_name)
    video.screenshot(frame_files,
                     { vframes: (video.duration * video.frame_rate).to_i, frame_rate: video.frame_rate },
                     { validate: false }) { |progress| puts "\tExtracting frames from #{name}: #{progress * 100.truncate(1)}%" }
  end

  def video_from_frames
    
  end

  def footer_height
    raise NotImplementedError, "This method is meant to be implemented, it just hasn't been yet"
  end

  def video_dir
    File.expand_path(video_name)
  end

  private

  attr_writer :name, :frame_dir

  # TODO: Not sure how to implement error checking when only one is required in an object oriented manner
  #
  # def name=(video_name)
  #  raise FileNotFoundError, "The video #{video_name} was not found" unless File.exist? video_name
  #
  #  @name = video_name
  # end
  #
  
  def frame_dir=(frame_dir)
    raise DirectoryNotFoundError, "The directory #{frame_dir} was not found" unless Dir.exist? frame_dir
    @frame_dir = frame_dir
  end

  def frame_numbering
    'frame_%3d.png'
  end

  def frame_files
    dir + '/' + frame_numbering
  end
end
