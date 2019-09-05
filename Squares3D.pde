import processing.pdf.*;

int pad = 1*100;
int W = 900-2*pad;
int H = 900-2*pad;

void settings(){
	size(W + 2*pad, H + 2*pad, P3D);
	// pixelDensity(2);
}

void setup() {
	noLoop();
	// ortho();

	Ny = N;
	dy = 1.0*H / Ny;
	Nx = round(W / dy);
	dx = 1.0*W / Nx;

	background(244);
}

int N = 200;
float D = 600;
float A = 200;
int Nx, Ny;
float dx, dy;
String[] list = new String[N+1];
ArrayList<String> arraylist = new ArrayList<String>();

void draw() {

	noiseSeed(int(random(1000000)));
	list = new String[N+1];
	arraylist = new ArrayList<String>();

	background(244);

	beginRaw(PDF, "vector/test.pdf");
	translate(pad, pad);
	translate(W/2, H/2, -400);
	rotateX(radians(45));
	rotateY(radians(-24));
	// rotateX(radians(random(-45,45)));
	// rotateY(radians(random(-45,45)));

	rectMode(CENTER);
	noFill();
	stroke(0);
	strokeWeight(0.7);

	int i = 0;
	for(float sz = 1./N; sz < 1.0-1.0/N; sz += 1.0/N){
		drawSquare(i++, pow(sz, 1/2.4));
	}

	saveStrings("coors4.txt", arraylist.toArray(new String[arraylist.size()]));

	noLoop();
	endRaw();
	save("image.jpg");
}

void keyPressed(){
	loop();
}

class Square{
	ArrayList<PVector> points = new ArrayList<PVector>();

	void add(PVector point){
		points.add(point);
	}
}

void drawSquare(int i, float pp){
	float sz = map(pp, 0, 1, -D/2, +D/2);

	pushMatrix();
	translate(0, 0, sz);
	float de = 0.02;
	rotateZ(radians(180));
	// if(pp > 0.5-de && pp < 0.5+de){
		// rotateZ(radians(12));
	// }

	float parts = 40;
	noFill();
	beginShape();
	if(i > 0){
		list[i] = "p";
		arraylist.add("p"); 
	}
	else{
		list[i] = "";
		arraylist.add(""); 
	}
	// float p;
	// float pom = floor(random(4));
	boolean alive = true;
	float x0 = -1000000000;
	float y0 = -1000000000;
	float z0 = -1000000000;
	for(float p = 0.0; p < 4.0; p += 1.0/parts){
	// for(float pp = pom; pp < 4.0+pom; pp += 1.0/parts){

		// p = pp % 4;

		float x, y, z;
		if(p < 1){
			x = lerp(-A/2, +A/2, p%1);
			y = lerp(-A/2, -A/2, p%1);
			x = x + A/parts*random(-0.2, 0.2);
		}
		else if(p < 2){
			x = lerp(+A/2, +A/2, p%1);
			y = lerp(-A/2, +A/2, p%1);
			y = y + A/parts*random(-0.2, 0.2);;
		}
		else if(p < 3){
			x = lerp(+A/2, -A/2, p%1);
			y = lerp(+A/2, +A/2, p%1);
			x = x + A/parts*random(-0.2, 0.2);;
		}
		else { // 4
			x = lerp(-A/2, -A/2, p%1);
			y = lerp(+A/2, -A/2, p%1);
			y = y + A/parts*random(-0.2, 0.2);;
		}

		float amp = 180 * pow(map(sz, +D/2, -D/2, 0, 1), 1);
		float ampxy = 20 * pow(map(sz, +D/2, -D/2, 0, 1), 1);
		float frq = map(pow(map(sz, +D/2, -D/2, 0, 1), 3), 0, 1, 0.01, 0.05);
		z = 0 * amp * (-1 + nnoise((x+A/2)*frq, (y+A/2)*frq, (sz+D/2)*0.01, 2));
		z += 4 * (-0.5 + nnoise((x+A/2)*0.4, (y+A/2)*0.4, (sz+D/2)*0.4, 2));
		// if(pp > 0.5-de && pp < 0.5+de){
		// 	x += 200 * (-0.5 + nnoise((x+A/2)*0.3, (y+A/2)*0.3, (sz+D/2)*0.3+120, 2));
		// 	y += 200 * (-0.5 + nnoise((x+A/2)*0.3, (y+A/2)*0.3, (sz+D/2)*0.3+321, 2));
		// }

		// PVector vec = new PVector(x, y);
		// float ang = nnoise((sz+D/2)*0.01,0,2);
		// vec.rotate(i*0.005);
		// x = vec.x;
		// y = vec.y;

		if(x0 == -1000000000){
			x0 = x;
			y0 = y;
			z0 = z;
		}
		float xx = screenX(x, y, z);
		float yy = screenY(x, y, z);

		if(alive){
			vertex(x, y, z);
			list[i] += "\n" + xx + " " + yy;
			arraylist.set(arraylist.size()-1, arraylist.get(arraylist.size()-1) + "\n" + xx + " " + yy); 
		}

		float chance = map(pow(map(sz, +D/2, -D/2, 0, 1), 2), 0, 1, 100, 50);
		if(alive){
			if(random(100) > chance){
				alive = false;
				endShape();
			}
		} else{
			if(random(100) > 90){
				alive = true;
				beginShape();
				list[i] += "\n" + "p";
				arraylist.set(arraylist.size()-1, arraylist.get(arraylist.size()-1) + "\n" + "p"); 
			}
		}
	}
	vertex(x0, y0, z0);

	float xx0 = screenX(x0, y0, z0);
	float yy0 = screenY(x0, y0, z0);
	list[i] += "\n" + xx0 + " " + yy0;
	arraylist.set(arraylist.size()-1, arraylist.get(arraylist.size()-1) + "\n" + xx0 + " " + yy0); 
	endShape();
	popMatrix();
}

float nnoise(float x, float y, float p){
	return power(noise(x, y), p);
}

float nnoise(float x, float y, float z, float p){
	return power(noise(x, y, z), p);
}

float power(float p, float g) {
	if (p < 0.5)
		return 0.5 * pow(2*p, g);
	else
		return 1 - 0.5 * pow(2*(1 - p), g);
}
