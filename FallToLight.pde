import ddf.minim.analysis.*;
import ddf.minim.*;

Minim mim;
AudioPlayer song;
ddf.minim.analysis.FFT fft;
float[] av = new float[binCount];
float max;
float avg;

// Events initialize and store all of their own mobs
ArrayList<Event> events = new ArrayList<Event>();

// Used to store global animation entities
ArrayList<Entity> mobs = new ArrayList<Entity>();

Camera cam;
static int de;
static int aw;
static PVector front;
static PVector back;


BeatTimer timer;
int currTime;
int currBeat;
static float fpb;

static float cos60 = cos(PI/3);

void setup() {
  size(1000,1000,P3D);
  de = (int)(min(width,height)*1);
  aw = (int)(4*de);

  cam = new Camera(de/2,de/2,-de*1.2);
  cam.ang.P.set(0,0,0);

  textSize(de/10);

  rectMode(CENTER);
  textAlign(CENTER);

  mim = new Minim(this);
  song = mim.loadFile(songName, 1024);
  fft = new FFT(song.bufferSize(), song.sampleRate());

  timer = new BeatTimer(threshold,offset,bpm);
  fpb = 3600/bpm;
  
  song.loop();
  song.setGain(volumeGain);

  setSketch();
  addEvents();
}

void draw() {
  background(0);
  cam.render();
  update();

  render();

  for (Entity mob : mobs) {
    if (mob.draw) mob.render();
  }

  // fill(255);
  //drawBorders();
  //drawWidthBox(de);
  //drawPitches();
  // push();
  // translate(0,de*0.75,0);
  // text(source.nodes.arm + " " + (int)frameRate,0,0);
  // pop();
}

void update() {
  calcFFT();

  currTime = song.position();
  if (timer.beat) currBeat ++;

  cam.update();
  timer.update();

  updateEvents();
  updateMobs();
}

void updateEvents() {
  for (int i = 0 ; i < events.size() ; i ++) {
    Event event = events.get(i);
    if (!event.finished) {
        if (currBeat >= event.time && currBeat < event.timeEnd) {
          if (!event.spawned) {
            event.spawned = true;
            event.spawn();
          }
          event.update();
          event.render();
        } else if (currBeat >= event.timeEnd) {
            event.finished = true;
            event.end();
        }
    }
  }
}

void updateMobs() {
  for (Entity mob : mobs) {
    mob.update();
  }
  for (int i = 0 ; i < mobs.size() ; i ++) {
    if (mobs.get(i).finished) mobs.remove(i);
  }
}

void calcFFT() {
  fft.forward(song.mix);

  avg = 0;
  max = 0;
  float temp;
  for (int i = 0 ; i < av.length ; i ++) {
    temp = 0;
    for (int k = i ; k < fft.specSize() ; k += i + 1) {
      temp += fft.getBand(k);
    }
    temp /= av.length / (i + 1);
    temp = pow(temp,fftPow);
    avg += temp;
    av[i] = temp;
  }
  avg /= av.length;

  for (int i = 0 ; i < av.length ; i ++) {
    if (av[i] < avg*fftThreshold) {
      av[i] /= fftAmp;
    } else {
      av[i] += (av[i] - avg * fftThreshold) /fftAmp;
    }
    if (av[i] > max) max = av[i];
  }
}

void mousePressed() {
  float temp = ((float)mouseX / width) * song.length();
  int tempBeat = (int)((temp-timer.offset)/60000.0*bpm);
  for (Event event : events) {
    if (tempBeat <= event.time) {
      event.spawned = false;
      event.finished = false;
    }
    if (currBeat >= event.time && currBeat < event.timeEnd) {
      if (tempBeat < event.time || tempBeat >= event.timeEnd) event.end();
    }
  }
  song.cue((int)temp);
  currBeat = tempBeat;
}

void keyPressed() {
  if (key == 'e') {
    if (!cam.lock) {
      cam.lock = true;
      cam.ang.P.set(cam.dang.x, cam.dang.y, cam.dang.z);
    } else {
      cam.lock = false;
    }
    println("Cam lock: " + cam.lock);
  } else {
    println("KEY: " + key + " " + currTime + " " + currBeat + " " + frameRate);
    keyboardInput();
  }
}

void drawPitches() {
  push();
  fill(255);
  noStroke();
  translate(0,0,0);
  for (int i = 0 ; i < binCount ; i ++) {
    float w = width/(float)binCount;
    translate(w, 0,0);
    rect(0,0,w,av[i]*10);
  }
  pop();
}

void drawBorders() {
  noFill();
  stroke(255);
  push();
  translate(0,0,-aw);
  rect(0,0,de*2,de*2);
  pop();
  line(de,de,aw,de,de,-aw);
  line(de,-de,aw,de,-de,-aw);
  line(-de,de,aw,-de,de,-aw);
  line(-de,-de,aw,-de,-de,-aw);
}

void drawWidthBox(float w) {
  push();
  textSize(w/10);
  push();
  translate(0,0,0);
  text("0,0,0",0,0);
  pop();

  push();
  translate(w,w,w);
  text("1,1,1",0,0);
  pop();

  push();
  translate(-w,w,w);
  text("-1,1,1",0,0);
  pop();

  push();
  translate(-w,-w,w);
  text("-1,-1,1",0,0);
  pop();

  push();
  translate(w,-w,w);
  text("1,-1,-1",0,0);
  pop();

  push();
  translate(w,w,-w);
  text("1,1,-1",0,0);
  pop();

  push();
  translate(-w,w,-w);
  text("-1,1,-1",0,0);
  pop();

  push();
  translate(-w,-w,-w);
  text("-1,-1,-1",0,0);
  pop();

  push();
  translate(w,-w,-w);
  text("1,-1,-1",0,0);
  pop();
  pop();
}