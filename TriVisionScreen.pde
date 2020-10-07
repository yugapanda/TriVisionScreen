import netP5.*;
import oscP5.*;
import java.net.InetAddress;
import java.net.UnknownHostException;
import processing.video.*;

PImage black;

ArrayList<ImageDrawBase> imageDraws = new ArrayList<ImageDrawBase>();

OscP5 oscP5;
int portNumber = 12001;
boolean settingsWindow = true;
ArrayList<Boolean> play = new ArrayList<Boolean>();
ArrayList<Boolean> end = new ArrayList<Boolean>();
InetAddress addr;
FolderMovies fm = new FolderMovies();
ArrayList<File> movieList = new ArrayList<File>();

boolean startCamera = false;

Capture camera;

void setup() {

  size(1280, 720, P2D);

  colorMode(RGB);

  oscP5 = new OscP5(this, portNumber);

  String[] cameras = Capture.list();
  
  for(String cam : cameras){
   println(cam); 
  }

  camera = new Capture(this, "name=USB ビデオ デバイス,size=1280x720,fs=30");
  camera.start();

  movieList = fm.getDataFileList();
  try {
    addr = InetAddress.getLocalHost();
  }
  catch(Exception e) {
    println(e);
  }

  for (File f : movieList) {
    println(f.getName());

    imageDraws.add(new MovieDraw(this, new Movie(this, f.getAbsolutePath()), false, false));
    play.add(false);
    end.add(false);
  }
}


void draw() {

  background(0);

  if (startCamera) {
    camera.read();
    image(camera, 0, 0, width, height);
  } else {

    if (settingsWindow) {

      for (int idx = 0; idx < movieList.size(); idx++) {

        text(movieList.get(idx).getName(), 10, 50 + idx * 50);
      }

      text(addr.getHostAddress() + " : " + portNumber, width - 200, 50);
    }

    for (int i = 0; i<imageDraws.size(); i++) {

      //println("start flag "+ i +": " + play[i]);
      ImageDrawBase imageDraw = imageDraws.get(i);
      if (play.get(i)) {

        imageDraw.doFadeIn();
        imageDraw.drawImage();
        tint(255, 255, 255, imageDraw._fadeAlpha);
        image(imageDraw._pg, 0, 0);
      }

      //println("end flag "+ i +": " + end[i]);

      if (end.get(i)) {
        if (imageDraw.end()) {
          play.set(i, false) ;
          end.set(i, false);
        }
        tint(255, 255, 255, imageDraw._fadeAlpha);
        imageDraw.drawImage();
        image(imageDraw._pg, 0, 0, width, height);
      }
    }
  }
}

void movieEvent(Movie m) {
  if (frameCount > 1 && m.available()) {
    m.read();
  }
}





void keyPressed() {

  if (key == ' ' && settingsWindow) {
    settingsWindow = false;
  } else if (key == ' ' && !settingsWindow) {

    settingsWindow = true;
  }
}

/**
 OSCを受信して動画の再生をしたりする
 */
void oscEvent(OscMessage theOscMessage) {


  //startを受け取ると動画を再生
  if (theOscMessage.checkAddrPattern("/start")) {

    play.set(theOscMessage.get(0).intValue(), true);
  }

  // endを受け取ると動画を停止
  if (theOscMessage.checkAddrPattern("/end")) {

    if (play.get(theOscMessage.get(0).intValue())) {
      end.set(theOscMessage.get(0).intValue(), true);
      play.set(theOscMessage.get(0).intValue(), false);
    }
  }

  //cameraを受け取るとカメラの入力を映したり消したりする
  if (theOscMessage.checkAddrPattern("/camera")) {
    startCamera = !startCamera;
  }

  if (theOscMessage.checkAddrPattern("/movieList")) {



    int number = theOscMessage.get(0).intValue();
    String ip = theOscMessage.get(1).stringValue();
    int port = theOscMessage.get(2).intValue();

    println("ip: " + ip + " port: " + port);

    NetAddress address = new NetAddress(ip, port);

    OscMessage message = new OscMessage("/movieList");
    message.add(number);

    for (File f : movieList) {
      message.add(f.getName());
    }

    oscP5.send(message, address);
  }
}