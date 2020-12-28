/*
	MidiInterface
	Handles the communication with a Midi device. Supports Fader and Note mappings
 */

import themidibus.*;
import java.util.Map;

public static class MidiInterface {
	private static final MidiInterface INSTANCE = new MidiInterface();

	MidiBus myBus; // MidiMix Bus
	HashMap<Integer,ArrayList<Feature>> controllerMapping = new HashMap<Integer,ArrayList<Feature>>();
	HashMap<Integer,ArrayList<Feature>> noteMapping = new HashMap<Integer,ArrayList<Feature>>();

	public int hue = 0;
	public int saturation = 0;
	public int distanceBetweenWaveforms = 200;

	public static MidiInterface getInstance() {
		return INSTANCE;
	}

	private MidiInterface() {
		println("Initializing MidiInterface with following devices: ");
		MidiBus.list();

		myBus = new MidiBus(this, 0, 1);
		//disable all leds 
		for (int i = 0; i < 100; ++i) {
			this.setControlLED(i, false);
		}
	}


	public void registerForFaderValue(Feature feature, int inputNumber) {
		if (controllerMapping.containsKey(inputNumber)) {
			controllerMapping.get(inputNumber).add(feature);
		} else {
			ArrayList<Feature> featureList = new ArrayList<Feature>();
			featureList.add(feature);
			controllerMapping.put(inputNumber, featureList);
		}
	}

	void controllerChange(int channel, int number, int value) {
		if (controllerMapping.containsKey(number)) {
			for (Feature feature : controllerMapping.get(number)) {
				feature.newFaderValue(value, number);
			}
		}
		switch (number) {
			case 61:
				saturation = Math.round(map(value, 0, 127, 0, 100));
				if (saturation <= 10) saturation = 0;
			break;
			case 60:
				hue = Math.round(map(value, 0, 127, 0, 360));
			break;
			case 19:
				distanceBetweenWaveforms = Math.round(map(value, 0, 127, 400, 0));
			break;	
  		}
	}

	public void registerForNoteValue(Feature feature, int pitch) {
		if (noteMapping.containsKey(pitch)) {
			noteMapping.get(pitch).add(feature);
		} else {
			ArrayList<Feature> featureList = new ArrayList<Feature>();
			featureList.add(feature);
			noteMapping.put(pitch, featureList);
		}
	}

	public void noteOff(int channel, int pitch, int velocity) {
		if (channel != 0) return;
		if (noteMapping.containsKey(pitch)) {
			for (Feature feature : noteMapping.get(pitch)) {
				feature.newNoteValue(pitch);
			}
		}
	}

	public void setControlLED(int note, boolean state) {
		if (state == true) {
			this.myBus.sendMessage(0x90, (byte)note, 0x7F);	
		} else {
			this.myBus.sendMessage(0x90, (byte)note, 0x00);
		}
  	}
	
}
