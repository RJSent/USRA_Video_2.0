# frozen_string_literal: true

require 'opencv'
require_relative 'detector.rb'
require_relative 'pairer.rb'

# Tracks objects across a video
class Tracker
  include OpenCV

  # FIXME: Hardcoded model
  def initialize(model: 'particlecascade2stage.xml')
    @model = model # FIXME: writer method
    @detector = Detector.new(model: model)
    @pairer = Pairer.new
  end

  # Detects all objects in all frames of a video
  # FIXME: Assumes video already extracted frames, SEMVideo has no way
  # of knowing if it needs to extract frames again.
  def detect_objects(video:, start_at: 30)
    objects_across_frames = []
    frames = get_frames(video.frame_dir)
    frames.reject { |frame| frame < video.frame_numbering % start_at }
    frames.each do |frame|
      objects_across_frames << detector.detect_bandaid(frame)
    end
    objects_across_frames
  end

  def pair_objects(array_of_cv:)
    
  end

  private

  attr_accessor :detector

  # FIXME: DRY same code as ContrastEnhancer
  def get_frames(dir)
    Dir.entries(dir).reject { |f| File.directory? f }.map do |f|
      File.absolute_path(f, dir)
    end
  end

  def output_dir(video)
    video.path + '_tracked'
  end
end
