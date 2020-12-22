/*
	VideoRecorder
	Feature that records the complete video as a file
	Currently disabled due to performance problems
 */

import java.util.Date;
import com.hamoid.*;
import ddf.minim.*;

public class VideoRecorder extends Feature {
	VideoExport videoExport;
	private boolean recorderEnabled = false;
	private boolean armBlinkState = false;

	AudioRecorder recorder;

	public VideoRecorder(PApplet applet, MidiInterface midi, int midiEnableFaderNumber) {
		super(applet, midi, midiEnableFaderNumber);
	}

	public void setupFeature() {

	}

	public void featureGotEnabled() {
    	Date d = new Date();
    	String filename = String.valueOf(d.getTime());

		AudioInput in = currentAudioSource.audioInput;
		recorder = minim.createRecorder(in, filename+".wav");  
		recorder.beginRecord();

		videoExport = new VideoExport(this.applet);
  		videoExport.setMovieFileName(filename+".mp4");
  		videoExport.setQuality(35, 128);
   	  	//videoExport.setDebugging(false);
  		videoExport.startMovie();
  		recorderEnabled = true;
	}

	public void featureGotDisabled() {
    	videoExport.endMovie();
    	recorder.endRecord();
    	recorder.save();
    	recorderEnabled = false;
  	}

	public void newFaderValue(int value, int number) {

	}

	public void drawFeature(int currentTimeState) {
		if (recorderEnabled) {
			videoExport.saveFrame();
		}

		if (recorderEnabled && (currentTimeState % 10) == 0) {
			armBlinkState = !armBlinkState;
		}
		midiInterface.setControlLED(midiEnableFaderNumber, armBlinkState);

	}
	
	public void newNoteValue(int note) {
		super.newNoteValue(note);
	}
}