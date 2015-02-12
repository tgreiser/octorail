/*
 * Handle
 * Drag and drop handle for a Bar/Segment
 *
 * (c) Tim Greiser - 2015
 * Released under the terms of MIT License
 */

class Handle {
  float x;
  float y;
  float size;
  Bar bar;
  boolean first;
  
  boolean mouseOver = false;
  boolean dragging = false;
  
  float offsetX = 0.0;
  float offsetY = 0.0;
  
  Handle(Bar _bar, boolean _first, float _size) {
    first = _first; //<>//
    if (first) {
      x = _bar.x1;
      y = _bar.y1;
    } else {
      x = _bar.x2;
      y = _bar.y2;
    }
    bar = _bar;
    size = _size;
  }
  
  void draw() {
    
    if (dragging) {
      fill(#FF7700);
      x = mouseX + offsetX;
      y = mouseY + offsetY;
    } else {
      float d =dist(mouseX, mouseY, x, y);
     
      if (d <= size/2.0) {
        mouseOver = true;
        stroke(255);
      } else {
        mouseOver = false;
        stroke(#FF7700);
      }
      fill(#FF7700);
    }
    ellipse(x+offsetX, y+offsetY, size, size);
  }
  
  void arrowAt(Handle h2) {
    arrow(int(x), int(y), int(h2.x), int(h2.y));
  }
  
  void arrow(int x1, int y1, int x2, int y2) {
    stroke(#FF7700);
    line(x1, y1, x2, y2);
    pushMatrix();
    translate(x2, y2);
    float a = atan2(x1-x2, y2-y1);
    rotate(a);
    line(0, 0, -10, -10);
    line(0, 0, 10, -10);
    popMatrix();
  }
  
  void clicked(float mx, float my) {
    if (mouseOver) {
      dragging = true;
      offsetX = x-mx;
      offsetY = y-my;
    }
  }
  
  void stopDragging() {
    if (dragging) {
      println("Stop dragging");
      dragging = false;
      
      if (first) {
        println("Updated first");
        bar.update(true, x, y);
      } else {
        bar.update(false, x, y);
        println("Updated second");
      }
    }
  }
}
