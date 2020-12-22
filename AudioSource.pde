/*
	AudioSource
	Uses Minim to analyze signal of the default input device
 */

import ddf.minim.*;

public class AudioSource {
  private AudioPlayer audioPlayer = null;
  private AudioInput audioInput = null;
  //scales every buffer value -> depending on input device
  private int valueScale;

  private float[] currentLeftSet;
  private float[] currentRightSet;
  private float[] currentCenterSet;

  public void useAudioPlayer(AudioPlayer p) {
    println("Use AudioPlayer");
    this.audioPlayer = p;
    this.audioInput = null;
    this.valueScale = 100;
  }

  public void useAudioInput(AudioInput i) {
    println("Use AudioInput");
    i.setGain(5.0);
    i.disableMonitoring();
    this.audioInput = i;
    this.audioPlayer = null;
    this.valueScale = 5000;
  }

  public float getLeft(int i) {
    return this.currentLeftSet[i];
  }

  public float getRight(int i) {
    return this.currentRightSet[i];
  }

  public float getCenter(int i) {
    return this.currentCenterSet[i];
  }

  public AudioBuffer getBufferForCenter() {
    return this.audioInput.mix;
  }
  
  public int getBufferSize() {
    if (this.audioPlayer == null && this.audioInput != null) {
      return this.audioInput.bufferSize();
    } else if (this.audioInput == null && this.audioPlayer != null)  {
      return this.audioPlayer.bufferSize();
    } else return 0;
  }

  public void reframe() {
    if (this.audioInput != null) {
      this.currentLeftSet = this.audioInput.left.toArray();
      this.currentRightSet = this.audioInput.right.toArray();
      this.currentCenterSet = this.audioInput.mix.toArray();
    }
    else if (this.audioPlayer != null) {
      this.currentLeftSet = this.audioPlayer.left.toArray();
      this.currentRightSet = this.audioPlayer.right.toArray();
      this.currentCenterSet = this.audioPlayer.mix.toArray();      
    }
  }
}
