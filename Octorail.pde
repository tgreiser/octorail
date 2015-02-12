/*
 * Octorail
 * Configure and video map modular systems of LED strips using OPC / FadeCandy
 *
 * (c) Tim Greiser - 2015
 * Released under the terms of MIT License
 */

import controlP5.*;

OPC opc;
PImage dot;
int mode = 1;
ControlP5 c5;

CheckBox checkbox;
BarList bars;
Textlabel logo;
Textlabel tsec;

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

int h = 450;
int w = 450;

void setup()
{
  size(900, 450, P3D);
  
  int align = 450;
  frame.setResizable(false);
  
  opc = new OPC(this, server, 7890);
  
  c5 = new ControlP5(this);
  
  logo = c5.addTextlabel("label")
                    .setText("OCTORAIL")
                    .setPosition(705,0)
                    .setColorValue(cg1)
                    .setFont(createFont("Consolas",40))
                    ;
  tsec = new Textlabel(c5,"Toggle Drivers",align+285,55, 100,20, 255, 0);
    
  checkbox = c5.addCheckBox("drivers")
    .setPosition(align+250, 70);
  customize(checkbox);

  bars = new BarList(align);
  bars.load(sketchPath+"/data/bars.csv");

  dot = loadImage("dot.png");
  frameRate(60);

  setupVideo();
}

void customize(CheckBox cb) {
  cb.setColorForeground(cg1)
                .setColorActive(cg4)
                .setColorLabel(color(255))
                .setSize(20, 20)
                .setItemsPerRow(5)
                .setSpacingColumn(20)
                .setSpacingRow(20)
                .addItem("1", 1)
                .addItem("2", 2)
                .addItem("3", 3)
                .addItem("4", 4)
                .addItem("5", 5)
                .activateAll()
                ;
}

void customize(ListBox ddl, String label) {
  // a convenience function to customize a DropdownList
  ddl.setBackgroundColor(cb2);
  ddl.setItemHeight(20);
  ddl.setBarHeight(15);
  ddl.captionLabel().set(label);
  ddl.captionLabel().style().marginTop = 3;
  ddl.captionLabel().style().marginLeft = 3;
  ddl.captionLabel().setColor(cg1);
  ddl.valueLabel().style().marginTop = 3;
  
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

  if (mode == 1) {
    drawVideo();
  } else if (mode == 2) {
    drawRing();
  } else if (mode == 4) {
    drawDot();
  } else {
    drawRadar();
  }
  bars.draw();
  tsec.draw(this);
  stroke(color(0));
}

void updateConfig() {
  if (checkbox == null || bars == null || opc == null) { return; }
  println("updateConfig");
  float[] vals = checkbox.getArrayValue();

  opc.reset();
  
  if (vals[0] == 1.0) bars.leds(opc, 1);
  if (vals[1] == 1.0) bars.leds(opc, 2);
  if (vals[2] == 1.0) bars.leds(opc, 3);
  if (vals[3] == 1.0) bars.leds(opc, 4);
  if (vals[4] == 1.0) bars.leds(opc, 5);
  
  bars.buildList();
}

void controlEvent(ControlEvent theEvent) {
  
  if (theEvent.isFrom(checkbox)) {
    print("got an event from "+checkbox.getName()+"\t\n");
    // checkbox uses arrayValue to store the state of 
    // individual checkbox-items. usage:
    //opc.dispose();
    updateConfig();  
  } else if (theEvent.name().equals("videos")) {
    println("Event: "+theEvent.getGroup().getValue()+" from "+ theEvent.getGroup());
    playVideo(int(theEvent.getGroup().getValue()));
  }
  
  if (bars != null) bars.controlEvent(theEvent);
}

void checkBox(float[] a) {
  println(a);
}

void keyPressed() {
  if (bars != null && bars.isFocus() == true) {
    return;
  }
  
  keyPressedVideo();
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
  int m = (millis() / 50 ) % 60;
  float s = map(m, 0, 60, 0, TWO_PI) - HALF_PI;
  if (override != 0) { s = override; } 

  stroke(255);
  strokeWeight(5);
  int cx, cy;
  cx = h/2;
  cy = w/2;
  line(cx, cy, cx + cos(s) * cx, cy + sin(s) * cx);
}
float override = 0;

void mousePressed() {
  override();
  bars.clicked(mouseX, mouseY);
}

void mouseReleased() {
  bars.stopDragging();
}

void mouseDragged() {
  override();
}

void saveCallback(File selected) {
  bars.saveCallback(selected);
}

void loadCallback(File selected) {
  if (selected == null) { return; }
  bars.load(selected.getAbsolutePath());
}

void override() {
  if (mode == 2) {
    override = dist(w/2, h/2, mouseX, mouseY)*2;
  } else if (mode == 3) {
    int cx = w/2;
    int cy = h/2;
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
  if (ringCount++ > h) ringCount = 0;
  float size = float(ringCount);
  if (override > 0) { size = override; }
  fill(255);
  ellipse(h/2, w/2, size, size);
  fill(0);
  ellipse(h/2, w/2, size-10, size-10);
}

void drawDot() {
  
  // Change the dot size as a function of time, to make it "throb"
  float dotSize = height * 0.6 * (1.0 + 0.2 * sin(millis() * 0.01));
  
  // Draw it centered at the mouse location
  image(dot, mouseX - dotSize/2, mouseY - dotSize/2, dotSize, dotSize);
}

void stop() {
  stopVideo();
}

