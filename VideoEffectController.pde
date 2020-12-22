/*
	VideoEffectController
	Feature that adds filter to the Video image
 */

import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;
public class VideoEffectController extends Feature {

	PostFX fx;
	public float midiNoiseFactor = 0;
	public float midiVigneteSize = 0;
	public boolean midiSobelEnabled = false;
	public float midiPixealte = height;
	public float midiBrightPass = 0;
	
	public VideoEffectController(PApplet applet, MidiInterface midi, int midiEnableFaderNumber) {
		super(applet, midi, midiEnableFaderNumber);
	}

	public void setupFeature() {
		fx = new PostFX(this.applet);  

		midi.registerForFaderValue(this, 52);
		midi.registerForFaderValue(this, 53);
		midi.registerForFaderValue(this, 51);
		midi.registerForFaderValue(this, 50);
		midi.registerForNoteValue(this, 16);
	}

	public void newFaderValue(int value, int number) {
		if (number == 52) {
			midiNoiseFactor = map(value, 0, 127, 0, 0.8);
		}
		if (number == 53) {
			midiVigneteSize = map(value, 0, 127, 0, 1.5);
		}
		if (number == 51) {
			midiBrightPass = map(value, 0, 127, 0, 1);
		}
		if (number == 50) {
			midiPixealte = map(value, 0, 127, width/2, 1);
		}
	}

	public void newNoteValue(int note) {
		super.newNoteValue(note);
		if (note == 16) {
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
		if (this.midiBrightPass > 0) {
			builder = builder.brightPass(midiBrightPass);
		}
		if (this.midiSobelEnabled) {
			builder = builder.sobel();
		}
		builder = builder.vignette(midiVigneteSize, 0.4);
		builder.compose();
	}
}
