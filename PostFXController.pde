/*
	PostFXController
	Feature that adds filter to the resulting image
 */

import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;
public class PostFXController extends Feature {

	PostFX fx;
	public float midiNoiseFactor = 0;
	public float midiVigneteSize = 0;
	public boolean midiSobelEnabled = false;
	public float midiPixealte = height;
	public float midiRGBSplit = 0;
	
	public PostFXController(PApplet applet, MidiInterface midi, int midiEnableFaderNumber) {
		super(applet, midi, midiEnableFaderNumber);
	}

	public void setupFeature() {
		fx = new PostFX(this.applet);  

		midi.registerForFaderValue(this, 56);
		midi.registerForFaderValue(this, 57);
		midi.registerForFaderValue(this, 55);
		midi.registerForFaderValue(this, 54);
		midi.registerForNoteValue(this, 19);
	}

	public void newFaderValue(int value, int number) {
		if (number == 56) {
			midiNoiseFactor = map(value, 0, 127, 0, 0.8);
		}
		if (number == 57) {
			midiVigneteSize = map(value, 0, 127, 0, 1.5);
		}
		if (number == 55) {
			midiRGBSplit = map(value, 0, 127, 0, 200);
		}
		if (number == 54) {
			midiPixealte = map(value, 0, 127, width/2, 1);
		}
	}

	public void newNoteValue(int note) {
		super.newNoteValue(note);
		if (note == 19) {
			midiSobelEnabled = !midiSobelEnabled;
			this.midi.setControlLED(note, this.midiSobelEnabled);
		}
	}

	public void featureGotEnabled() {

	}

	public void drawFeature(int currentTimeState) {
		PostFXBuilder builder = fx.render();

		if (this.midiNoiseFactor > 0) {
			builder = builder.noise(midiNoiseFactor, 0.4);
		}
		if (this.midiPixealte < width/2) {
			builder = builder.pixelate(midiPixealte);
		}
		if (this.midiRGBSplit > 0) {
			builder = builder.rgbSplit(midiRGBSplit);
			//builder = builder.bloom(midiRGBSplit, 30, 50);
		}
		if (this.midiSobelEnabled) {
			builder = builder.sobel();
		}
		builder = builder.vignette(midiVigneteSize, 0.2);
		builder.compose();
	}
}
