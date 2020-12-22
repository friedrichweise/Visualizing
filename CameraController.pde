/*
	CameraController
	Defines position of the camera; including multiple camera modes (center, user defined, moving)
 */

public class CameraController extends Feature {
	private int midiYCameraPosition = 0;
	private int midiXCameraPosition = 0;
	private boolean midiFixedCameraMode = true;
	private int cameraSpan = 500;
	private boolean midiMovingCameraMode = false;
	private int midiCameraZoom = 0;

	public CameraController(PApplet applet, MidiInterface midi, int midiEnableFaderNumber) {
		super(applet, midi, midiEnableFaderNumber);
	}

	public void setupFeature() {
		midi.registerForNoteValue(this, 25);
		midi.registerForNoteValue(this, 26);
		midi.registerForFaderValue(this, 58); 
		midi.registerForFaderValue(this, 59); 
		midi.registerForFaderValue(this, 62); 

		midi.setControlLED(25, true);
	}

	public void newFaderValue(int value, int number) {
		if (number == 58) {
			midiYCameraPosition = Math.round(map(value, 127, 0, (height/2)-cameraSpan, (height/2)+cameraSpan));
		}
		if (number == 59) {
			midiXCameraPosition = Math.round(map(value, 0, 127, (width/2)-cameraSpan, (width/2)+cameraSpan));
		}
		if (number == 62) {
			midiCameraZoom = Math.round(map(value, 0, 127, 0, 200));
		}
	}
	
	public void newNoteValue(int note) {
		super.newNoteValue(note);
		if (note == 25) {
			this.midiFixedCameraMode = !this.midiFixedCameraMode;
			this.midi.setControlLED(note, this.midiFixedCameraMode);
		}
		if (note == 26) {
			this.midiMovingCameraMode = !this.midiMovingCameraMode;
			this.midi.setControlLED(note, this.midiMovingCameraMode);
		}
	}

	public void featureGotEnabled() {

	}

	public void drawFeature(int currentTimeState) {
		float eyeZ = ((height/2)-midiCameraZoom) / tan(PI/6);

		if (midiMovingCameraMode == true) {
			int cameraYPost = Math.round((sin((float)currentTimeState*0.05)*230)+ (height/2));
			int cameraXPost = Math.round((cos((float)currentTimeState*0.05)*200)+800);
			camera(cameraXPost, cameraYPost, eyeZ, bufferSize/2, height/2, 0, 0, 1, 0);
		}
		else if (midiFixedCameraMode == true) {
			// fixed center camera mode
			// eye, center
			camera(bufferSize/2, height/2, eyeZ, bufferSize/2, height/2, 0, 0, 1, 0);
		} else {
			// Midi Based Camera
			camera(midiXCameraPosition, midiYCameraPosition, eyeZ, bufferSize/2, height/2, 0, 0, 1, 0);    
		}

		// Mouse Camera Mode
		//int mouseXPosition = Math.round(map(mouseX, 0, displayWidth, (bufferSize/2)-cameraSpan, (bufferSize/2)+cameraSpan));
		//int mouseYPosition = Math.round(map(mouseY, 0, displayHeight, (height/2)-cameraSpan, (height/2)+cameraSpan));
		//camera(mouseXPosition, mouseYPosition, (displayHeight/2) / tan(PI/6), bufferSize/2, displayHeight/2, 0, 0, 1, 0);
	}

}
