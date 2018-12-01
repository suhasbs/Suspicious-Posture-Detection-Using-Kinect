import processing.video.*;

Capture cam;
int count=0;
void setup() {
  size(600, 300);
  cam = new Capture(this, 320, 240, 30);
  cam.start();
}

void draw() {
  if(cam.available()) {
    cam.read();
  }
  image(cam, 0,0);
  if (keyPressed) {
    if (key == 'b' || key == 'B') {
      saveFrame("img_"+count+".png");
      count+=1;
    }
  } 
}


