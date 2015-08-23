class Controller {
  LEDMap map;
  PApplet app;
  // Override these!
  void setup(PApplet _app, LEDMap _map) {
    map = _map;
    app = _app;
  }
  void draw() { }
  void controlEvent(ControlEvent theEvent) { }
  void keyPressed() { }
  void stop() { }
  void mousePressed() { }
  void mouseReleased() { }
  void mouseDragged() { override(); }

}
