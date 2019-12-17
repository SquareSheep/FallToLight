class Source extends MobF {
	int spawnRate = 5;
	int max = 100;

	Source(PVector p) {
		this.p = new Point(p);
	}

	void update() {
		super.update();
		if (nodes.arm < max && frameCount % spawnRate == 0) {
			nodes.add(new PVector(p.p.x,p.p.y,p.p.z));
			nodes.getLast().pv.reset(random(-2,2),random(-2,2),random(-2, 2));
		}
	}
}

class NodePool extends ObjectPool<Node> {

	void add(PVector p) {
		if (arm == ar.size()) {
			ar.add(0,new Node(p));
		} else {
			Node node = (Node)ar.get(arm);
			node.p.reset(p.x + random(-100,100),p.y + random(-100,100),p.z + random(-100,100));
			node.finished = false;
			node.draw = true;
		}
		arm ++;
	}

	void remove(int i) {
		super.remove(i);
		Node node = (Node) getLast();
		println(node);
		if (node.parent != null) {
			node.parent.children.remove(node);
		}
		if (node.children.size() != 0) {
			for (Node child : node.children) {
				child.parent = node.parent;
			}
		}
	}

	void update() {
		for (int i = 0 ; i < arm ; i ++) {
	      Mob mob = (Mob)ar.get(i);
	      if (mob.p.p.x > front.x || mob.p.p.x < back.x) mob.finished = true;
	      if (mob.p.p.y > front.y || mob.p.p.y < back.y) mob.finished = true;
	      if (mob.p.p.z > front.z || mob.p.p.z < back.z) mob.finished = true;
	    }
		super.update();
	}
}

class Node extends MobF {
	Node parent;
	ArrayList<Node> children;

	Node(PVector p) {
		this.p = new Point(p);
		this.w = de*0.05;
	}

	void render() {
		setDraw();
		circle(0,0,w);
		pop();
		if (parent != null) {
			line(p.p.x,p.p.y,p.p.z, parent.p.p.x,parent.p.p.y,parent.p.p.z);
		}
	}

	void addChild(Node child) {
		children.add(child);
	}

	void removeChild(Node child) {
		children.remove(child);
	}
}