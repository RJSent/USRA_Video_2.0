# frozen_string_literal: true

require 'streamio-ffmpeg'

# This class represents a video file taken from a SEM
class SEMVideo
  attr_reader :video_file, :video_dir, :frame_dir

  def initialize(video_file:, frame_dir: nil)
    self.file = video_file
    self.name = File.basename(video_file)
    self.base_dir = File.dirname(video_file)
    if frame_dir.nil?
      self.frame_dir = frame_dir_setup
    else
      self.frame_dir = frame_dir
    end
  end

  def extract_frames
    video = FFMPEG::Movie.new(file)
    video.screenshot(frame_files,
                     { vframes: (video.duration * video.frame_rate).to_i, frame_rate: video.frame_rate },
                     { validate: false }) { |progress| puts "\tExtracting frames from #{name}: #{progress * 100.truncate(1)}%" }
  end

  # Returns a new video in the parent of a directory filled with frames
  def self.video_from_frames(frame_dir:, duration:, numbering: frame_numbering)
    valid_directory(frame_dir)

    frames = Dir.entries(frame_dir).reject { |f| File.directory? f }
    average_fps = frames.size / duration
    parent_dir = File.expand_path('..', frame_dir)
    output_video = parent_dir + lowest_output(parent_dir)
    `ffmpeg -framerate #{average_fps} -i #{frame_dir + numbering} -pix_fmt yux420p '#{output_video}`
    new(video_file: output_video, frame_dir: frame_dir)
  end

  def footer_height
    raise NotImplementedError, "This method is meant to be implemented, it just hasn't been yet"
  end

  def self.frame_numbering
    'frame_%3d.png'
  end

  private

  attr_writer :name, :base_dir, :frame_dir

  # Delete contents of directory if it already exists, else make it
  def frame_dir_setup
    self.class.valid_directory(base_dir)

    frame_dir = base_dir + '/frames'
    if Dir.exist(frame_dir)
      Dir.each_child(frame_dir) { |x| File.delete(frame_dir + '/' + x) }
    else
      Dir.mkdir(frame_dir)
    end
    frame_dir
  end

  # Works for both strings and File objects
  # expand_path is necessary as ~ isn't expanded to /home/user apparently
  def video_file=(video_file)
    raise FileNotFoundError, "The video #{file} was not found" unless File.exist?(File.expand_path(file))

    @video_file = File.realpath(video_file)
  end

  def frame_files
    frame_dir + '/' + self.class.frame_numbering
  end

  class << self
    # Returns the lowest available output name in a directory
    # e.g. if a directory has output1.mp4, output2.mp4, output3.mp4
    # this will return output4.mp4
    # TODO: Could use optimizing, unnecessary sort() to protect bad algorithm
    def lowest_output(directory)
      valid_directory(directory)

      i = 1
      Dir.children(directory).sort.each do |f|
        i += 1 if "output#{i}.mp4" == f
        raise TooManyOutputsError, "You have over 99 output videos in #{directory}. That's a problem." if i > 99
      end
      "output#{i}.mp4"
    end

    def valid_directory(directory)
      raise DirectoryNotFoundError, "The directory #{directory} does not exist" unless Dir.exist(directory)
    end
  end
end
