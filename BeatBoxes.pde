/*
	BeatBoxes
	Feature that renders boxes which resize on detected beats by Minim
 */

public class BeatBoxes extends Feature {
	float kickSize, snareSize, hatSize = 16;
	private int midiBeatBoxGab = 200;
	private float midiLineWidth = 7.0;
	private float midiRotateSpeed = 0.0;
	private float midiBoxScaling = 0.0;
	private boolean midiFillEnabled = false;
	float rotate = 0.0;

	public BeatBoxes(PApplet applet, MidiInterface midi, int midiEnableFaderNumber) {
		super(applet, midi, midiEnableFaderNumber);
	}

	public void setupFeature() {
		midi.registerForFaderValue(this, 30);
		midi.registerForFaderValue(this, 31);
		midi.registerForFaderValue(this, 29);
		midi.registerForFaderValue(this, 28);

		midi.registerForNoteValue(this, 10);
	}

	public void newFaderValue(int value, int number) {
		if (number == 30) {
      		midiBeatBoxGab = Math.round(map(value, 0, 127, 900, 0));
		}
		if (number == 29) {
			midiLineWidth = map(value, 0, 127, 0, 20);
		}
		if (number == 31) {
			midiBoxScaling = map(value, 0, 127, 0.0, 2.0);
		}
		if (number == 28) {
			midiRotateSpeed = map(value, 0, 127, 0.0, 0.1);
		}
	}

	public void newNoteValue(int note) {
		super.newNoteValue(note);
		if (note == 10) {
			midiFillEnabled = !midiFillEnabled;
			this.midi.setControlLED(note, midiFillEnabled);
		}
	}

	public void featureGotEnabled() {

	}

	public void drawFeature(int currentTimeState) {
		int maxGrow = 200;
		float rectW = bufferSize / beat.detectSize();

		if ( beat.isKick() ) kickSize = maxGrow;
		if ( beat.isSnare() ) snareSize = maxGrow;
		if ( beat.isHat() ) hatSize = maxGrow;

		if (!midiFillEnabled) {
			noFill();
		}

		PShape snareBox = createBox(30, Math.round(kickSize), 100);
		PShape kickBox = createBox(30, Math.round(kickSize), 100);
		PShape hatBox = createBox(30, Math.round(kickSize), 100);

		rotate = (rotate + this.midiRotateSpeed) % 360;
		kickBox.rotateY(rotate);
		kickBox.rotateX(rotate);

		hatBox.rotateY(rotate);
		snareBox.rotateX(rotate);

		pushMatrix();
		translate(currentAudioSource.getBufferSize()/2-(midiBeatBoxGab*2), height/2, 100);
		shape(hatBox);
		popMatrix();

		pushMatrix();
		translate(currentAudioSource.getBufferSize()/2-midiBeatBoxGab, height/2, 100);
		shape(snareBox);
		popMatrix();

		pushMatrix();
		translate(currentAudioSource.getBufferSize()/2, height/2, 100);
		shape(kickBox);
		popMatrix();
		
		pushMatrix();
		translate(currentAudioSource.getBufferSize()/2+midiBeatBoxGab, height/2, 100);
		shape(snareBox);
		popMatrix();

		pushMatrix();
		translate(currentAudioSource.getBufferSize()/2+(midiBeatBoxGab*2), height/2, 100);
		shape(hatBox);
		popMatrix();

		kickSize = constrain(kickSize * 0.96, 20, maxGrow);
		snareSize = constrain(snareSize * 0.96, 20, maxGrow);
		hatSize = constrain(hatSize * 0.96, 20, maxGrow);
	}

	private PShape createBox(int boxWidth, int boxHeight, int boxDepth) {
		PShape box = createShape(BOX, boxWidth, boxHeight, boxDepth);
		box.setStrokeWeight(this.midiLineWidth);
		box.setStroke(color(0,0,100));
		box.scale(midiBoxScaling);
		if (midiFillEnabled) {
			box.setFill(color(midi.hue, midi.saturation, 100));
			box.setStroke(color(0,0,100));
		} else {
			box.setStroke(color(midi.hue, midi.saturation, 100));
		}
		return box;
	}
}
