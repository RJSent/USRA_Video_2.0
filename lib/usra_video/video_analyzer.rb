# frozen_string_literal: true

require 'mini_magick'
# require_relative 'usra_video' # require statements may not be necessary

module USRAVideo
  # This class is meant to handle analyzing the video
  # Sending it to the right programs, managing their
  # output, ensure the correct directories are written to, etc
  class VideoAnalyzer
    attr_reader(:video, :enhancer, :tracker, :dir)

    def initialize(video:, enhancer:, tracker:, dir: Dir.pwd)
      @video = video
      @enhancer = enhancer
      @tracker = tracker
      @base_dir = dir
    end

    def analyze
      @video.extract_frames
      enhancer.enhance(video: @video)
      # tracking_data = tracker.track(enhanced_video)
    end
  end
end
