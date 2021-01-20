# frozen_string_literal: true

require 'opencv'

class Detector
  include OpenCV

  def initialize(model:)
    @model = model
    @detector = CvHaarClassifierCascade.load(model)
  end

  # Returns CvSeq
  def detect_image(image:)
    detector.detect_objects(image)
  end

  # Band-aid fix for my crappy model, discard when above certain area
  def detect_bandaid(image:, area: 2000)
    objects = detect_image(image: image)
    objects.each_with_index do |object, i|
      remove(i) if object.width * object.height > area
    end
  end

  private

  def draw_bounding_boxes(image:, output_dir:, cv_seg:)
    CvMat.load(image)
    cv_seg.each do |object|
      image.rectangle! object.top_left, object.bottom_right, color: color
    end
    image.save_image(File.join(output_dir, image))
  end

  def color
    CvColor::Red
  end
end
