/*
 * Video
 * Video Controller
 *
 * (c) Tim Greiser - 2015
 * Released under the terms of MIT License
 */

import processing.video.*;
import java.util.Map;

class VideoController extends Controller {
  boolean active = false;

  Movie movie;
  ScrollableList d1;
  boolean playing;

  void setup(PApplet _app, LEDMap _map) {
    super.setup(_app, _map);
    background(cb1);
  
    int spacer = 10;
    d1 = c5.addScrollableList("videos")
      .setPosition(map.w+spacer, 15+spacer)
      .setType(ControlP5.LIST)
      .setColorBackground(cb3)
      .setColorActive(cg1)
      .setSize(230,205);
    
    customize(d1, "Movies - Press 0-1");
    initVideos();
    
    movie = new Movie(app, "aeDomeDesign_1.mov");
    movie.loop();
    playing = true;
    println("Video setup and playing");
  }
  
  void initVideos() {
    File[] files = new File(sketchPath+"/data").listFiles();
    int iX = 0;
    for (int i=0;i<files.length;i++) {
      String name = files[i].getName();
      
      if (name.toLowerCase().endsWith(".mov") == false) { continue; }
      println("Added " + name + " at " + str(iX));
      d1.addItem(name, iX++);
    }
  }
  
  Movie movie() {
    return movie;
  }
  
  void stop() {
    movie.dispose();
    movie = null;
  }
  
  void playVideo(int sel) {
    Map<String,Object> vi = d1.getItem(sel);
    String filekey = "text";
    String file = vi.get(filekey).toString();
    println("Playing video : "+file);
    movie.dispose();
    movie = null;
    movie = new Movie(app, file);
    movie.loop();
  }
  
  void draw()
  {
    if (active == true) {
      //println("Drawing movie frame");
      //println(movie);
      if (movie.available()) {
        movie.read();
      }
      image(movie, 0, 0, map.w, map.h);
    }
  }
  
  void controlEvent(ControlEvent theEvent) {
    if (theEvent.isFrom(d1)) {
      videoController.playVideo(int(theEvent.getValue()));
    }
  }
  
  void keyPressed() {
    println(key);
    if (key == 32) {
      if (playing == true) {
        movie.pause();
        playing = false;
      } else {
        movie.play();
        playing = true;
      }
    }
    if (key >= 48 && key <= 57) {
      String file = "";
      try {
        Map<String,Object> vi = d1.getItem(key-48);
        file = vi.get("text").toString();
        
        println("Loading " + file);
        movie = new Movie(app, file);
        movie.loop();
      } catch (java.lang.IndexOutOfBoundsException e) {
        // no need to complain
      }  
    }
    
    if (key == CODED) {
      
    }
  }
  
  void movieEvent(Movie m) {
    if (m != null) {
      m.read();
    }
  }
}
