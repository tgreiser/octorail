/*
 * LEDMap
 * Handles mapping and communication with the OPC client
 *
 * (c) Tim Greiser - 2015
 * Released under the terms of MIT License
 */
 
class LEDMap {
  int h = 450;
  int w = 450;
  
  OPC opc;
  float[] activeDrivers;
  
  LEDMap(PApplet app, String server) {
    opc = new OPC(app, server, 7890);
  }
  
  void checkboxValues(float[] values) {
    activeDrivers = values;
  }
  
  void updateConfig() {
    if (activeDrivers == null || segmentController == null || opc == null) { return; }
    println("updateConfig");

    opc.reset();
    
    if (activeDrivers[0] == 1.0) segmentController.leds(opc, 1);
    if (activeDrivers[1] == 1.0) segmentController.leds(opc, 2);
    if (activeDrivers[2] == 1.0) segmentController.leds(opc, 3);
    if (activeDrivers[3] == 1.0) segmentController.leds(opc, 4);
    if (activeDrivers[4] == 1.0) segmentController.leds(opc, 5);
    
    segmentController.buildList();
  }
  
}
