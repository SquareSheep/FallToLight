/*
Fall To Light

Main elements:

Floating particle nodes

Flashing line between nodes

List of force diagrams

--------------------------
Additional elements:

Global bar-style visualizer in background

Global bass-driven source object (probably a subwoofer)

*/

static float bpm = 130;
static int threshold = 50;
static int offset = 0;
static int binCount = 144;
static float defaultMass = 20;
static float defaultVMult = 0.5;
static float fillMass = 10;
static float fillVMult = 0.35;
static float fftThreshold = 1.5;
static float fftPow = 1.3;
static float fftAmp = 5;
static float volumeGain = -10;
static String songName = "../Music/falltolight.mp3";

IColor defaultFill = new IColor(0,0,0,0, 5,5,5,5,-1);
IColor defaultStroke = new IColor(0,0,0,0, 5,5,5,5,-1);

Source source;

void render() {
	
}

void addEvents() {
	
}

void setSketch() {
	source = new Source(new PVector(0,0,0));
	mobs.add(source);

	strokeWeight(1);
	strokeCap(ROUND);
	strokeJoin(MITER);
	front = new PVector(de,de,de*0.5);
  	back = new PVector(-de,-de,-de*0.5);
}