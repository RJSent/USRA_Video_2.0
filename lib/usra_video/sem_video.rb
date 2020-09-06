# frozen_string_literal: true

require 'streamio-ffmpeg'

# This class represents a video file taken from a SEM
class SEMVideo
  attr_reader :name, :dir, :frame_dir

  def initialize(video_name:)
    raise FileNotFoundError, "The video #{video_name} was not found" unless File.exist? video_name

    self.name = video_name
    self.dir = File.expand_path(video_name)
    self.frame_dir = dir + "/#{name}_frames"
  end

  def extract_frames
    video = FFMPEG::Movie.new(video_name)
    video.screenshot(frame_files,
                     { vframes: (video.duration * video.frame_rate).to_i, frame_rate: video.frame_rate },
                     { validate: false }) { |progress| puts "\tExtracting frames from #{name}: #{progress * 100.truncate(1)}%" }
  end

  def footer_height
    raise NotImplementedError, "This method is meant to be implemented, it just hasn't been yet"
  end

  private

  attr_writer :name, :dir, :frame_dir

  def frame_numbering
    'frame_%3d.png'
  end

  def frame_files
    dir + '/' + frame_numbering
  end
end
