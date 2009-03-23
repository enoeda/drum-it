class Grid {

  int iW, iH;
  PVector [][] pvEsquinas;
  boolean [][] bIsMoving;
  final int iRad = 4;

  Grid(int iWidth, int iHeight){

    iW=iWidth+2;
    iH=iHeight+2;

    pvEsquinas = new PVector[2][2];
    pvEsquinas[0][0] = new PVector (20,20);
    pvEsquinas[1][0] = new PVector (340,20);  
    pvEsquinas[0][1] = new PVector (20,160);
    pvEsquinas[1][1] = new PVector (340,160);    

    bIsMoving = new boolean[2][2];
    soltarBoton();

  }

  void paint (boolean configurable) {

    stroke (227,208,191);
    fill(160);

    // Pinta borde
    /*
    line (pvEsquinas[0][0].x, pvEsquinas[0][0].y, pvEsquinas[1][0].x, pvEsquinas[1][0].y);
     line (pvEsquinas[1][0].x, pvEsquinas[1][0].y, pvEsquinas[1][1].x, pvEsquinas[1][1].y);
     line (pvEsquinas[1][1].x, pvEsquinas[1][1].y, pvEsquinas[0][1].x, pvEsquinas[0][1].y);
     line (pvEsquinas[0][1].x, pvEsquinas[0][1].y, pvEsquinas[0][0].x, pvEsquinas[0][0].y); 
     */

    // Pinta líneas horizontales
    for (int iPaso=0; iPaso<=iH; iPaso++){
      PVector pv1 = interpolaBorde(pvEsquinas[0][0],pvEsquinas[0][1], iPaso, iH);
      PVector pv2 = interpolaBorde(pvEsquinas[1][0],pvEsquinas[1][1], iPaso, iH);      
      line (pv1.x,pv1.y,pv2.x,pv2.y);
    }

    // Pinta líneas verticales
    for (int iPaso=0; iPaso<=iW; iPaso++){
      PVector pv1 = interpolaBorde(pvEsquinas[0][0],pvEsquinas[1][0], iPaso, iW);
      PVector pv2 = interpolaBorde(pvEsquinas[0][1],pvEsquinas[1][1], iPaso, iW);            
      line (pv1.x,pv1.y,pv2.x,pv2.y);      
    }    

    // Pinta cruces de los centros   
    boolean show; 
    for (int iPasoY=1; iPasoY<=iH; iPasoY++){
      for (int iPasoX=1; iPasoX<=iW; iPasoX++){
        PVector pv1 = interpolaBorde(pvEsquinas[0][0],pvEsquinas[1][0], -0.5+(float)iPasoX, iW);
        PVector pv2 = interpolaBorde(pvEsquinas[0][1],pvEsquinas[1][1], -0.5+(float)iPasoX, iW);            
        PVector pv3 = interpolaBorde(pvEsquinas[0][0],pvEsquinas[0][1], -0.5+(float)iPasoY, iH);
        PVector pv4 = interpolaBorde(pvEsquinas[1][0],pvEsquinas[1][1], -0.5+(float)iPasoY, iH);            
        PVector pvInter = lineIntersection (pv1, pv2, pv3, pv4);

        if (!configurable) {
          show = true;
        } 
        else if ((iPasoY==1 || iPasoY==iH) && (iPasoX==1||iPasoX==iW)){
          show = true;
        } 
        else {
          show = false;
        }
        if (show) {
          line(pvInter.x-5,pvInter.y,pvInter.x+5,pvInter.y);
          line(pvInter.x,pvInter.y-5,pvInter.x,pvInter.y+5);
        }

      }             
    }

    // Pinta las esquinas movibles
    if (configurable) {
      stroke (255);
      fill(157,77,72);
      rect(pvEsquinas[0][0].x, pvEsquinas[0][0].y,iRad,iRad);
      rect(pvEsquinas[1][0].x, pvEsquinas[1][0].y,iRad,iRad);  
      rect(pvEsquinas[1][1].x, pvEsquinas[1][1].y,iRad,iRad);    
      rect(pvEsquinas[0][1].x, pvEsquinas[0][1].y,iRad,iRad);             
    }
  }

  void update(){

    if (mousePressed) {
      if (bIsMoving[0][0]) pvEsquinas[0][0] = new PVector(mouseX, mouseY);
      else if (bIsMoving[1][0]) pvEsquinas[1][0] = new PVector(mouseX, mouseY);    
      else if (bIsMoving[1][1]) pvEsquinas[1][1] = new PVector(mouseX, mouseY);    
      else if (bIsMoving[0][1]) pvEsquinas[0][1] = new PVector(mouseX, mouseY);        
    }   

  }

  PVector interpolaBorde(PVector pvInicio, PVector pvFin, float fCurrPaso, int iTotPasos){
    return new PVector (pvInicio.x + fCurrPaso*(pvFin.x-pvInicio.x)/iTotPasos,
    pvInicio.y + fCurrPaso*(pvFin.y-pvInicio.y)/iTotPasos);
  }

  void pulsarBoton(){
    for(int y = 0; y<2; y++) {
      for(int x = 0; x<2; x++) {
        if (mouseX>=pvEsquinas[x][y].x-iRad && mouseX <= pvEsquinas[x][y].x+iRad &&
          mouseY>=pvEsquinas[x][y].y-iRad && mouseY <= pvEsquinas[x][y].y+iRad) {
          bIsMoving[x][y] = true;
          return;
        } 
      }
    }
  }  

  void soltarBoton(){
    bIsMoving[0][0] = false;
    bIsMoving[1][0] = false;  
    bIsMoving[0][1] = false;
    bIsMoving[1][1] = false;      
  }

  PVector lineIntersection(PVector pv1, PVector pv2, PVector pv3, PVector pv4){
    float bx = pv2.x - pv1.x;
    float by = pv2.y - pv1.y;
    float dx = pv4.x - pv3.x;
    float dy = pv4.y - pv3.y;

    float b_dot_d_perp = bx*dy - by*dx;

    if(b_dot_d_perp == 0) return null;

    float cx = pv3.x-pv1.x;
    float cy = pv3.y-pv1.y;

    float t = (cx*dy - cy*dx) / b_dot_d_perp;

    return new PVector(pv1.x+t*bx, pv1.y+t*by);
  }

  // Lee los datos de iluminación de la imagen pasada como parámetro
  int[][] readIluminacion(PImage i) {
    int[][] iIlum = new int[iW][iH];

    for (int iPasoY=1; iPasoY<=iH; iPasoY++){
      for (int iPasoX=1; iPasoX<=iW; iPasoX++){
        PVector pv1 = interpolaBorde(pvEsquinas[0][0],pvEsquinas[1][0], -0.5+(float)iPasoX, iW);
        PVector pv2 = interpolaBorde(pvEsquinas[0][1],pvEsquinas[1][1], -0.5+(float)iPasoX, iW);            
        PVector pv3 = interpolaBorde(pvEsquinas[0][0],pvEsquinas[0][1], -0.5+(float)iPasoY, iH);
        PVector pv4 = interpolaBorde(pvEsquinas[1][0],pvEsquinas[1][1], -0.5+(float)iPasoY, iH);            
        PVector pvInter = lineIntersection (pv1, pv2, pv3, pv4);

        iIlum[iPasoX-1][iPasoY-1]=0;
        for (int y = (int)pvInter.y-5; y<(int)pvInter.y+5; y++){
          for (int x = (int)pvInter.x-5; x<(int)pvInter.x+5; x++){
            int c = i.get(x,y);
            // Suma de los 3 canales
            iIlum[iPasoX-1][iPasoY-1] += (((c >> 16) & 0xff) + ((c >> 8) & 0xff) + (c & 0xff)) /3;
            // stroke(
          }
        }

        iIlum[iPasoX-1][iPasoY-1] /= 100;               
      }             
    }  
    return iIlum;
  }
  
}

