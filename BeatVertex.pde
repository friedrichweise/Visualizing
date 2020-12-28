/*
	BeatVertex
	Feature that renders a vertex which resize on detected beats by Minim
 */

public class BeatVertex extends Feature {
	float hatSizeVertex = 200;
	float snareSizeVertex = 100;

	private float midiBeatVertexScaling = 0.0;
	private float midiLineWidth = 7.0;
	private float midiRotateSpeed = 0.0;
	private boolean midiFillEnabled = false;
	private float vertexRotation = 0;

	public BeatVertex(PApplet applet, MidiInterface midi, int midiEnableFaderNumber) {
		super(applet, midi, midiEnableFaderNumber);
	}

	public void setupFeature() {
		midi.registerForFaderValue(this, 27);
		midi.registerForNoteValue(this, 7);

		midi.registerForFaderValue(this, 25);
		midi.registerForFaderValue(this, 24);
	}

	public void newFaderValue(int value, int number) {
		if (number == 27) {
      		midiBeatVertexScaling = map(value, 0, 127, 0.0, 2.0);
		}
		if (number == 25) {
			midiLineWidth = map(value, 0, 127, 0, 20);
		}
		if (number == 24) {
			midiRotateSpeed = map(value, 0, 127, 0.0, 0.1);
		}
	}

	public void newNoteValue(int note) {
		super.newNoteValue(note);
		if (note == 7) {
			midiFillEnabled = !midiFillEnabled;
			this.midi.setControlLED(note, this.midiFillEnabled);
		}
	}

	public void featureGotEnabled() {

	}

	public void drawFeature(int currentTimeState) {
		vertexRotation = vertexRotation+midiRotateSpeed % 360;

		PShape beatVertex;  // The PShape object

		int vHeight = 200;
		int vWidth = 75;
		beatVertex = createShape();
		beatVertex.beginShape(TRIANGLE_STRIP);
		beatVertex.vertex(0, vHeight, 0);  //A
		beatVertex.vertex(0, 0, -vWidth);      //B
		beatVertex.vertex(0, -vHeight, 0);    //F
		beatVertex.vertex(0, 0, vWidth);       //D
		beatVertex.vertex(0, vHeight, 0);  //A

		beatVertex.vertex(vWidth, 0, 0);     //C
		beatVertex.vertex(0, -vHeight, 0);    //F
		beatVertex.vertex(-vWidth, 0, 0);       //E
		beatVertex.vertex(0, vHeight, 0);  //
		if (!midiFillEnabled) {
			beatVertex.noFill();
		}
		beatVertex.endShape();


		if (beat.isKick() ) hatSizeVertex = 400;

		int centerX = currentAudioSource.getBufferSize()/2;
		int centerY = height/2;
		beatVertex.setStrokeWeight(this.midiLineWidth);
		if (midiFillEnabled) {
			beatVertex.setFill(color(midi.hue, midi.saturation, 100));
			beatVertex.setStroke(color(0,0,100));
		} else {
			beatVertex.setStroke(color(midi.hue, midi.saturation, 100));
		}
		beatVertex.rotateY(vertexRotation);
		pushMatrix();
		translate(0, 0, 200);
		shape(beatVertex, centerX, centerY, Math.round(hatSizeVertex * midiBeatVertexScaling), Math.round(400*midiBeatVertexScaling));
		popMatrix();
		hatSizeVertex = constrain(hatSizeVertex * 0.98, 100, 400);
	}
}
