import processing.video.*;
import ddf.minim.*;

boolean bDebug = true;
boolean mute = true;

Minim minim;
AudioSample[] asBeatBox;
Rejilla r;
Capture cam;
int iEstado = 0;

void setup(){
  background(0);

  size(800, 600, P2D);
  frameRate(8);
  textFont(createFont("Calibri",12));
  rectMode(RADIUS);

  minim = new Minim(this);
  asBeatBox = new AudioSample[4];
  asBeatBox[0] = minim.loadSample("KICK1.WAV", 2048);
  asBeatBox[1] = minim.loadSample("SNARE1.WAV", 2048);  
  asBeatBox[2] = minim.loadSample("HHCL.WAV", 2048);    
  asBeatBox[3] = minim.loadSample("HHOP.WAV", 2048);    

  //smooth();

  cam = new Capture(this, 320, 240);
  r = new Rejilla(10,6);

}

void draw(){

  switch (iEstado) {
  case 0: 
    if (cam.available() == true) {
      cam.read();
      image(cam, 0, 0);
    }
    break;

  case 1:
    background(0);
    r.update();
    r.render();
    break;

  case 2:
    //r.update();
    if (cam.available() == true) {
      cam.read();
    }    
    background(0);
    r.renderLight(cam, asBeatBox, mute);

    break;
  }

  if (bDebug) {
    fill(255);        
    text("Mute: " + mute + ", Estado: " + iEstado + ", FPS: " +  (int)frameRate ,width-180,height-5);  
  }  

}

void mousePressed(){
  r.pulsarBoton();
}

void mouseReleased(){
  r.soltarBoton();
}

void keyPressed() {
  if (key=='m' || key=='M') {
    mute = !(mute);
    return;
  }
  
  if (iEstado==0) {
    r.setBaseImage(cam);
    iEstado++;
  } 
  else if (iEstado==1) {
    r.setBaseValues();
    iEstado++;
  } 
  else {
    iEstado = 0;    
  }
}

void stop(){
  asBeatBox[0].close();
  asBeatBox[1].close();
  asBeatBox[2].close();  
  asBeatBox[3].close();    
  minim.stop();
  super.stop();
}












