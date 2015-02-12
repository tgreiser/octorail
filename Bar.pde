/*
 * Bar
 * Model for a single bar - to be renamed segment
 *
 * (c) Tim Greiser - 2015
 * Released under the terms of MIT License
 */

class Bar {
  float x1;
  float y1;
  float x2;
  float y2;
  
  float ox1;
  float oy1;
  float ox2;
  float oy2;
  
  String name;
  boolean active = true;
  
  int driver;
  int bar;
  int index;
  int count;
  
  Bar(String _name, int _driver, int _bar, int _index, int _count, float _x1, float _y1, float _x2, float _y2) {
    driver = _driver;
    bar = _bar;
    index = _index;
    count = _count;
    name = _name;
    
    x1 = _x1;
    y1 = _y1;
    x2 = _x2;
    y2 = _y2;
    backupLocations();
  }
  
  void backupLocations() {
    if (frameCount > 0) { println("Backing up bar "+name); }
    ox1 = x1;
    oy1 = y1;
    ox2 = x2;
    oy2 = y2;
  }
  
  void revert() {
    println("Revering bar " +name);
    x1 = ox1;
    y1 = oy1;
    x2 = ox2;
    y2 = oy2;
    updateConfig();
  }
  
  String getListName() {
    return name;
  }
  
  void leds(OPC opc) {
    float[] xs = interpolate(x1, x2, count);
    float[] ys = interpolate(y1, y2, count); 
    
    for (int iX = 0; iX < count; iX++ ) {
      opc.led(index + iX, int(xs[iX]), int(ys[iX]));
    }
  }
  
  float[] interpolate(float p1, float p2, int times) {
    float[] ret = new float [times];
    times++;
    for (int iX = 1; iX < times; iX++) {
      float mult = float(iX) / float(times);
      float inv = 1.0 - mult;
      ret[iX-1] = (p1 * mult + p2 * inv);
    }
    return ret; 
  }
  
  void update(boolean p1, float x, float y) {
    if (p1 == true) {
      x1 = x;
      y1 = y;
    } else {
      x2 = x;
      y2 = y;
    }
    updateConfig();
  }
}
