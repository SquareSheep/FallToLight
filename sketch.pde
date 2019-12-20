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
static float defaultMass = 30;
static float defaultVMult = 0.5;
static float fillMass = 5;
static float fillVMult = 0.5;
static float fftThreshold = 1.5;
static float fftPow = 1.3;
static float fftAmp = 5;
static float volumeGain = -10;
static String songName = "../Music/falltolight.mp3";

IColor defaultFill = new IColor(0,0,0,0, 5,5,5,5,-1);
IColor defaultStroke = new IColor(0,0,0,0, 5,5,5,5,-1);

FallingLight source;

void render() {
	
}

void addEvents() {
	
}

void keyboardInput() {
	if (key == '1') {
		source.nodes.currPGraph = 0;
	} else if (key == '2') {
		source.nodes.currPGraph = 1;
	}
}

void setSketch() {
	source = new FallingLight(0,0,0, de*0.5,de*0.5,de*0.1);
	mobs.add(source);

	strokeWeight(6);
	strokeCap(ROUND);
	strokeJoin(MITER);
	noStroke();
	float mult = 0.75;
	front = new PVector(de*mult,de*mult,de*mult);
  	back = new PVector(-de*mult,-de*mult,-de*mult);
}