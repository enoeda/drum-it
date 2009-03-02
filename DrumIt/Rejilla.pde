class Rejilla {

  int iW,iH;
  PVector [][] pvEsquinas;
  boolean [][] bIsMoving;
  int iRad = 4;
  int [][] iIlum;
  int [][] iIlumBase;
  PImage piFoto;
  int umbral = 15;
  int iPosEnCompas = 0;

  Rejilla(int iWidth, int iHeight){

    iW=iWidth;
    iH=iHeight;

    pvEsquinas = new PVector[2][2];
    pvEsquinas[0][0] = new PVector (20,20);
    pvEsquinas[1][0] = new PVector (340,20);  
    pvEsquinas[0][1] = new PVector (20,160);
    pvEsquinas[1][1] = new PVector (340,160);    

    bIsMoving = new boolean[2][2];
    soltarBoton();

    iIlum = new int[iWidth][iHeight];
    iIlumBase = new int[iWidth][iHeight];

  }

  void setBaseImage(PImage imagebase) {
    piFoto = imagebase;
  }

  void setBaseValues() {
    // Calculate base values
  }

  void update(){

    if (mousePressed) {
      if (bIsMoving[0][0]) pvEsquinas[0][0] = new PVector(mouseX, mouseY);
      else if (bIsMoving[1][0]) pvEsquinas[1][0] = new PVector(mouseX, mouseY);    
      else if (bIsMoving[1][1]) pvEsquinas[1][1] = new PVector(mouseX, mouseY);    
      else if (bIsMoving[0][1]) pvEsquinas[0][1] = new PVector(mouseX, mouseY);        
    }   

  }
  
  void renderLight(PImage imagecurr, AudioSample[] asBeatBox) {
    piFoto = imagecurr;
    // TODO: copiar lo del render que nos haga falta, no hacer la llamada completa

    image(piFoto, 0, 0, piFoto.width, piFoto.height);    
    piFoto.loadPixels();

    stroke (227,208,191);
    line (pvEsquinas[0][0].x, pvEsquinas[0][0].y, pvEsquinas[1][0].x, pvEsquinas[1][0].y);
    line (pvEsquinas[1][0].x, pvEsquinas[1][0].y, pvEsquinas[1][1].x, pvEsquinas[1][1].y);
    line (pvEsquinas[1][1].x, pvEsquinas[1][1].y, pvEsquinas[0][1].x, pvEsquinas[0][1].y);
    line (pvEsquinas[0][1].x, pvEsquinas[0][1].y, pvEsquinas[0][0].x, pvEsquinas[0][0].y); 

    for (int iPaso=1; iPaso<iH; iPaso++){
      PVector pv1 = interpolaBorde(pvEsquinas[0][0],pvEsquinas[0][1], iPaso, iH);
      PVector pv2 = interpolaBorde(pvEsquinas[1][0],pvEsquinas[1][1], iPaso, iH);      
      line (pv1.x,pv1.y,pv2.x,pv2.y);
    }

    for (int iPaso=1; iPaso<iW; iPaso++){
      PVector pv1 = interpolaBorde(pvEsquinas[0][0],pvEsquinas[1][0], iPaso, iW);
      PVector pv2 = interpolaBorde(pvEsquinas[0][1],pvEsquinas[1][1], iPaso, iW);            
      line (pv1.x,pv1.y,pv2.x,pv2.y);      
    }    

    noFill();
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
            int c = piFoto.get(x,y);
            // Optimizado para postits fucsia
            iIlum[iPasoX-1][iPasoY-1] += (((c >> 16) & 0xff) + ((c >> 8) & 0xff) + (c & 0x00)) /3;
            // stroke(
          }
        }
        
        iIlum[iPasoX-1][iPasoY-1] /= 100;    
        // Pintar base
        fill(160);
        text(iIlumBase[iPasoX-1][iPasoY-1],iPasoX*30, iPasoY*30 + piFoto.height+50);
        // Pintamos current
        if (abs(iIlum[iPasoX-1][iPasoY-1] - iIlumBase[iPasoX-1][iPasoY-1]) >= umbral) {
          fill(255,0,0);
          stroke (255,0,0);
        } else {
          fill(255);
          stroke (227,208,191);          
        }
        text(iIlum[iPasoX-1][iPasoY-1],iPasoX*30, iPasoY*30 + piFoto.height+60);

        line(pvInter.x-5,pvInter.y,pvInter.x+5,pvInter.y);
        line(pvInter.x,pvInter.y-5,pvInter.x,pvInter.y+5);
      }             
    }
    
    noFill();
    rect(68 + iPosEnCompas*30, 395,12,15*(iH-2));
    
    // Revisamos el grid de instrumentos    
    for (int i=1; i<iH-1; i++) {
        if (abs(iIlum[iPosEnCompas+1][i] - iIlumBase[iPosEnCompas+1][i]) >= umbral) {
          asBeatBox[i-1].trigger();
        }
    }
    
    if(++iPosEnCompas>=(iW-2)) iPosEnCompas = 0;

  }
  
  void render(){

    image(piFoto, 0, 0, piFoto.width, piFoto.height);    
    piFoto.loadPixels();

    stroke (227,208,191);
    fill(160);
    
    line (pvEsquinas[0][0].x, pvEsquinas[0][0].y, pvEsquinas[1][0].x, pvEsquinas[1][0].y);
    line (pvEsquinas[1][0].x, pvEsquinas[1][0].y, pvEsquinas[1][1].x, pvEsquinas[1][1].y);
    line (pvEsquinas[1][1].x, pvEsquinas[1][1].y, pvEsquinas[0][1].x, pvEsquinas[0][1].y);
    line (pvEsquinas[0][1].x, pvEsquinas[0][1].y, pvEsquinas[0][0].x, pvEsquinas[0][0].y); 

    for (int iPaso=1; iPaso<iH; iPaso++){
      PVector pv1 = interpolaBorde(pvEsquinas[0][0],pvEsquinas[0][1], iPaso, iH);
      PVector pv2 = interpolaBorde(pvEsquinas[1][0],pvEsquinas[1][1], iPaso, iH);      
      line (pv1.x,pv1.y,pv2.x,pv2.y);
    }

    for (int iPaso=1; iPaso<iW; iPaso++){
      PVector pv1 = interpolaBorde(pvEsquinas[0][0],pvEsquinas[1][0], iPaso, iW);
      PVector pv2 = interpolaBorde(pvEsquinas[0][1],pvEsquinas[1][1], iPaso, iW);            
      line (pv1.x,pv1.y,pv2.x,pv2.y);      
    }    


    for (int iPasoY=1; iPasoY<=iH; iPasoY++){
      for (int iPasoX=1; iPasoX<=iW; iPasoX++){
        PVector pv1 = interpolaBorde(pvEsquinas[0][0],pvEsquinas[1][0], -0.5+(float)iPasoX, iW);
        PVector pv2 = interpolaBorde(pvEsquinas[0][1],pvEsquinas[1][1], -0.5+(float)iPasoX, iW);            
        PVector pv3 = interpolaBorde(pvEsquinas[0][0],pvEsquinas[0][1], -0.5+(float)iPasoY, iH);
        PVector pv4 = interpolaBorde(pvEsquinas[1][0],pvEsquinas[1][1], -0.5+(float)iPasoY, iH);            
        PVector pvInter = lineIntersection (pv1, pv2, pv3, pv4);
        line(pvInter.x-5,pvInter.y,pvInter.x+5,pvInter.y);
        line(pvInter.x,pvInter.y-5,pvInter.x,pvInter.y+5);
        iIlumBase[iPasoX-1][iPasoY-1]=0;
        for (int y = (int)pvInter.y-5; y<(int)pvInter.y+5; y++){
          for (int x = (int)pvInter.x-5; x<(int)pvInter.x+5; x++){
            int c = piFoto.get(x,y);
            // Optimizado para postits fucsia
            iIlumBase[iPasoX-1][iPasoY-1] += (((c >> 16) & 0xff) + ((c >> 8) & 0xff) + (c & 0x00)) /3;
          }
        }
        iIlumBase[iPasoX-1][iPasoY-1] /= 100;        

        text(iIlumBase[iPasoX-1][iPasoY-1],iPasoX*30, iPasoY*30 + piFoto.height+50);
      }             
    }

    stroke (255);
    fill(157,77,72);
    rect(pvEsquinas[0][0].x, pvEsquinas[0][0].y,iRad,iRad);
    rect(pvEsquinas[1][0].x, pvEsquinas[1][0].y,iRad,iRad);  
    rect(pvEsquinas[1][1].x, pvEsquinas[1][1].y,iRad,iRad);    
    rect(pvEsquinas[0][1].x, pvEsquinas[0][1].y,iRad,iRad);     

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



}















