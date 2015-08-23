/*
 * Octorail
 * Configure and video map modular systems of LED strips using OPC / FadeCandy
 * https://github.com/tgreiser/octorail
 *
 * (c) Tim Greiser - 2015
 * Released under the terms of MIT License
 */

import controlP5.*;
import java.util.Arrays;

DriverController driverController;
VideoController videoController;
SegmentController segmentController;

Controller[] ctrls;
LEDMap map;

PImage dot;
int mode = 1;
ControlP5 c5;

Textlabel logo;

color cb1 = #728CA6;
color cb2 = #4A6B8A;
color cb3 = #2A4D6E;
color cb4 = #133453;
color cb5 = #041E37;

color cp1 = #827FB2;
color cp2 = #585594;
color cp3 = #363377;
color cp4 = #1D1959;
color cp5 = #0B083B;

color cg1 = #72AB97;
color cg2 = #478E75;
color cg3 = #267257;
color cg4 = #0E553C;
color cg5 = #003925;

String server = "127.0.0.1";

void setup()
{
  println("Begin...");
  map = new LEDMap(this, server);
  println("Connected to " + server);
  
  size(map.w*2, map.h, P3D);
  frame.setResizable(false);
  frameRate(60);
  
  ctrls = new Controller[3];
  driverController = new DriverController();
  videoController = new VideoController();
  println("Initialize segmentController");
  segmentController = new SegmentController();
  ctrls[0] = videoController;
  ctrls[1] = segmentController;
  ctrls[2] = driverController;
  
  println("Initialized controllers");
  
  c5 = new ControlP5(this);
  
  logo = c5.addTextlabel("label")
                    .setText("OCTORAIL")
                    .setPosition(705,0)
                    .setColorValue(cg1)
                    .setFont(createFont("Consolas",40))
                    ;
   
  dot = loadImage("dot.png");
  
  println("Setting up controllers...");
  int iX = 0;
  for (Controller c : ctrls) {
    println("Controller " + iX++);
    c.setup(this, map);
  }
}

void customize(ScrollableList ddl, String label) {
  // a convenience function to customize a DropdownList
  ddl.setBackgroundColor(cb2);
  ddl.setItemHeight(20);
  ddl.setBarHeight(15);
  ddl.getCaptionLabel().set(label);
  ddl.getCaptionLabel().getStyle().marginTop = 3;
  ddl.getCaptionLabel().getStyle().marginLeft = 3;
  ddl.getCaptionLabel().setColor(cg1);
  ddl.getValueLabel().getStyle().marginTop = 3;
  
  //ddl.scroll(0);
  ddl.setColorBackground(cb3);
  ddl.setColorActive(cb4);
}

void draw()
{
  background(0);
  
  fill(cb5);
  rect(450, 0, 900, 450);
  
  //println(frameRate);

  videoController.active = (mode == 1);
  for (Controller c : ctrls) {
    c.draw();
  }
  
  if (mode == 2) {
    drawRing();
  } else if (mode == 4) {
    drawDot();
  } else if (mode == 5) {
    drawRadar();
  }
  
  stroke(color(0));
}

void controlEvent(ControlEvent theEvent) {
  
  for (Controller c : ctrls) {
    c.controlEvent(theEvent);
  }
}

void keyPressed() {
  if (segmentController != null && segmentController.isFocus() == true) {
    return;
  }
  
  for (Controller c : ctrls) {
    c.keyPressed();
  }
  
  override = 0;
  //mode = key - 48;
  if (key == 46) {
    mode = 2;
  } else if (key == 47) {
    mode = 3;
  } else if (key == 42) {
    mode = 4;
  } else if (key == 10) {
    mode = 5;
  } else if (key > 48 && key < 57) {
    mode = 1 ;
  }
}

int radarCount = 0;
void drawRadar() {
  println("Draw radar");
  int m = (millis() / 50 ) % 60;
  float s = map(m, 0, 60, 0, TWO_PI) - HALF_PI;
  if (override != 0) { s = override; } 

  stroke(255);
  strokeWeight(5);
  int cx, cy;
  cx = map.h/2;
  cy = map.w/2;
  line(cx, cy, cx + cos(s) * cx, cy + sin(s) * cx);
}
float override = 0;

void mousePressed() {
  for (Controller c : ctrls) {
    c.mousePressed();
  }
}

void mouseReleased() {
  for (Controller c : ctrls) {
    c.mouseReleased();
  }
}

void mouseDragged() {
  for (Controller c : ctrls) {
    c.mouseDragged();
  }
}

void saveCallback(File selected) {
  segmentController.saveCallback(selected);
}

void loadCallback(File selected) {
  if (selected == null) { return; }
  segmentController.load(selected.getAbsolutePath());
}

void override() {
  if (mode == 2) {
    override = dist(map.w/2, map.h/2, mouseX, mouseY)*2;
  } else if (mode == 3) {
    int cx = map.w/2;
    int cy = map.h/2;
    int dy = mouseY - cy;
    int dx = mouseX - cx;
    
    float slope = 0;
    if (dx != 0) { slope = float(dy) / float(dx); }
    
    override = atan(slope);
    // make the negative side of the circle work
    if (dx < 0) { override = override + 3; }
  }
}

int ringCount = 0;
void drawRing() {
  stroke(255);
  strokeWeight(4);
  if (ringCount++ > map.h) ringCount = 0;
  float size = float(ringCount);
  if (override > 0) { size = override; }
  fill(255);
  ellipse(map.h/2, map.w/2, size, size);
  fill(0);
  ellipse(map.h/2, map.w/2, size-10, size-10);
}

void drawDot() {
  
  // Change the dot size as a function of time, to make it "throb"
  float dotSize = height * 0.6 * (1.0 + 0.2 * sin(millis() * 0.01));
  
  // Draw it centered at the mouse location
  image(dot, mouseX - dotSize/2, mouseY - dotSize/2, dotSize, dotSize);
}

void stop() {
  for (Controller c : ctrls) {
    c.stop();
  }
}
