class LightAnalyzer {
  
  final int lightdebug_x = 70;
  final int lightdebug_y = 350;

  int [][] iIlumBase;
  
  LightAnalyzer (int[][] iIlumBase) {
    this.iIlumBase = iIlumBase;
  }
    
  boolean[][] calculate(int[][] iIlumCurrent) {
    
    textAlign(RIGHT);

    boolean[][] resultados = new boolean[iIlumCurrent.length][iIlumCurrent[0].length];
    
    for (int i=0; i<iIlumCurrent.length; i++) {
      for (int j=0; j<iIlumCurrent[i].length; j++) {
        resultados[i][j] = (abs(iIlumCurrent[i][j] - iIlumBase[i][j]) >= umbral);
        if (resultados[i][j]) {
          fill(255,0,0);
        } else {
          if (i==0 || j==0 || i==iIlumCurrent.length-1 || j==iIlumCurrent[i].length-1) {
            fill(96);
          } else {
            fill(255);
          }
        }
        
        text(iIlumCurrent[i][j], lightdebug_x + i*40, lightdebug_y + j*40);

      }
    }
    return (resultados);
  }
  
}
