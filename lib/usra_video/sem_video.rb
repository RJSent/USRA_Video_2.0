# frozen_string_literal: true

require 'streamio-ffmpeg'

# This class represents a video file taken from a SEM
class SEMVideo
  attr_reader :video_file, :frame_dir, :ffmpeg_video

  def initialize(video_file:, frame_dir: nil)
    self.video_file = video_file
    create_ffmpeg_video
    puts "Hello"
    self.frame_dir = frame_dir.nil? ? frame_dir_setup : frame_dir
  end

  def extract_frames
    ffmpeg_video.screenshot(frame_files,
                            { vframes: (duration * frame_rate).to_i, frame_rate: frame_rate },
                            { validate: false }) { |progress| puts "\tExtracting frames from #{video_file}: #{(progress * 100).truncate(1)}%" }
  end

  # Returns a new video in the parent of a directory filled with frames
  def self.frames_to_video(frame_dir:, duration:, numbering: frame_numbering)
    valid_directory(frame_dir)

    binding.pry
    frames = Dir.entries(frame_dir).reject { |f| File.directory? f }
    average_fps = frames.size / duration
    parent_dir = File.expand_path('..', frame_dir)
    parent_dir += '/' unless parent_dir[-1] == '/'
    output_video = parent_dir + lowest_output(parent_dir)
    `ffmpeg -framerate #{average_fps} -i #{frame_dir + numbering} -pix_fmt yux420p '#{output_video}`
    new(video_file: output_video, frame_dir: frame_dir)
  end

  def footer_height
    raise NotImplementedError, "This method is meant to be implemented, it just hasn't been yet"
  end

  def base_dir
    File.dirname(video_file)
  end

  def name
    File.basename(video_file)
  end

  def self.frame_numbering
    'frame_%3d.png'
  end

  def frame_rate
    @ffmpeg_video.frame_rate
  end

  def duration
    @ffmpeg_video.duration
  end

  private

  attr_writer :name, :base_dir, :frame_dir

  # Delete contents of directory if it already exists, else make it
  def frame_dir_setup
    self.class.valid_directory(base_dir)

    frame_dir = video_file + ' frames'
    if Dir.exist?(frame_dir)
      Dir.each_child(frame_dir) { |f| File.delete(frame_dir + '/' + f) }
    else
      Dir.mkdir(frame_dir)
    end
    frame_dir
  end

  # Works for both strings and File objects
  # expand_path is necessary as ~ isn't expanded to /home/user apparently
  def video_file=(file)
    raise ArgumentError, "The video #{file} was not found" unless File.exist?(File.expand_path(file))

    @video_file = File.realpath(file)
  end

  def frame_files
    frame_dir + '/' + self.class.frame_numbering
  end

  def create_ffmpeg_video
    @ffmpeg_video = FFMPEG::Movie.new(video_file)
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
        raise "You have over 99 output videos in #{directory}. That's a problem." if i > 99
      end
      "output#{i}.mp4"
    end

    def valid_directory(directory)
      raise ArgumentError, "The directory #{directory} does not exist" unless Dir.exist?(directory)
    end
  end
end
