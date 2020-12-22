/*
	VideoPlayer
	Feature that allows playback of videos, including as an caleidoscope
 */

import processing.video.*;

public class VideoPlayer extends Feature {
	float scale = 1.0;
	private int midiCurrentOpacity = 0;
	private float midiVideoSpeed = 1.0;
	private Capture cam;
	ArrayList<String> movies;
	Movie currentMovie = null;

	// caleidoscope
	int slices = 20;
	float angle = PI/slices;
	PShape mySlice;
	float radius;
	float offset = 0;

	private PApplet applet;
	HashMap<Integer, String> movieMappings;


	public VideoPlayer(PApplet applet, MidiInterface midi, int midiEnableFaderNumber) {
		super(applet, midi, midiEnableFaderNumber);
		this.applet = applet;
	}

	public void setupFeature() {
		radius = max(width, height)/2;

		// simple movie list for MidiMix
		ArrayList<String> movies;
		this.movies = new ArrayList<String>();


		String[] cameras = Capture.list();
  
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
    
    // The camera can be initialized directly using an 
    // element from the array returned by list():
    cam = new Capture(this.applet, cameras[0]);
    cam.start();     
  }      

		println("Initalizing Video Files:");
		File dir = new File(dataPath(""));
		String[] children = dir.list();
		if (children == null) {
			println("Error: No files found in data folder");
		} else {
 			for (int i=0; i<children.length; i++) {
				// Get filename of file or directory
				String filename = children[i];
				if (filename.endsWith("mov") || filename.endsWith("mp4")) {
					println("Init Video: ", filename);
					this.movies.add(filename);
				}
			}
		} 

		midi.registerForFaderValue(this, 49);
		midi.registerForFaderValue(this, 48);
		midi.registerForFaderValue(this, 47);
		midi.registerForFaderValue(this, 46);
		midi.registerForNoteValue(this, 13);
			}

	public void featureGotEnabled() {

	}

	public void newFaderValue(int value, int number) {
		if (number == 49) {
			midiCurrentOpacity = Math.round(map(value, 0, 127, 0, 100));
		}
		if (number == 48) {
			//@todo
		}
		if (number == 47) {
			slices = Math.round(map(value, 0, 127, 0, 30));
			angle = PI/slices;
		}
		if (number == 46) {
			midiVideoSpeed = map(value, 0, 127, 0, 2);
			if (currentMovie != null) {
				//currentMovie.speed(midiVideoSpeed);
			}
		}
	}

	public void drawFeature(int currentTimeState) {
		if (cam.available() == true) {
   			 cam.read();
  		}
  		set(0, 0, cam);
		if (currentMovie != null) {
			if (currentMovie.available()) {
				currentMovie.read();
			}

			if (slices <= 1) {
				this.renderVideo();
			} else {
				this.renderCaleidoscope();
			}
		}
	}

	private void renderVideo() {
		int x = Math.round((bufferSize/2) - (width * 0.5));
		tint(midiCurrentOpacity, midiCurrentOpacity);
		//tint(midi.hue, midi.saturation, midiCurrentOpacity);
		image(currentMovie, x, 0, width, height);
	}

	  // from Key25
    public void newVideoMappingNoteValue(int note) {
        //String fileName = movieMappings.get(note);
       // this.initNewVideo(fileName);
    }

	private void renderCaleidoscope() {
		offset+=PI/180;	

		mySlice = createShape();
		mySlice.beginShape();
			mySlice.tint(midiCurrentOpacity, midiCurrentOpacity);
			mySlice.texture(currentMovie);
			mySlice.noStroke();
			mySlice.vertex(0, 0, currentMovie.width/2, currentMovie.height/2);
			mySlice.vertex(cos(angle)*radius, sin(angle)*radius, cos(angle+offset)*radius+currentMovie.width/2, sin(angle+offset)*radius+currentMovie.height/2);
			mySlice.vertex(cos(-angle)*radius, sin(-angle)*radius, cos(-angle+offset)*radius+currentMovie.width/2, sin(-angle+offset)*radius+currentMovie.height/2);
		mySlice.scale(1.5);
		mySlice.endShape();
		pushMatrix();
		translate(bufferSize/2, height/2);
		for (int i = 0; i < slices; i++) {
			rotate(angle*2);
			shape(mySlice);
		}
		popMatrix();
	}

	int keyNavPosition = 0;
	public void keyPressed(int keyCode) {
		if (keyCode == 37) { // RIGHT
			this.keyNavPosition++;
		} else if (keyCode == 39) { // LEFT
			this.keyNavPosition--;
		}
		if (this.keyNavPosition < 0) this.keyNavPosition = movies.size() -1;
		if (this.keyNavPosition > movies.size() -1) this.keyNavPosition = 0;
		println("SELECT: "+movies.get(this.keyNavPosition));
	}

	public void newNoteValue(int note) {
		super.newNoteValue(note);

		if (note == 13) {
			this.initNewVideo(this.movies.get(keyNavPosition));
		}
	}

	public void initNewVideo(String fileName) {
		if (fileName == null || fileName.length() == 0) {
			return;
		}
		if (currentMovie != null) {
			currentMovie.stop();
		}
		currentMovie = new Movie(this.applet, fileName);
		currentMovie.volume(0);
		currentMovie.loop();
		println("Loaded and started movie: ", fileName, " ("+ currentMovie.duration()+")");
	}
}