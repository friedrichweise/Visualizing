/*
	Waveform
	Feature that draws multiple waveform of the input signal
 */

public class Waveform extends Feature {
	private boolean midiFillLine = false;
	private int valueMax = height / 2;
	private int midiLineSpacing = 100;
	private float midiLineWidth = 7.0;
	private float xScale = 1.0;
	private int distanceBetweenWaveforms = 200;

	PShape line;  // The PShape object

	public Waveform(PApplet applet, MidiInterface midi, int midiEnableFaderNumber) {
		super(applet, midi, midiEnableFaderNumber);
	}

	public void setupFeature() {
		midi.registerForFaderValue(this, 1);
		midi.registerForFaderValue(this, 18);
		midi.registerForFaderValue(this, 17);
		midi.registerForFaderValue(this, 16);
		midi.registerForFaderValue(this, 19);
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
			valueMax = Math.round(map(value, 0, 127,  0,  height*2));
		}
		if (number == 19) {
			distanceBetweenWaveforms = Math.round(map(value, 0, 127, 600, 0));
		}
	}
	public void newNoteValue(int note) {
		super.newNoteValue(note);
		if (note == 1) {
			midiFillLine = !midiFillLine;
			this.midi.setControlLED(note, this.midiFillLine);
		}
	}

	public void featureGotEnabled() {
		// calculate the xScale to adjust buffersSize to window width
		this.xScale = (float)width/(float)currentAudioSource.getBufferSize();
	}

	// get and normalize value from audioBuffer
	float getValueFromAudioBuffer(int i) {
	  float value = currentAudioSource.getCenter(i);
	  value = map(value, -1, 1, -valueMax/2, valueMax/2);
	  return value;
	}

	public void drawFeature(int currentTimeState) {
		currentAudioSource.reframe();
		line = createShape();

		line.beginShape();
		line.vertex(0,0);
		for (int i = 0; i < currentAudioSource.getBufferSize() - 1; i++) {
			line.vertex(i, getValueFromAudioBuffer(i));
			line.vertex(i+1, getValueFromAudioBuffer(i+1));
		}

		if (this.midiFillLine) {
			line.vertex(currentAudioSource.getBufferSize() - 1, 0);
			line.endShape(CLOSE);
			line.setFill(color(midi.hue, midi.saturation, 200));
		} else {
			line.noFill();
			line.endShape();
		}
		line.setStroke(color(midi.hue, midi.saturation, 200));
		line.scale(this.xScale, 1.0, 1.0);	

  		int yPosition = height / 2;
		drawScene(yPosition - distanceBetweenWaveforms);
		drawScene(yPosition + distanceBetweenWaveforms);
	}

	public void drawScene(int yPosition) {
		int centerX = width/2;
		int y = yPosition;
		
		for (int z = 400; z > 0; z=z-midiLineSpacing) {
			int realZ = z;

			float strokeWidth = map(realZ, 0, 400, 0, this.midiLineWidth);
			pushMatrix();
			line.setStrokeWeight(strokeWidth);
			translate(0, y, realZ);
			shape(line);
			popMatrix();
		}
	}
}
