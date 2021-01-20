# UsraVideo

This is a work in programm gem written during undergraduate research with Cleveland State University's undergraduate physics department. The goal of the gem is to assist with quickly analyzing electron microscope videos of microgels suspended in ionic liquid. This is accomplished in several steps.

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

## Usage

This gem comes with an executable called usra_video. You can run the application with

     $ usra_video FILE

where FILE is the video you want to analyze.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
