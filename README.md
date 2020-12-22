# Visualizing

This repository contains my second implementation of a live audio visualizer. The software is able to analyse an audio signal and generate a matching video signal. Through a connected MIDI Interface the user can combine geometrical forms with video loops and filters.

* Features:
	* show Waveform or FFT representation of music signal
	* show simple animated geometric forms that respond to beats
	* load and loop video files and manipulate them with several effects
	* use shader based filters (pixelate, noise, rgb-shift ) to tune the composition

<img src="assets/grid.gif"/><br>

<img src="assets/midimix.gif"/><br>

## Using the code
The first step is to install the listed dependencies as well as `processing-java` with the Processing.app. To fully use the wide range of visual options you should connect the AKAI MIDImix. Thus using another MIDI controller is possible but requires adjusting the channel numbers in each `Feature`-File (`setupFeature()` function).
The Feature `VideoPlayer.pde` allows playback of all `.mov` and `.mp4` files located in the `data`-Folder. For performance reasons I decode them to MPEG2 and scale them to 720p. Video files can be loaded during a session with the arrow keys.

To start open `visalizing_again.pde` in processing or run `./start` in the repo folder.

## Dependencies
This implementation is based on my [first visualizer](https://github.com/friedrichweise/visualizer/) written in Proccessing. In addition it uses the following dependencies:
* [Minim Sound Library](http://code.compartmental.net/minim/)
* [PostFX](https://github.com/cansik/processing-postfx/)
* [themidibus](https://github.com/sparks/themidibus)

