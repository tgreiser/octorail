/*
 * Octorail
 * Configure and video map modular systems of LED strips using OPC / FadeCandy
 * https://github.com/tgreiser/octorail
 *
 * (c) Tim Greiser - 2015
 * Released under the terms of MIT License
 */

int HANDLE_SIZE = 6;

class SegmentController extends Controller {
  ScrollableList segList;
  Textfield driver;
  Textfield rail;
  Textfield segment;
  Textfield count;
  
  Button reset;
  Button delete;
  Button addSeg; 
  Button apply;
  Button imp;
  Button exp;
  Button swap;
  Button clear;
  
  Segment[] segments;
  int selected = -1;
  Handle h1;
  Handle h2;
  
  int spacer = 10;
  int top;
  color colForm = color(255);
  color colButton = cp3;
  
  void setup(PApplet _app, LEDMap _map) {
    super.setup(_app, _map);
    
    segments = new Segment[0];
    top = map.h/2+spacer;
    segList = c5.addScrollableList("segments")
      .setPosition(map.w+spacer, 15+top)
      .setSize(230, 205)
      .setType(ControlP5.LIST)
      .setItemHeight(20)
      .setBarHeight(20)
      .setColorBackground(cb3)
      .setColorActive(cg1);
    customize(segList, "Segments");
    
    int left = map.w+spacer*2+230;
    imp = c5.addButton("Import Segs")
      .setPosition(left, top)
      .setColorBackground(colButton)
      .setSize(55, 19);    
    
    exp = c5.addButton("Export Segs")
      .setPosition(left+spacer+55, top)
      .setColorBackground(colButton)
      .setSize(57, 19);
      
    clear = c5.addButton("Clear Segs")
      .setPosition(left+spacer*2+55*2, top)
      .setColorBackground(colButton)
      .setSize(57, 19);
      
    // form
    driver = c5.addTextfield("driver")
      .setPosition(left, top+30)
      .setSize(55, 19)
      .setColor(colForm);
      
    rail =c5.addTextfield("rail")
      .setPosition(left+spacer+55, top+30)
      .setSize(55, 19)
      .setColor(colForm);
      
    segment = c5.addTextfield("segment")
      .setPosition(left, top+70)
      .setSize(55, 19)
      .setColor(colForm);
      
    count = c5.addTextfield("count")
      .setPosition(left+spacer+55, top+70)
      .setSize(55, 19)
      .setColor(colForm);
            
    addSeg = c5.addButton("Add Seg")
      .setPosition(left, 390)
      .setColorBackground(colButton)
      .setSize(55, 19);
    
    apply = c5.addButton("Apply")
      .setColorBackground(colButton)
      .setPosition(left, 420)
      .setSize(55, 19);
      
    swap = c5.addButton("Swap Pts")
      .setColorBackground(colButton)
      .setPosition(left+spacer+55, 420)
      .setSize(55, 19);
      
    reset = c5.addButton("Reset")
      .setPosition(left+spacer*2+55*2, 420)
      .setColorBackground(colButton)
      .setSize(55, 19);
      
    delete = c5.addButton("Delete Seg")
      .setPosition(left+spacer*2+55*2, 390)
      .setColorBackground(colButton)
      .setSize(55, 19);
      
    hideElements();
    
    this.load(sketchPath+"/data/default.csv");
  }
  
  // if a segment is selected, draw the handles
  void draw() {
    if (selected > -1 && selected < segments.length) {
      //println("Drawing points for bar " + bars[selected].getListName());
      stroke(1);
      h1.draw();
      h1.arrowAt(h2);
      h2.draw();
    }
  }
  
  boolean isFocus() {
    return driver.isFocus() || rail.isFocus() || segment.isFocus();
  }
  
  void controlEvent(ControlEvent theEvent) {
    if (theEvent.isFrom(delete)) {
      deleteSegment();
    } else if (theEvent.isFrom(reset)) {
      reset();
    } else if (theEvent.isFrom(addSeg)) {
      addSegment();
    } else if (theEvent.isFrom(exp)) {
      save();
    } else if (theEvent.isFrom(imp)) {
      importBrowse();
    } else if (theEvent.isFrom(apply)) {
      apply();
    } else if (theEvent.isFrom(segList)) {
      int sel = (int)theEvent.getValue();
      selected(sel, true);
    } else if (theEvent.isFrom(swap)) {
      swapSelectedPoints();
    } else if (theEvent.isFrom(clear)) {
      clearSegments();
    }
  }
  
  void mousePressed() {
    if (h1 != null) h1.clicked(mouseX, mouseY);
    if (h2 != null) h2.clicked(mouseX, mouseY);
  }
  
  void mouseReleased() {
    if (h1 != null) h1.stopDragging();
    if (h2 != null) h2.stopDragging();
  }
  
  void leds(OPC opc, int _driver) {
    for (Segment s : segments) {
      if (s == null) {
        println("Null record in segments!");
        continue;
      }
      if (s.driver == _driver) {
        s.leds(opc);
      }
    }
  }
  
  // save values to bar, de-select
  void apply() {
    if (selected < 0) { return; }
    saveTextfields();
    
    map.updateConfig();
    
    deselect();
  }
  
  void saveTextfields() {
    if (segments[selected] == null) {
      println("Null record! Selected index:");
      println(selected);
      return;
    }
    segments[selected].driver = int(driver.getText());
    segments[selected].rail = int(rail.getText());
    segments[selected].index = int(segment.getText());
    segments[selected].count = int(count.getText());
  }
  
  void swapSelectedPoints() {
    if (selected < 0) { return; }
    
    segments[selected].backupLocations();
    float tx = segments[selected].x1;
    float ty = segments[selected].y1;
    segments[selected].x1 = segments[selected].x2;
    segments[selected].y1 = segments[selected].y2;
    segments[selected].x2 = tx;
    segments[selected].y2 = ty;
    
    //updateConfig();
    selected(selected, false);
  }
  
  void addSegment() {
    if (selected == -1) {
      selected = segments.length;
    } else {
      selected += 1;
    }
    
    segments = array_add(segments, selected);
    println("Selected " + str(selected)+" - Segments length " + str(segments.length));
    int new_ptr = selected;
    if (selected != segments.length-1) { deselect(); }
    map.updateConfig();
    selected(new_ptr, true);
    
    driver.setValue("1");
    rail.setValue("1");
    segment.setValue("0");
    count.setValue("30");
    
    segList.setValue(selected);
    
    driver.setFocus(true);
    
    //float scroll = float(new_ptr+1) / float(segments.length);
    //println("Scroll to " + str(scroll));
    //segList.scroll(selected);
  }
  
  void deleteSegment() {
    if (selected > -1) {
      println("Deleting!");
      int new_ptr = selected;
      deselect();
      
      segList.removeItem(segments[new_ptr].name());
      segments = array_remove(segments, new_ptr);
      
      map.updateConfig();
      println("Left: " + str(segments.length));
    }
  }
  
  // de-select everything, null the handles, trigger revert on the bar.
  void reset() {
    if (selected < 0) { return; }
    segments[selected].revert();
    deselect();
  }
  
  void deselect() {
    unset(selected);
    driver.setValue("");
    rail.setValue("");
    segment.setValue("");
    count.setValue("");
    selected = -1;
    h1 = null;
    h2 = null;
    hideElements();
  }
  
  void clearSegments() {
    if (selected >= 0) { deselect(); }
    segments = new Segment[0];
    segList.clear();
    map.updateConfig();
  }
  
  void importBrowse() {
    deselect();
    selectInput("What config would you like to load?", "loadCallback", new File(sketchPath+"/data/default.csv"));
  }
  
  void load(String filename) {
    Table table = loadTable(filename, "header");
    
    segments = new Segment[table.getRowCount()];
    int iX = 0;
    for (TableRow row : table.rows()) {
      segments[iX++] = new Segment(row.getInt("driver"), row.getInt("rail"), row.getInt("segment"), row.getInt("count"),
        row.getFloat("x1"), row.getFloat("y1"),
        row.getFloat("x2"), row.getFloat("y2")
        );
    }
    
    map.updateConfig();
  }
  
  void save() {
    apply();
    println("Running selectOutput..");
    selectOutput("Where would you like to save your config?", "saveCallback", new File(sketchPath+"/data/export.csv"));
  }
  
  void saveCallback(File selection) {
    if (selection == null) { return; }
    String fn = selection.getAbsolutePath();
    println("Saving " + fn);
    String[] data = new String[segments.length+1];
    int iX = 1;
    data[0] = "driver,rail,segment,count,x1,y1,x2,y2";
    for (Segment s : segments) {
      data[iX++] = str(s.driver)+","+str(s.rail)+","+str(s.index)+","+str(s.count)+","+str(s.x1)+","+str(s.y1)+","+str(s.x2)+","+
        str(s.y2);
    }
    
    saveStrings(fn, data);
    map.updateConfig();
  }
  
  void buildList() {
    segList.clear();
    for (int iX = 0; iX < segments.length; iX++) {
      if (segments[iX] == null) {
        println("Segment is null at " + str(iX));
        continue;
      }
      segList.addItem(segments[iX].getListName(), iX);
    }
  }
  
  void selected(int sel, boolean setUndo) {
    if (sel >= segments.length) { return; }
    
    println("Selecting " + segments[sel].getListName());
    if (selected >=0) {
      // set the old pick back to bg
      unset(selected);
      // we are doing auto-apply here
      saveTextfields();
    }
    selected = sel;
    //segList.getItem(selected).setColorBackground(cg2);
    
    if (setUndo == true) { segments[sel].backupLocations(); }
    h1 = new Handle(segments[sel], true, float(HANDLE_SIZE));
    h2 = new Handle(segments[sel], false, float(HANDLE_SIZE));
    
    driver.setValue(str(segments[sel].driver));
    rail.setValue(str(segments[sel].rail));
    segment.setValue(str(segments[sel].index));
    count.setValue(str(segments[sel].count));
        
    showElements();
  }
  
  void showElements() {
    driver.show();
    rail.show();
    segment.show();
    count.show();
    delete.show();
    reset.show();
    apply.show();
    swap.show();
  }
  
  void hideElements() {
    driver.hide();
    rail.hide();
    segment.hide();
    count.hide();
    delete.hide();
    reset.hide();
    apply.hide();
    swap.hide();
  }
  
  void unset(int index) {
    if (index < 0) { return; }
    //ListBoxItem item = segList.getItem(index);
    //item.setColorBackground(cb3);
  }
  
  void customizePts(ScrollableList ddl) {
    // a convenience function to customize a DropdownList
    ddl.setBackgroundColor(color(190));
    ddl.setItemHeight(20);
    ddl.setBarHeight(15);
    ddl.getCaptionLabel().set("Segments");
    ddl.getCaptionLabel().getStyle().marginTop = 3;
    ddl.getCaptionLabel().getStyle().marginLeft = 3;
    ddl.getCaptionLabel().setColor(0xffff0000);
    ddl.getValueLabel().getStyle().marginTop = 3;
    
    //ddl.scroll(0);
    ddl.setColorBackground(color(60));
    ddl.setColorActive(color(255, 128));
  }
  
  Segment[] array_remove(Segment array[], int item) {
    println("Removing segment at index " + str(item));
    Segment outgoing[] = new Segment[array.length - 1];
    System.arraycopy(array, 0, outgoing, 0, item);
    System.arraycopy(array, item+1, outgoing, item, array.length - (item + 1));
    return outgoing;
  }
  
  Segment[] array_add(Segment array[], int at) {
    println("Adding segment at index " + str(at));
    Segment outgoing[] = new Segment[array.length + 1];
    System.arraycopy(array, 0, outgoing, 0, at);
    outgoing[at] = new Segment(1, 1, 0, 30,
      5.0, 5.0, 50.0, 50.0);
    System.arraycopy(array, at, outgoing, at+1, array.length - (at));
    return outgoing;
  }
}
