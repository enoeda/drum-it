import processing.video.*;
import krister.Ess.*;

final int FRAMERATE = 100;
int BPM = 120;
final int TEMPO_BASE = 100;
final int TEMPO_DIFF = 5;

final int RESOLUCION_NOTA = 4; // 1: negra, 2: corchea, 4: semicorchea

int tiempo_frame;
int umbral = 25;
  
boolean bDebug = true;
boolean mute = false;
double tiempo_lastlap;
boolean modo_edicion = false;

final int debug_x = 500;
final int debug_y = 80;
final int rectdebug_x = 95;
final int rectdebug_y = 445;

final int maxkits = 4;
int currentkit=0;

AudioChannel[][][] asBeatBox;
Capture cam;
int iEstado = 0;
Grid gWebcam;
Grid gProyector;
LightAnalyzer lightAnalyzer;
boolean[][] analyzedData;
int [][] iIlumCurrent, iIlumReferencia;
int iPosEnCompas = 0;
int iH=4, iW=16;
String sEstado = "Calibrar webcam";

void setup(){

  background(0);
  size(800, 600, P2D);
  frameRate(FRAMERATE);
  rectMode(RADIUS);  
  smooth();  
  textFont(createFont("Calibri",18,true));
  textMode(SCREEN);
  
  tiempo_frame = calculaTiempoFrame(BPM);
  initSound();

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
      image(cam, 40, 30);
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
    
    background(0);
    if (cam.available() == true) {
      cam.read();
      image(cam, 40, 30);
    }    

    //gProyector.paint(false);
    gWebcam.paint(false);

    // Miramos si ha habido cambios en la imagen
    iIlumCurrent = gWebcam.readIluminacion(cam);

    if (!modo_edicion) {
      // Analizamos y pintamos los datos y los guardamos
      analyzedData = lightAnalyzer.calculate(iIlumCurrent);
    } else {
      // Analizamos y pintamos los datos, pero no los guardamos
      lightAnalyzer.calculate(iIlumCurrent);
    }    

    if (!modo_edicion) {
      // Miramos si ha habido cambios en la fila del tempo
      if (analyzedData[iPosEnCompas+1][0]) {
        BPM = TEMPO_BASE + (iPosEnCompas*TEMPO_DIFF);
        tiempo_frame = calculaTiempoFrame(BPM);
      }
    }

    if (!mute) {
      // Tocamos fila según los últimos cambios leídos
      for (int i=1; i<=iH; i++) {
        if (analyzedData[iPosEnCompas+1][i]) {
          //if (asBeatBox[i-1].state==Ess.PLAYING) asBeatBox[i-1].stop();
          asBeatBox[currentkit][iPosEnCompas][i-1].play();
        }
      }
    }

    // Para pintar el recuadro anterior y no el actual
    int iPosEnCompasAnticipada = iPosEnCompas + 1;
    if (iPosEnCompasAnticipada>=iW)  iPosEnCompasAnticipada = 0;
    fill(100,255,100,30);
    rect(rectdebug_x + iPosEnCompasAnticipada*40, rectdebug_y, 19, 20*iH);
    
    if(++iPosEnCompas>=iW) iPosEnCompas = 0;

    double tiempo_lap = (System.nanoTime()-tiempo_lastlap)/1000000;
    if (tiempo_lap< tiempo_frame)
      delay((int)(tiempo_frame-tiempo_lap));
    
    break;
  }

  if (bDebug) {
    fill(255);      
    textAlign(RIGHT); 
    text("Tempo:", debug_x, debug_y);  
    text("Mute:", debug_x, debug_y+30);  
    text("Modo edición:", debug_x, debug_y+60);  
    text("Estado:", debug_x, debug_y+90);
    text("Kit:", debug_x, debug_y+120);              
    text("Umbral:", debug_x, debug_y+150);          
    text("FPS:", debug_x, debug_y+180);              

    textAlign(LEFT); 
    text(BPM +" bpm  [t/y]", debug_x+10, debug_y);  
    text(mute + "  [m]", debug_x+10, debug_y+30);  
    text(modo_edicion + "  [e]", debug_x+10, debug_y+60);  
    text(sEstado + "  [espacio]", debug_x+10, debug_y+90);      
    text(currentkit + "  [k]", debug_x+10, debug_y+120);          
    text(umbral + "  [u/i]", debug_x+10, debug_y+150);          
    text((int)frameRate, debug_x+10, debug_y+180);        
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
    if (!mute) {
       // Reinicializamos el sistema de audio
       Ess.stop();
       initSound();
    }     
    mute = !(mute);   
    return;
  }

  if (key=='t' || key=='T') {
    // tempo arriba
    BPM++;
    tiempo_frame = calculaTiempoFrame(BPM);
    return;
  }

  if (key=='y' || key=='Y') {
    // tempo abajo
    BPM--;
    tiempo_frame = calculaTiempoFrame(BPM);
    return;
  }

  if (key=='k' || key=='K') {
    // tempo abajo
    currentkit++;
    if (currentkit>=maxkits)
      currentkit=0;
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

  if (key=='e' || key=='E') {
    // modo edicion ON y OFF
    modo_edicion = !modo_edicion;
    return;
  }

  if (key==' ') {

    if (iEstado==0) {
      iEstado++;
      sEstado = "Calibrar proyector";
    } else if (iEstado==1) {
      sEstado = "Caja de ritmos";
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
      sEstado = "Calibrar webcam"; 
    }
    return;
  }
  
}

void initSound() {  
  Ess.start(this);
  asBeatBox = new AudioChannel[maxkits][iW][iH];
  for (int a=0; a<maxkits; a++) {
    for (int i=0; i<iW; i++) {
      for (int j=0; j<iH; j++) {
        asBeatBox[a][i][j] = new AudioChannel("kit_" + (a+1) + "_sample_" + (j+1) + ".WAV");
      }
    }
  }
}

int calculaTiempoFrame (int bpm) {
  return (60000 / RESOLUCION_NOTA / bpm);
}
  
void stop(){
  Ess.stop();
  super.stop();
}
