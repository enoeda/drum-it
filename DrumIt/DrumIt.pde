import processing.video.*;
import ddf.minim.*;

boolean bDebug = true;
boolean mute = true;

Minim minim;
AudioSample[] asBeatBox;
Capture cam;
int iEstado = 0;
Grid gWebcam;
Grid gProyector;
int[][] iIlum;


void setup(){
  background(0);

  size(800, 600, P2D);
  //frameRate(8);
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
  gWebcam = new Grid(10,6);
  gProyector = new Grid(10,6);

}

void draw(){

  switch (iEstado) {
  case 0: 
    if (cam.available() == true) {
      cam.read();
      background(0);
      image(cam, 0, 0);
      gWebcam.update();
      gWebcam.paint(true);
    }
    break;

  case 1:
    background(0);
    gProyector.update();
    gProyector.paint(true);
    break;

  case 2:
    //r.update();
    if (cam.available() == true) {
      cam.read();
    }    
    background(0);
    gProyector.paint(false);
    // TODO: analiza y play
    //r.renderLight(cam, asBeatBox, mute);

    break;
  }

  if (bDebug) {
    fill(255);        
    text("Mute: " + mute + ", Estado: " + iEstado + ", FPS: " +  (int)frameRate ,width-180,height-5);  
  }  

}

void mousePressed(){
  switch (iEstado) {
  case 0: 
    gWebcam.pulsarBoton();
    break;
  case 1:
    gProyector.pulsarBoton();
    break;
  }

}

void mouseReleased(){
  switch (iEstado) {
  case 0: 
    gWebcam.soltarBoton();
    break;
  case 1:
    gProyector.soltarBoton();
    break;
  }
}

void keyPressed() {
  if (key=='m' || key=='M') {
    mute = !(mute);
    return;
  }
  
  if (iEstado==0) {
    //r.setBaseImage(cam);
    iEstado++;
  } 
  else if (iEstado==1) {

    // Nos quedamos con la última imagen de la webcam con la rejilla proyectada
    gProyector.paint(false);
    while (cam.available() != true) {
    }
    cam.read();
    // Tomar medidas de luz de "cam"
    iIlum = gWebcam.readIluminacion(cam);
    //image(cam, 0, 0);
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












