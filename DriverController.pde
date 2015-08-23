/*
 * Octorail
 * Configure and video map modular systems of LED strips using OPC / FadeCandy
 * https://github.com/tgreiser/octorail
 *
 * (c) Tim Greiser - 2015
 * Released under the terms of MIT License
 */

class DriverController extends Controller {
  CheckBox checkbox;
  Textlabel tsec;
  
  void setup(PApplet _app, LEDMap _map) {
    super.setup(_app, _map);
    
    tsec = new Textlabel(c5,"Toggle Drivers",map.w+285,55, 100,20);
    
    checkbox = c5.addCheckBox("drivers")
      .setPosition(map.w+250, 70);
    customize(checkbox); //<>//
    checkbox.activateAll();
  }
  
  void draw() {
    tsec.draw(app);
  }
  
  void controlEvent(ControlEvent theEvent) {
    if (theEvent.isFrom(checkbox)) {
      print("got an event from "+checkbox.getName()+"\t\n");
      map.checkboxValues(checkbox.getArrayValue());
      map.updateConfig();
    }
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
      .addItem("5", 5);
  }
}
