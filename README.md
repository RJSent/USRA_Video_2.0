# USRA_Video

## Table of Contents

1. [Introduction](#introduction)
2. [Installation](#paragraph1)
    a. [Dependencies](#subparagraph1)
3. [Usage](#paragraph2)
4. [Example](#paragraph3)
    a. [Before](#subparagraph3)
    b. [After](#sub2paragraph3)
5. [Logic](#paragraph4)
    a. [Enhancement](#subparagraph4)
    b. [Tracking](#sub2paragraph4)
6. [License](#paragraph5)

## Introduction <a name="introduction"></a>

This is a work in progress gem written during undergraduate research
with Cleveland State University's physics department. The goal of the
gem is to assist with quickly analyzing electron microscope videos of
microgels suspended in ionic liquid. This is accomplished in several
steps.

1. Convert the image to black and white, where the microgels are white and the background is black. The header is not adjusted.
2. Perform object detection of microgel particles using OpenCV and a Haar Cascade model.
3. Look between adjacent frames, trying to group microgel positions together. This would track the position of microgels for the entire video.
4. Use the positional data that was just gathered to automatically analyze the microgels.

## Installation <a name="paragraph1"></a>

Add this line to your application's Gemfile:

```ruby
gem 'usra_video'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install usra_video

### Dependencies <a name="subparagraph1"></a>

Be sure that ImageMagick and OpenCV 2.4.13.7 are installed on the
system. Other versions of OpenCV < 3.0 may work, but are untested.
This is a limitation of the ruby-opencv gem dependency. Depending on
where OpenCV is installed, the ruby-opencv gem may need to be pointed
at the location during installation.

## Usage <a name="paragraph2"></a>

This gem comes with an executable called usra_video. You can run the application with

     $ usra_video FILE

where FILE is the video you want to analyze.

## Example <a name="paragraph3"></a>

This is an example showing the effectiveness of the contrast
enhancement and particle tracking for silica particles in ionic
liquid.

### Before <a name="subparagraph3"></a>

<img src="images/frame_0039.png" alt="Original image" width="600" />

### After <a name="sub2paragraph3"></a>

<img src="images/frame_039_content.png" alt="Enhanced and tracked image" width="600" />

## Logic <a name="paragraph4"></a>

Here are some sequence diagrams that should provide a outline of how
the different classes interact with each other. The diagrams were made
using [Mermaid](https://github.com/mermaid-js/mermaid).

### Enhancement <a name="subparagraph4"></a>

<img src="images/analysis_enhancement.png" alt="Enhancement sequence diagram" width="600" />

### Tracking <a name="sub2paragraph4"></a>

<img src="images/analysis_tracking.png" alt="Tracking sequence diagram" width="600" />

## License < a name="paragraph5"></a>

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).