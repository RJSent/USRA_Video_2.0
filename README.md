# USRA_Video

This is a work in progress gem written during undergraduate research
with Cleveland State University's physics department. The goal of the
gem is to assist with quickly analyzing electron microscope videos of
microgels suspended in ionic liquid. This is accomplished in several
steps.

1. Convert the image to black and white, where the microgels are white and the background is black. The header is not adjusted.
2. Perform object detection of microgel particles using OpenCV and a Haar Cascade model.
3. Look between adjacent frames, trying to group microgel positions together. This would track the position of microgels for the entire video.
4. Use the positional data that was just gathered to automatically analyze the microgels.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'usra_video'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install usra_video

Be sure that ImageMagick and OpenCV 2.4.13.7 are installed on the
system. Other versions of OpenCV < 3.0 may work, but are untested.
This is a limitation of the ruby-opencv gem dependency. Depending on
where OpenCV is installed, the ruby-opencv gem may need to be pointed
at the location during installation.

## Usage

This gem comes with an executable called usra_video. You can run the application with

     $ usra_video FILE

where FILE is the video you want to analyze.

## Example

This is an example showing the effectiveness of the contrast
enhancement and particle tracking for silica particles in ionic
liquid.

### Before

![Silica Before](/images/frame_0039.png)

### After

![Silica After](/images/frame_0039_content.png)

## Logic

Here are several sequences that should provide a outline of how the
different classes interact with each other. The diagrams were made
using [Mermaid](https://github.com/mermaid-js/mermaid).

### Enhancement

![Enhancement Sequence Diagram](/images/analysis_enhancement.png)

### Tracking

![Tracking Sequence Diagram](/images/analysis_tracking.png)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).