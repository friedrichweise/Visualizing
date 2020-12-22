/*
  Feature
  Abstract class to implement specific features
 */

public abstract class Feature {
	private String name;
  	public PApplet applet;
  	public MidiInterface midi;
  	public boolean enabled = false;
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

	public abstract void setupFeature();
  
	public abstract void drawFeature(int currentTimeState);
  
  public abstract void newFaderValue(int value, int number);
  
  public abstract void featureGotEnabled();

  public void keyPressed(int keyCode) {
    return;
  }

  public void featureGotDisabled() {
    
  }

  public void newNoteValue(int note) {  
    if (note == this.midiEnableFaderNumber) {
        this.enabled = !this.enabled;
        this.midi.setControlLED(note, this.enabled);
        if (this.enabled) {
          this.featureGotEnabled();
          println("Enabled Feature:    ", this.getClass().getSimpleName());
        } else {
          this.featureGotDisabled();
          println("Disabled Feature:   ", this.getClass().getSimpleName());
        }
      }
  }
}
