import processing.video.*;
import krister.Ess.*;

final int FRAMERATE = 100;
int BPM = 120;
final int RESOLUCION_NOTA = 2; // 1: negra, 2: corchea, 4: semicorchea

int tiempo_frame;
int umbral = 25;
  
boolean bDebug = true;
boolean mute = false;
double tiempo_lastlap;


AudioChannel[][] asBeatBox;
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
  frameRate(FRAMERATE);
  textFont(createFont("Calibri",12));
  rectMode(RADIUS);

  tiempo_frame = 60000 / RESOLUCION_NOTA / BPM;

  Ess.start(this);
  asBeatBox = new AudioChannel[iW][iH];
  for (int i=0; i<iW; i++) {
    for (int j=0; j<iH; j++) {
      asBeatBox[i][j] = new AudioChannel("sample_" + (j+1) + ".WAV");

    }
  }

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

    tiempo_lastlap = System.nanoTime(); // Grabamos tiempo último step
    
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

    if (!mute) {
      for (int i=1; i<=iH; i++) {
        if (analyzedData[iPosEnCompas+1][i]) {
          //if (asBeatBox[i-1].state==Ess.PLAYING) asBeatBox[i-1].stop();
          asBeatBox[iPosEnCompas][i-1].play();
  
        }
      }
    }

    noFill();
    // Para pintar el recuadro anterior y no el actual
    int iPosEnCompasAnticipada = iPosEnCompas + 1;
    if (iPosEnCompasAnticipada>=iW)  iPosEnCompasAnticipada = 0;
    rect(38 + iPosEnCompasAnticipada*30, 475,12,15*iH);
    
    if(++iPosEnCompas>=iW) iPosEnCompas = 0;

    double tiempo_lap = (System.nanoTime()-tiempo_lastlap)/1000000;
    //print ("lap: " + tiempo_lap + ", frame: " + tiempo_frame); 
    if (tiempo_lap< tiempo_frame)
      delay((int)(tiempo_frame-tiempo_lap));
    
    break;
  }

  if (bDebug) {
    fill(255);        
    text("Tempo: " + BPM +" bpms, Mute: " + mute + ", Estado: " + iEstado + ", Umbral: " + umbral + ", FPS: " +  (int)frameRate, 0, height-5);  
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

  if (key=='t' || key=='T') {
    // tempo arriba
    BPM++;
    tiempo_frame = 60000 / RESOLUCION_NOTA / BPM;    
    return;
  }

  if (key=='y' || key=='Y') {
    // tempo abajo
    BPM--;
    tiempo_frame = 60000 / RESOLUCION_NOTA / BPM;
    return;
  }

  if (key=='u' || key=='U') {
    // umbral arriba
    umbral++;
    return;
  }

  if (key=='i' || key=='I') {
    // umbral abajo
    umbral--;
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
  Ess.stop();
  super.stop();
}



