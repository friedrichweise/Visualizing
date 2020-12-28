/*
	Waveform
	Feature that draws multiple waveform of the input signal
 */

public class Waveform extends Feature {
	private boolean midiEnableLineMovement = false;
	private int valueMax = height / 2;
	private int midiLineSpacing = 100;
	private float midiLineWidth = 7.0;

	PShape line;  // The PShape object

	public Waveform(PApplet applet, MidiInterface midi, int midiEnableFaderNumber) {
		super(applet, midi, midiEnableFaderNumber);
	}

	public void setupFeature() {
		midi.registerForFaderValue(this, 1);
		midi.registerForFaderValue(this, 18);
		midi.registerForFaderValue(this, 17);
		midi.registerForFaderValue(this, 16);
		midi.registerForNoteValue(this, 1);
	}

	public void newFaderValue(int value, int number) {
		if (number == 18) {
			midiLineSpacing = Math.round(map(value, 127, 0, 15, 400));
		}
		if (number == 17) {
			midiLineWidth = map(value, 0, 127, 0, 20);
		}
		if (number == 16) {
			valueMax = Math.round(map(value, 0, 127,  0,  height));
		}
	}
	public void newNoteValue(int note) {
		super.newNoteValue(note);
		if (note == 1) {
			midiEnableLineMovement = !midiEnableLineMovement;
			this.midi.setControlLED(note, this.midiEnableLineMovement);
		}
	}

	public void featureGotEnabled() {

	}

	// get and normalize value from audioBuffer
	float getValueFromAudioBuffer(int i) {
	  float value = currentAudioSource.getCenter(i);
	  value = map(value, -1, 1, 0, valueMax);
	  return value;
	}

	public void drawFeature(int currentTimeState) {
  		int yPosition = height / 2;

		drawScene(currentTimeState, yPosition - midi.distanceBetweenWaveforms);
		drawScene(currentTimeState, yPosition + midi.distanceBetweenWaveforms);
	}

	public void drawScene(int run, int yPosition) {
		currentAudioSource.reframe();
		int centerX = currentAudioSource.getBufferSize()/2;
		int centerY = height/2;

		int y = yPosition - (valueMax / 2);
		line = createShape();
		line.beginShape();
		line.noFill();
		for (int i = 0; i < currentAudioSource.getBufferSize() - 1; i++) {
			line.vertex(i, getValueFromAudioBuffer(i));
			line.vertex(i+1, getValueFromAudioBuffer(i+1));
		}
		line.endShape();
		for (int z = 400; z > 0; z=z-midiLineSpacing) {
			int realZ = z;

			if (midiEnableLineMovement == true) {
				realZ = (z+(run)) % 400;
			}
			float strokeWidth = map(realZ, 0, 400, 0, this.midiLineWidth);
			pushMatrix();
			line.setStrokeWeight(strokeWidth);
			line.setStroke(color(midi.hue, midi.saturation, 100));
			translate(0, y, realZ);
			shape(line);
			popMatrix();
		}
	}
}
