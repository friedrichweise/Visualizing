/*
	Spectro
	Feature that draws a spectrogram from the Minim FFT functionality
 */
public class Spectro extends Feature {
	private float midiLineWidth = 2.0;
	private int midiLineSpacing = 0;
	private boolean midiVertexEnabled = false;
	private int midiHistorySize = 40;
	private int valueMax = height / 2;
	LinkedList<ArrayList<Float>> fftHistory = new LinkedList<ArrayList<Float>>();

	public Spectro(PApplet applet, MidiInterface midi, int midiEnableFaderNumber) {
		super(applet, midi, midiEnableFaderNumber);
		midi.registerForFaderValue(this, 21);
		midi.registerForFaderValue(this, 23);
		midi.registerForFaderValue(this, 22);
		midi.registerForFaderValue(this, 20);

		midi.registerForNoteValue(this, 4);
	}

	public void setupFeature() {

	}

	public void newFaderValue(int value, int number) {
		if (number == 21) {
			this.midiLineWidth = map(value, 0, 127, 0, 10);
		}
		if (number == 23) {
			this.midiLineSpacing = Math.round(map(value, 0, 127, -700, 200));
		}
		if (number == 22) {
			this.midiHistorySize = Math.round(map(value, 0, 127, 2, 50));
		}
		if (number == 20) {
			this.valueMax = Math.round(map(value, 0, 127, 100, height));
		}
	}

	public void newNoteValue(int note) {
		super.newNoteValue(note);
		if (note == 4) {
			this.midiVertexEnabled = !this.midiVertexEnabled;
			this.midi.setControlLED(note, this.midiVertexEnabled);
		}
	}

	public void featureGotEnabled() {

	}
	
	public void drawFeature(int currentTimeState) {
  		int yPosition = height / 2;

    	drawSpectro(yPosition - this.midiLineSpacing);
	}

	public void drawSpectro(int yPosition) {
		pushMatrix();

 		ArrayList<Float> newLine = new ArrayList<Float>();
		for (int i=0; i < fftMain.avgSize(); i++) {
			float y = map(fftMain.getAvg(i), 0, 100, 100, 0) ;
			// smoothing
			if (i != 0) {
				y = (y + newLine.get(i-1))/2;
			}
			else if (i != 0 && i != fftMain.avgSize()-1) {
				y = (y + newLine.get(i-1) + newLine.get(i+1))/3;
			}
			newLine.add(y);
		}

		while (fftHistory.size() >= midiHistorySize) {
			fftHistory.removeLast();
		}
		fftHistory.addFirst(newLine);
		translate(0, yPosition, 0);


		int zSpacing = (400 / fftHistory.size());
		int z = 400;

		for(int currentLine = 0; currentLine < fftHistory.size(); currentLine++) {
			ArrayList<Float> lineToDraw = fftHistory.get(currentLine);
			if (midiHistorySize > 4) {
				z = z-zSpacing;
			}

			float bright = map(z, 400, 0, 100, 0);

			pushMatrix();
			if (midiVertexEnabled) {
				beginShape(TRIANGLE_STRIP);
			} else {
				beginShape();
			}
			strokeWeight(midiLineWidth);
			stroke(midi.hue, midi.saturation, bright);
			noFill();
			for(int i = 0; i < lineToDraw.size(); i++) {
				float value = lineToDraw.get(i);
				float x = map(i, 0, fftMain.avgSize(), 0, width);
				vertex(x, value, z);
				if (midiVertexEnabled && currentLine != 0) {
					float prevValue = fftHistory.get(currentLine-1).get(i);
					vertex(x, prevValue, z);
					vertex(x, value, z);
				}
			}
			endShape();
			popMatrix();	
		}
		popMatrix();
	}
}
