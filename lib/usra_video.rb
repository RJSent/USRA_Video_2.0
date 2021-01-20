# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'

require_relative 'usra_video/version'
require_relative 'usra_video/contrast_enhancer'
require_relative 'usra_video/input'
require_relative 'usra_video/output'
require_relative 'usra_video/sem_video'
require_relative 'usra_video/tracker'
require_relative 'usra_video/video_analyzer'

# This module needs to be documented ;)
# args is meant to be a series of videos, relative to pwd or absolute.
module USRAVideo
  def self.execute(*args)
    prompt_args if args.empty?
    args.each do |video_name|
      analyze video_name
    end
  end

  def self.analyze(video_name)
    video = video_creator(video_name)
    enhancer = enhancer_creator
    tracker = tracker_creator
    VideoAnalyzer.new(video: video, enhancer: enhancer, tracker: tracker, dir: base_dir).analyze
  end

  def self.prompt_args
    raise NotImplementedError,
          "This method is meant to be implemented, it just hasn't been yet"
  end

  def self.base_dir
    Dir.pwd
  end

  def self.video_creator(video_name)
    SEMVideo.new(video_file: video_name)
  end

  def self.enhancer_creator
    ContrastEnhancer.new(threshold_percent: '28%')
  end

  def self.tracker_creator
    Tracker.new
  end

  def self.threshold_percent
    Output.prompt_percent
    Input.answer_percent
  end
end
