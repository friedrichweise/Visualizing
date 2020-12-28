/*
  Feature
  Abstract class to implement specific features
 */

public abstract class Feature {
	private String name;
  public PApplet applet;
  public MidiInterface midi;
  private boolean enabled = false;
  public int midiEnableFaderNumber;

	public Feature(PApplet applet, MidiInterface midi, int midiEnableFaderNumber) {
    	this.applet = applet;
    	this.midi = midi;
      this.midiEnableFaderNumber = midiEnableFaderNumber;
      if (midiEnableFaderNumber != -1) {
        this.midi.registerForNoteValue(this, midiEnableFaderNumber);
      }
		  println("Initializing Feature: ", this.getClass().getSimpleName());
      this.setupFeature();
	}

  public void enableFeature() {
    this.enabled = true;
    println("Enabled Feature:    ", this.getClass().getSimpleName());
    this.featureGotEnabled();
  }
  public void disableFeature() {
    this.enabled = false;
    println("Disabled Feature:   ", this.getClass().getSimpleName());
    //this.featureGotDisabled();
  }
  public boolean isEnabled() {
    return this.enabled;
  }

	public abstract void setupFeature();
  
	public abstract void drawFeature(int currentTimeState);
  
  public abstract void newFaderValue(int value, int number);
  
  public abstract void featureGotEnabled();

  public void keyPressed(int keyCode) {
    return;
  }

  public void newNoteValue(int note) {  
    if (note == this.midiEnableFaderNumber) {
      if (this.enabled) {
        this.disableFeature();
        this.midi.setControlLED(note, false);
      } else {
        this.enableFeature();
        this.midi.setControlLED(note, true);
      }
    }
  }
}
