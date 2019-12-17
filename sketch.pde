/*
Fall To Light

Main elements:

Data tree of floating particle nodes

Global bar-style visualizer in background

Global bass-driven center object (probably a subwoofer)

*/

static float bpm = 130;
static int threshold = 50;
static int offset = 0;
static int binCount = 144;
static float defaultMass = 20;
static float defaultVMult = 0.7;
static float fillMass = 15;
static float fillVMult = 0.6;
static float fftThreshold = 2;
static float fftPow = 1.5;
static float fftAmp = 2;
static float volumeGain = -25;
static String songName = "../Music/falltolight.mp3";

IColor defaultFill = new IColor(222,125,222,255);
IColor defaultStroke = new IColor(0,0,0,0);

NodePool nodes;
Source source;

void render() {
	nodes.update();
	nodes.render();
}

void addEvents() {
	
}

void setSketch() {
	nodes = new NodePool();
	source = new Source(new PVector(0,0,0));
	mobs.add(source);

	strokeWeight(5);
	strokeCap(ROUND);
	strokeJoin(MITER);
	front = new PVector(de*2,de,de*0.2);
  	back = new PVector(-de*2,-de,-aw);

  	nodes.add(new PVector(0,0,0));
}