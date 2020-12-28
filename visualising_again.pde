import processing.opengl.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import java.util.LinkedList;

Minim minim;
BeatDetect beat;
FFT fftMain;
AudioSource currentAudioSource = new AudioSource();

/* buffer Size for AudioInput -> defines x span of waves */
int bufferSize = 2048;
float sampleRate = 44100.0f;
final MidiInterface midiInterface = MidiInterface.getInstance();;

ArrayList<Feature> features = new ArrayList<Feature>();

void setup() {
  // base setup
  size(displayWidth, displayHeight, P3D);
  //size(1280,720, P3D);
  //fullScreen(P3D, 0);
  surface.setResizable(false);
  frameRate(30);
  colorMode(HSB);
  colorMode(HSB, 360, 100, 100, 100); 

  // audio input //
  minim = new Minim(this);
  AudioInput input;
  input = minim.getLineIn(Minim.STEREO, bufferSize);
  currentAudioSource.useAudioInput(input);

  // features //
  fftMain = new FFT (input.bufferSize (), input.sampleRate ());
  fftMain.logAverages(9, 30);

  beat = new BeatDetect(bufferSize, sampleRate);
  beat.setSensitivity(300);

  CameraController camera = new CameraController(this, midiInterface, -1);
  camera.enabled = true;
  features.add(camera);

  VideoPlayer videoPlayer = new VideoPlayer(this, midiInterface, 15);
  features.add(videoPlayer);

  VideoEffectController vidFX = new VideoEffectController(this, midiInterface, 18) ;
  features.add(vidFX);

  Waveform wave = new Waveform(this, midiInterface, 3);
  wave.enabled = true;
  midiInterface.setControlLED(3, true);
  features.add(wave);

  Spectro spectro = new Spectro(this, midiInterface, 6);
  features.add(spectro);
  
  BeatVertex beatVertex = new BeatVertex(this, midiInterface, 9);
  features.add(beatVertex);

  BeatBoxes beatBoxes = new BeatBoxes(this, midiInterface, 12);
  features.add(beatBoxes);

  PostFXController postFX = new PostFXController(this, midiInterface, 21) ;
  features.add(postFX);

  //VideoRecorder videoRecorder = new VideoRecorder(this, midiInterface, 24);
  //features.add(videoRecorder);
}

private int currentRun = 0;
void draw() {
  currentRun++;
  if (currentRun == 800) {
    currentRun = 0;
  }
  if (frameRate < 25) {
    midiInterface.setControlLED(22, true);
  } else {
    midiInterface.setControlLED(22, false);
  }
  background(0);
  lights();

  beat.detect(currentAudioSource.getBufferForCenter());
  fftMain.forward(currentAudioSource.getBufferForCenter());
  // draw features
  for (Feature feature : features) {
    if (feature.enabled) {
      pushStyle();
      feature.drawFeature(currentRun);
      popStyle();
    }
  }
}

void keyPressed() {
  if (key == CODED) {
    for (Feature feature : features) {
      if (feature.enabled) {
        feature.keyPressed(keyCode);
      }
    }
  }
}