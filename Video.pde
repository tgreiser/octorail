/*
 * Video
 * Video Controller
 *
 * (c) Tim Greiser - 2015
 * Released under the terms of MIT License
 */

import processing.video.*;

Movie movie;

ListBox d1;
boolean playing;

void setupVideo() {
  background(0);

  int spacer = 10;
  d1 = c5.addListBox("videos")
    .setPosition(w+spacer, 15+spacer)
    .setSize(230,205);
  
  customize(d1, "Movies - Press 0-1");
  initVideos();
  
  movie = new Movie(this, "aeDomeDesign_1.mov");
  movie.loop();
  playing = true;
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

void stopVideo() {
  movie = null;
}

void playVideo(int sel) {
  String file = d1.getItem(sel).getText();
  println("Playing video : "+file);
  movie = new Movie(this, file);
  movie.loop();
}

void drawVideo()
{
  image(movie, 0, 0, w, h);
}

void keyPressedVideo() {
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
      file = d1.getItem(key-48).getText();
      
      println("Loading " + file);
      movie = new Movie(this, file);
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
