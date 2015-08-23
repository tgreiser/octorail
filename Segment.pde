/*
 * Segment
 * Model for a single segment
 *
 * (c) Tim Greiser - 2015
 * Released under the terms of MIT License
 */

class Segment {
  float x1;
  float y1;
  float x2;
  float y2;
  
  float ox1;
  float oy1;
  float ox2;
  float oy2;
  
  boolean active = true;
  
  int driver;
  int rail;
  int index;
  int count;
  
  Segment(int _driver, int _rail, int _index, int _count, float _x1, float _y1, float _x2, float _y2) {
    driver = _driver;
    rail = _rail;
    index = _index;
    count = _count;
    
    x1 = _x1;
    y1 = _y1;
    x2 = _x2;
    y2 = _y2;
    backupLocations();
  }
  
  String name() {
    // TODO - convert index to A,B,C, etc
    return str(driver)+str(rail)+str(index);
  }
  
  int globalIndex() {
    return ((driver - 1) * 512) +
      ((rail - 1) * 64) +
      index;
  }
  
  void backupLocations() {
    if (frameCount > 0) { println("Backing up segment "+name()); }
    ox1 = x1;
    oy1 = y1;
    ox2 = x2;
    oy2 = y2;
  }
  
  void revert() {
    println("Revering segment " +name());
    x1 = ox1;
    y1 = oy1;
    x2 = ox2;
    y2 = oy2;
    map.updateConfig();
  }
  
  String getListName() {
    return name();
  }
  
  void leds(OPC opc) {
    float[] xs = interpolate(x1, x2, count);
    float[] ys = interpolate(y1, y2, count); 
    
    println("Placing " + count + " LEDs at " + this.name());
    int gi = this.globalIndex();
    for (int iX = 0; iX < count; iX++ ) {
      opc.led(gi + iX, int(xs[iX]), int(ys[iX]));
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
    map.updateConfig();
  }
}
