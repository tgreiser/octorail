/*
 * BarList
 * Multi-purpose controller
 *
 * (c) Tim Greiser - 2015
 * Released under the terms of MIT License
 */

int HANDLE_SIZE = 6;

class BarList {
  ListBox pts;
  Textfield driver;
  Textfield bar;
  Textfield count;
  Textfield index;
  Textfield name;
  
  Button reset;
  Button delete;
  Button add_seg; 
  Button apply;
  Button imp;
  Button exp;
  Button swap;
  Button clear;
  
  Bar[] bars;
  int selected = -1;
  Handle h1;
  Handle h2;
  
  int spacer = 10;
  int top = 225+spacer;
  color colForm = color(255);
  color colButton = cp3;
  
  BarList(int align) {
    pts = c5.addListBox("bars")
      .setPosition(align+spacer, 15+top)
      .setSize(230, 205);
    customize(pts, "Segments");
    
    int left = align+spacer*2+230;
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
      
    bar =c5.addTextfield("segment")
      .setPosition(left+spacer+55, top+30)
      .setSize(55, 19)
      .setColor(colForm);
      
    count = c5.addTextfield("count")
      .setPosition(left, top+70)
      .setSize(55, 19)
      .setColor(colForm);
      
    index = c5.addTextfield("index")
      .setPosition(left+spacer+55, top+70)
      .setSize(55, 19)
      .setColor(colForm);
      
    name = c5.addTextfield("name")
      .setPosition(left, top+110)
      .setSize(110+spacer, 19)
      .setColor(colForm);
      
    
      
    add_seg = c5.addButton("Add Seg")
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
  }
  
  boolean isFocus() {
    return driver.isFocus() || bar.isFocus() || count.isFocus() || index.isFocus() || name.isFocus();
  }
  
  void leds(OPC opc, int _driver) {
    for (Bar b : bars) {
      if (b == null) {
        println("Null record in bars!");
        continue;
      }
      if (b.driver == _driver) {
        b.leds(opc);
      }
    }
  }
  
  // save values to bar, de-select
  void apply() {
    if (selected < 0) { return; }
    saveTextfields();
    
    updateConfig();
    
    deselect();
  }
  
  void saveTextfields() {
    if (bars[selected] == null) {
      println("Null record! Selected index:");
      println(selected);
      return;
    }
    bars[selected].driver = int(driver.getText());
    bars[selected].bar = int(bar.getText());
    bars[selected].count = int(count.getText());
    bars[selected].index = int(index.getText());
    bars[selected].name = name.getText();
  }
  
  void controlEvent(ControlEvent theEvent) {
    if (theEvent.isFrom(delete)) {
      deleteBar();
    } else if (theEvent.isFrom(reset)) {
      reset();
    } else if (theEvent.isFrom(add_seg)) {
      addSegment();
    } else if (theEvent.isFrom(exp)) {
      save();
    } else if (theEvent.isFrom(imp)) {
      importBrowse();
    } else if (theEvent.isFrom(apply)) {
      apply();
    } else if (theEvent.isFrom(pts)) {
      int sel = int(theEvent.getGroup().getValue());
      selected(sel, true);
    } else if (theEvent.isFrom(swap)) {
      swapSelectedPoints();
    } else if (theEvent.isFrom(clear)) {
      clearSegments();
    }
  }
  
  void swapSelectedPoints() {
    if (selected < 0) { return; }
    
    bars[selected].backupLocations();
    float tx = bars[selected].x1;
    float ty = bars[selected].y1;
    bars[selected].x1 = bars[selected].x2;
    bars[selected].y1 = bars[selected].y2;
    bars[selected].x2 = tx;
    bars[selected].y2 = ty;
    
    //updateConfig();
    selected(selected, false);
  }
  
  void addSegment() {
    if (selected == -1) { selected = bars.length; }
    
    bars = array_add(bars, selected);
    println("Selected " + str(selected)+" - Bars length " + str(bars.length));
    int new_ptr = selected;
    if (selected != bars.length-1) { deselect(); }
    updateConfig();
    selected(new_ptr, true);
    driver.setFocus(true);
    
    float scroll = float(new_ptr+1) / float(bars.length);
    println("Scroll to " + str(scroll));
    pts.scroll(scroll);
  }
  
  void deleteBar() {
    if (selected > -1) {
      println("Deleting!");
      int new_ptr = selected;
      deselect();
      
      pts.removeItem(bars[new_ptr].name);
      bars = array_remove(bars, new_ptr);
      
      updateConfig();
      println("Left: " + str(bars.length));
    }
  }
  
  // de-select everything, null the handles, trigger revert on the bar.
  void reset() {
    if (selected < 0) { return; }
    bars[selected].revert();
    deselect();
  }
  
  void deselect() {
    unset(selected);
    driver.setValue("");
    bar.setValue("");
    count.setValue("");
    index.setValue("");
    name.setValue("");
    selected = -1;
    h1 = null;
    h2 = null;
    hideElements();
  }
  
  void clearSegments() {
    if (selected >= 0) { deselect(); }
    bars = new Bar[0];
    pts.clear();
    updateConfig();
  }
  
  void importBrowse() {
    deselect();
    selectInput("What config would you like to load?", "loadCallback", new File(sketchPath+"/data/bars.csv"));
  }
  
  void load(String filename) {
    Table table = loadTable(filename, "header");
    
    bars = new Bar[table.getRowCount()];
    int iX = 0;
    for (TableRow row : table.rows()) {
      bars[iX++] = new Bar(row.getString("name"), row.getInt("driver"), row.getInt("bar"), row.getInt("index"), row.getInt("count"),
        row.getFloat("x1"), row.getFloat("y1"),
        row.getFloat("x2"), row.getFloat("y2")
        );
    }
    
    updateConfig();
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
    String[] data = new String[bars.length+1];
    int iX = 1;
    data[0] = "driver,bar,x1,y1,x2,y2,index,count,name";
    for (Bar b : bars) {
      data[iX++] = str(b.driver)+","+str(b.bar)+","+str(b.x1)+","+str(b.y1)+","+str(b.x2)+","+
        str(b.y2)+","+str(b.index)+","+str(b.count)+","+b.name;
    } // finish CSV TODO
    
    saveStrings(fn, data);
    updateConfig();
  }
  
  void buildList() {
    pts.clear();
    for (int iX = 0; iX < bars.length; iX++) {
      if (bars[iX] == null) {
        println("Bar is null at " + str(iX));
        continue;
      }
      pts.addItem(bars[iX].getListName(), iX);
    }
  }
  
  void selected(int sel, boolean setUndo) {
    if (sel >= bars.length) { return; }
    
    println("Selecting " + bars[sel].getListName());
    if (selected >=0) {
      // set the old pick back to bg
      unset(selected);
      // we are doing auto-apply here
      saveTextfields();
    }
    selected = sel;
    pts.getItem(selected).setColorBackground(cg2);
    
    if (setUndo == true) { bars[sel].backupLocations(); }
    h1 = new Handle(bars[sel], true, float(HANDLE_SIZE));
    h2 = new Handle(bars[sel], false, float(HANDLE_SIZE));
    
    driver.setValue(str(bars[sel].driver));
    bar.setValue(str(bars[sel].bar));
    count.setValue(str(bars[sel].count));
    index.setValue(str(bars[sel].index));
    name.setValue(bars[sel].name);
    
    showElements();
  }
  
  void showElements() {
    driver.show();
    bar.show();
    count.show();
    index.show();
    name.show();
    delete.show();
    reset.show();
    apply.show();
    swap.show();
  }
  
  void hideElements() {
    driver.hide();
    bar.hide();
    count.hide();
    index.hide();
    name.hide();
    delete.hide();
    reset.hide();
    apply.hide();
    swap.hide();
  }
  
  void unset(int index) {
    if (index < 0) { return; }
    ListBoxItem item = pts.getItem(index);
    item.setColorBackground(cb3);
  }
  
  // if a bar is selected, draw the handles
  void draw() {
    if (selected > -1 && selected < bars.length) {
      //println("Drawing points for bar " + bars[selected].getListName());
      h1.draw();
      h1.arrowAt(h2);
      h2.draw();
    }
  }
  
  void clicked(float x, float y) {
    if (h1 != null) h1.clicked(x, y);
    if (h2 != null) h2.clicked(x, y);
  }
  
  void stopDragging() {
    if (h1 != null) h1.stopDragging();
    if (h2 != null) h2.stopDragging();
  }
}

void customizePts(ListBox ddl) {
  // a convenience function to customize a DropdownList
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(20);
  ddl.setBarHeight(15);
  ddl.captionLabel().set("Bars");
  ddl.captionLabel().style().marginTop = 3;
  ddl.captionLabel().style().marginLeft = 3;
  ddl.captionLabel().setColor(0xffff0000);
  ddl.valueLabel().style().marginTop = 3;
  
  //ddl.scroll(0);
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
}

Bar[] array_remove(Bar array[], int item) {
  println("Removing segment at index " + str(item));
  Bar outgoing[] = new Bar[array.length - 1];
  System.arraycopy(array, 0, outgoing, 0, item);
  System.arraycopy(array, item+1, outgoing, item, array.length - (item + 1));
  return outgoing;
}

Bar[] array_add(Bar array[], int at) {
  println("Adding segment at index " + str(at));
  Bar outgoing[] = new Bar[array.length + 1];
  System.arraycopy(array, 0, outgoing, 0, at);
  outgoing[at] = new Bar("", 0, 0, 10, 0,
    5.0, 5.0, 50.0, 50.0);
  System.arraycopy(array, at, outgoing, at+1, array.length - (at));
  return outgoing;
}
