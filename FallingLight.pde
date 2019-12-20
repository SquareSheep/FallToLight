class FallingLight extends Entity {
	float size;
	PVector fr;
	PVector ba;
	PVector p;

	Node center;
	int nofNodes;
	NodePool nodes;
	float nodeWX;
	int nodeLifeSpan = 1200;

	LightPool lights;
	int nofLights;	
	float lightDistMax;
	float lightDistMin;
	int lightNof = 2;
	float lightLifeSpan = 120;
	float amp;

	FallingLight(float x, float y, float z, float w, float h, float d) {
		p = new PVector(x,y,z);
		fr = new PVector(w,h,d);
		ba = new PVector(-w,-h,-d);
		size = (w+h)/2;

		center = new Node();
		center.p.reset(x,y,z);

		nofNodes = (int)sqrt(size);
		nodeWX= -size*0.005;

		lightDistMax = size;
		lightDistMin = size*0.05;

		amp = size * 0.001;

		nodes = new NodePool();
		lights = new LightPool();
	}

	void render() {
		push();
		translate(p.x,p.y,p.z);
		lights.render();
		nodes.render();
		pop();
	}

	void update() {
		center.update();

		nodes.update();
		if (nodes.arm != nofNodes) {
			while (nodes.arm < nofNodes) {
				nodes.add(new PVector(random(-size,size), random(-size,size), random(-size,size)));
			}
			while (nodes.arm > nofNodes) {
				nodes.remove(0);
			}
		}

		lights.update();
		for (int i = 0 ; i < lights.arm ; i ++) {
			Light light = lights.ar.get(i);
			if (light.finished) {
				lights.remove(i);
				if (light.nof > 0) {
					Node a = light.b;
					findNodeBforA(light.b, a);
					lights.add(light.b, nodes.get((int)random(nodes.arm)), light.nof-1);
				}
			}
		}

		nofLights = (int)((max + avg)/2);
		while (lights.arm < nofLights) {
			Node a; Node b; int count;
			a = center;
			b = nodes.get((int)random(nodes.arm));
			findNodeBforA(a,b);
			lights.add(a,b, lightNof);
		}
	}

	void findNodeBforA(Node a, Node b) {
		int count = 0;
		while (count < nodes.arm/4 && (a == b || abs(a.p.p.x - b.p.p.x) < lightDistMax
			|| abs(a.p.p.y - b.p.p.y) < lightDistMax || abs(a.p.p.z - b.p.p.z) < lightDistMax)
			&& (a == b || abs(a.p.p.x - b.p.p.x) > lightDistMin
			|| abs(a.p.p.y - b.p.p.y) > lightDistMin || abs(a.p.p.z - b.p.p.z) > lightDistMin)) {
			b = nodes.get((int)random(nodes.arm));
			count ++;
		}
	}

	class LightFillGraph1 extends Function<Light> {
		void set(Light obj) {
			float x = abs(obj.b.p.p.x)/size;
			float y = abs(obj.b.p.p.y)/size;
			obj.fillStyle.setC(y*55,(x+y)*25,x*55,255);
			obj.fillStyle.setM(y*5,(x+y)*5,x*5,0, abs(obj.b.p.p.x/size*binCount)%binCount);
		}
	}

	class NodeFillGraph1 extends Function<Node> {
		void set(Node obj) {
			float x = abs(obj.p.p.x)/size;
			float y = abs(obj.p.p.y)/size;
			obj.fillStyle.setC(y*255,(x+y)*125,x*255,255);
		}
	}

	class NodePGraph2 extends Function<Node> {
		float speed = -size*0.001;
		void set(Node obj) {
			float x = obj.p.p.y/(obj.p.p.x+size*2)*amp;
			float y = obj.p.p.x/(obj.p.p.y+size*2)*amp;
			obj.pv.P.x = x + speed;
			obj.pv.P.y = y + speed;
			obj.pv.P.z = -y;
		}
	}

	class NodePGraph1 extends Function<Node> {
		void set(Node obj) {
			float x = obj.p.p.x/size*amp;
			float y = obj.p.p.y/size*amp;
			obj.pv.P.x = x;
			obj.pv.P.y = y;
			obj.pv.P.z = 1;
		}
	}

	class NodeWGraph1 extends Function<Node> {
		void set(Node obj) {
			 obj.w.index = ((int)(abs(obj.p.p.x + obj.p.p.y)/size*binCount))%binCount;
		}
	}

	abstract class Function<T extends Entity> {
		abstract void set(T obj);

		void swap(ObjectPool<T> pool) { // Call this when swapping to this Function

		}
	}

	class LightPool extends ObjectPool<Light> {

		int currFillGraph = 0;
		Function[] fillGraphs = {new LightFillGraph1()};

		void set(Light light, Node a, Node b, int nof) {
			light.a = a;
			light.b = b;
			light.lifeSpan = lightLifeSpan;
			light.maxLife = lightLifeSpan;
			light.finished = false;
			light.draw = true;
			light.fillStyle.setx(0,0,0,0);
			light.nof = nof;
		}

		void add(Node a, Node b, int nof) {
			if (arm == ar.size()) {
				ar.add(0,new Light());
				set(getLast(),a,b, nof);
			} else {
				set(ar.get(arm),a,b, nof);
			}
			arm ++;
		}

		void update() {
			for (int i = 0 ; i < arm ; i ++) {
				Light light = ar.get(i);
				fillGraphs[currFillGraph].set(light);
				light.update();
			}
		}
	}

	class Light extends Entity {
		Node a;
		Node b;
		IColor fillStyle;
		float lifeSpan;
		float maxLife;
		int nof;

		Light() {
			fillStyle = new IColor();
			fillStyle.index = 0;
		}

		void update() {
			lifeSpan -= avg/10+av[fillStyle.index]/4;
			fillStyle.update();
			if (lifeSpan <= 0 || a.finished || b.finished) {
				this.finished = true;
				b.w.v += size*0.05*fillStyle.a.x/255;
				b.w.x += size*0.05*fillStyle.a.x/255;
			}
		}

		void render() {
			float dx = (b.p.p.x - a.p.p.x);
			float dy = (b.p.p.y - a.p.p.y);
			float dz = (b.p.p.z - a.p.p.z);
			float tick = (float)(maxLife-lifeSpan)/maxLife;
			float tick2 = (float)(maxLife-lifeSpan)/maxLife;
			tick2 *= tick2;
			push();
			fillStyle.strokeStyle();
			line(a.p.p.x + dx*tick, a.p.p.y + dy*tick, a.p.p.z + dz*tick, a.p.p.x + dx*tick2, a.p.p.y + dy*tick2, a.p.p.z + dz*tick2);
			pop();

		}
	}

	class NodePool extends ObjectPool<Node> {
		int currPGraph = 0;
		Function[] pGraphs = {new NodePGraph1(), new NodePGraph2()};

		int currWGraph = 0;
		Function[] wGraphs = {new NodeWGraph1()};

		int currFillGraph = 0;
		Function[] fillGraphs = {new NodeFillGraph1()};

		void set(Node node, PVector p) {
			node.p.reset(p.x,p.y,p.z);
			node.finished = false;
			node.draw = true;
			node.pv.reset(0,0,0);
			node.w.x = 0;
			node.w.X = nodeWX;
			node.lifeSpan = nodeLifeSpan;
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

		      pGraphs[currPGraph].set(mob);
		      wGraphs[currWGraph].set(mob);
		     fillGraphs[currFillGraph].set(mob);

		      if (mob.lifeSpan <= 0) mob.finished = true;
		      if (mob.p.p.x >  fr.x || mob.p.p.x < ba.x) mob.finished = true;
		      if (mob.p.p.y >  fr.y || mob.p.p.y < ba.y) mob.finished = true;
		      if (mob.p.p.z >  fr.z || mob.p.p.z < ba.z) mob.finished = true;
		    }
			super.update();
		}
	}

	class Node extends MobF {
		SpringValue w;

		Node() {
			this.p = new Point();
			this.w = new SpringValue(0, 0.5,10);
			pv.mass = 3;
		}

		void update() {
			super.update();
			w.update();
		}

		void render() {
			if (w.x > 3) {
				setDraw();
				box(w.x);
				pop();
			}
		}
	}
}