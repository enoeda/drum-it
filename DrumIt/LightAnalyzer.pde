class LightAnalyzer {
  
  int [][] iIlumBase;
  final int umbral = 25;
  
  LightAnalyzer (int[][] iIlumBase) {
    this.iIlumBase = iIlumBase;
  }
  
  boolean[][] calculate(int[][] iIlumCurrent) {
    boolean[][] resultados = new boolean[iIlumCurrent.length][iIlumCurrent[0].length];
    
    for (int i=0; i<iIlumCurrent.length; i++) {
      for (int j=0; j<iIlumCurrent[i].length; j++) {
        resultados[i][j] = (abs(iIlumCurrent[i][j] - iIlumBase[i][j]) >= umbral);
        //debug
        if (resultados[i][j]) {
          fill(255,0,0);
          stroke (255,0,0);
        } else {
          fill(255);
          stroke (227,208,191);          
        }
        
        text(iIlumCurrent[i][j],i*30, j*30 + 400);

      }
    }
    return (resultados);
  }
  
}
