/*
	AudioSource
	Uses Minim to analyze signal of the default input device
 */

import ddf.minim.*;

public class AudioSource {
  private AudioInput audioInput = null;

  private float[] currentLeftSet;
  private float[] currentRightSet;
  private float[] currentCenterSet;


  public void useAudioInput(AudioInput i) {
    i.setGain(5.0);
    i.disableMonitoring();
    this.audioInput = i;
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
    return this.audioInput.bufferSize();
  }

  public void reframe() {
      this.currentLeftSet = this.audioInput.left.toArray();
      this.currentRightSet = this.audioInput.right.toArray();
      this.currentCenterSet = this.audioInput.mix.toArray();
  }
}
