import processing.video.*;
//import ddf.minim.*;
import krister.Ess.*;


boolean bDebug = true;
boolean mute = true;

//Minim minim;
//AudioSample[] asBeatBox;
AudioChannel[] asBeatBox;
Capture cam;
int iEstado = 0;
Grid gWebcam;
Grid gProyector;
LightAnalyzer lightAnalyzer;
boolean[][] analyzedData;
int [][] iIlumCurrent, iIlumReferencia;
int iPosEnCompas = 0;
int iH=4, iW=8;

void setup(){
  background(0);

  size(800, 600, P2D);
  frameRate(8);
  textFont(createFont("Calibri",12));
  rectMode(RADIUS);

  //minim = new Minim(this);
  Ess.start(this);
  asBeatBox = new AudioChannel[4];
  asBeatBox[0] = new AudioChannel("KICK1.WAV");
  asBeatBox[1] = new AudioChannel("SNARE1.WAV");  
  asBeatBox[2] = new AudioChannel("HHCL.WAV");    
  asBeatBox[3] = new AudioChannel("HHOP.WAV");      
  //asBeatBox[3] = minim.loadSample("HHOP.WAV", 2048);    

  //smooth();

  cam = new Capture(this, 320, 240);
  gWebcam = new Grid(iW,iH);
  gProyector = new Grid(iW,iH);

}

void draw(){

  switch (iEstado) {
  case 0: 
    // Ajustar geometría de la rejilla webcam
    if (cam.available() == true) {
      cam.read();
      background(0);
      image(cam, 0, 0);
      gWebcam.update();
      gWebcam.paint(true);
    }
    break;

  case 1:
    // Ajustar geometría de la rejilla proyector
    background(0);
    gProyector.update();
    gProyector.paint(true);
    break;

  case 2:
    // Bucle de lectura e interpretación de la imagen de entrada
    //r.update();
    background(0);
    if (cam.available() == true) {
      cam.read();
      image(cam, 0, 0);
    }    
      


    
    //gProyector.paint(false);
    gWebcam.paint(false);
    iIlumCurrent = gWebcam.readIluminacion(cam);
    analyzedData = lightAnalyzer.calculate(iIlumCurrent);


    //if (!mute) {
      for (int i=1; i<=iH; i++) {
        if (analyzedData[iPosEnCompas+1][i]) {
          if (asBeatBox[i-1].state==Ess.PLAYING) asBeatBox[i-1].stop();
          asBeatBox[i-1].play();
        }
      }
    //}

    noFill();
    rect(38 + iPosEnCompas*30, 475,12,15*iH);
    if(++iPosEnCompas>=iW) iPosEnCompas = 0;

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
    iIlumReferencia = gWebcam.readIluminacion(cam);
    lightAnalyzer = new LightAnalyzer(iIlumReferencia);
    //image(cam, 0, 0);
    iEstado++;
  } 
  else {
    iEstado = 0;    
  }
}

void stop(){
  /*asBeatBox[0].close();
  asBeatBox[1].close();
  asBeatBox[2].close();  
  asBeatBox[3].close();    
  minim.stop();*/
  Ess.stop();

  super.stop();
}













