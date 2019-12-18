class NodeFillGraph1 extends Function<Node> {
	void set(Node obj) {
		float x = abs(obj.p.p.x)/de;
		float y = abs(obj.p.p.y)/de;
		obj.fillStyle.setC(x*255,y*125+125,(x+y)*125,255);
	}
}
class NodeIndexGraph1 extends Function<Node> {
	void set(Node obj) {
		 obj.w.index = ((int)(abs(obj.p.p.x + obj.p.p.y)/de*binCount))%binCount;
	}
}

abstract class Function<T> {
	abstract void set(T obj);
}

class Source extends Entity {
	int spawnRate = 5;
	float spawnAmp = 0.1;
	SpringValue lightDist;

	NodePool nodes;
	LightPool lights;

	// IndexFunctionGraphs[]
	// FillStyleFunctionGraphs[]
	// VelocityFunctionGraphs[]
	// ...

	Source(PVector p) {
		lightDist = new SpringValue(de*0.1, 0.2,30);
		nodes = new NodePool();
		lights = new LightPool();
	}

	void render() {
		nodes.render();
		lights.render();
	}

	void update() {
		nodes.update();
		lights.update();
		lightDist.update();

		if (frameCount % spawnRate == 0) {
			for (int i = 0 ; i < spawnAmp*avg ; i ++) {
				nodes.add(new PVector(random(back.x,front.x), random(back.y,front.y), random(back.z,front.z)));
			}
		}

		lightDist.X = avg*5+de*0.1;
		if (nodes.arm > 1) {
			Node a; Node b; int count;
			for (int o = 0 ; o < 1 ; o ++) {

				a = nodes.get((int)random(nodes.arm));
				for (int i = 0 ; i < 3 ; i ++) {
					b = a;
					a = nodes.get((int)random(nodes.arm));
					count = 0;

					while (count < nodes.arm/4 && (a == b || abs(a.p.p.x - b.p.p.x) > lightDist.x
						|| abs(a.p.p.y - b.p.p.y) > lightDist.x || abs(a.p.p.z - b.p.p.z) > lightDist.x)) {
						a = nodes.get((int)random(nodes.arm));
						count ++;
					}

					if (count >= nodes.arm/4 -2) break;
					lights.add(a,b);
				}
			}
		}
	}
}

class LightPool extends ObjectPool<Light> {

	int currIndexGraph = 0;

	void set(Light light, Node a, Node b) {
		light.a = a;
		light.b = b;
		light.lifeSpan = 30;
		light.maxLife = light.lifeSpan;
		light.finished = false;
		light.draw = true;
	}

	void add(Node a, Node b) {
		if (arm == ar.size()) {
			ar.add(0,new Light());
			set(getLast(),a,b);
		} else {
			set(ar.get(arm),a,b);
		}
		arm ++;
	}

	void update() {
		super.update();
		for (int i = 0 ; i < arm ; i ++) {
			Light light = ar.get(i);
		}
	}
}

class Light extends Entity {
	Node a;
	Node b;
	IColor strokeStyle;
	float lifeSpan;
	float maxLife;

	Light() {
		strokeStyle = new IColor();
	}

	void update() {
		lifeSpan -= avg/10;
		strokeStyle.update();
		if (lifeSpan <= 0 || a.finished || b.finished) this.finished = true;
	}

	void render() {
		float dx = (b.p.p.x - a.p.p.x);
		float dy = (b.p.p.y - a.p.p.y);
		float dz = (b.p.p.z - a.p.p.z);
		float tick = (float)(maxLife-lifeSpan)/maxLife;
		push();
		translate(a.p.p.x + dx*tick, a.p.p.y + dy*tick, a.p.p.z + dz*tick);
		circle(0,0,(a.w.x+b.w.x)/2);
		pop();

	}
}

class NodePool extends ObjectPool<Node> {
	float vs = 4;

	int currIndexGraph = 0;
	Function[] indexGraphs = {new NodeIndexGraph1()};

	int currFillGraph = 0;
	Function[] fillGraphs = {new NodeFillGraph1()};

	void set(Node node, PVector p) {
		node.p.reset(p.x,p.y,p.z);
		node.finished = false;
		node.draw = true;
		node.pv.reset(random(-vs,vs),random(-vs,vs),random(-vs, vs));
		node.w.x = 0;
		node.w.X = -3;
		node.w.xm = 3;
		node.lifeSpan = 600;
	}

	void add(PVector p) {
		if (arm == ar.size()) {
			ar.add(0,new Node());
			set(getLast(), p);
		} else {
			set(ar.get(arm), p);
		}
		arm ++;
	}

	void update() {
		for (int i = 0 ; i < arm ; i ++) {
	      Node mob = ar.get(i);

	      mob.lifeSpan --;

	      indexGraphs[currIndexGraph].set(mob);
	      fillGraphs[currFillGraph].set(mob);

	      if (mob.lifeSpan <= 0) mob.finished = true;
	      if (mob.p.p.x > front.x || mob.p.p.x < back.x) mob.finished = true;
	      if (mob.p.p.y > front.y || mob.p.p.y < back.y) mob.finished = true;
	      if (mob.p.p.z > front.z || mob.p.p.z < back.z) mob.finished = true;
	    }
		super.update();
	}
}

class Node extends MobF {
	SpringValue w;

	Node() {
		this.p = new Point();
		this.w = new SpringValue(0, 0.5,10);
	}

	void update() {
		super.update();
		w.update();
	}

	void render() {
		if (w.x > 0) {
			setDraw();
			circle(0,0,w.x);
			pop();
		}
	}
}