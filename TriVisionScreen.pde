import netP5.*;
import oscP5.*;
import java.net.InetAddress;
import java.net.UnknownHostException;
import processing.video.*;

PImage black;

ArrayList<MoviePlayer> imageDraws = new ArrayList<MoviePlayer>();

OscP5 oscP5;
int portNumber = 12001;
boolean settingsWindow = true;
ArrayList<Boolean> start = new ArrayList<Boolean>();
ArrayList<Boolean> playing = new ArrayList<Boolean>();
ArrayList<Boolean> end = new ArrayList<Boolean>();
NetAddress address;

InetAddress addr;
FolderMovies fm = new FolderMovies();
File[] movieList;

boolean startCamera = false;

Capture camera;

void setup() { 

  size(1280, 720, P2D);

  noCursor();

  colorMode(RGB);

  oscP5 = new OscP5(this, portNumber);

  String[] cameras = Capture.list();
  if (cameras.length > 0) {
    for (String cam : cameras) {
      println(cam);
    }

    camera = new Capture(this, "name=Logicool HD Pro Webcam C910,size=1280x720,fs=30");
    camera.start();
  }



  try {
    addr = InetAddress.getLocalHost();
  }
  catch(Exception e) {
    println(e);
  }

  initAll();
}


void draw() {

  try{
  background(0);

  if (startCamera) {
    camera.read();
    image(camera, 0, 0, width, height);
  } else {

    if (settingsWindow) {

      for (int idx = 0; idx < movieList.length; idx++) {

        text(movieList[idx].getName(), 10, 50 + idx * 50);
      }

      text(addr.getHostAddress() + " : " + portNumber, width - 200, 50);
    }

    for (int i = 0; i<imageDraws.size(); i++) {

      //println("start flag "+ i +": " + play[i]);
      final MoviePlayer imageDraw = imageDraws.get(i);

      if (playing.get(i)) {
        imageDraw.draw();
      }

      //スタートフラグが立っていたムービーについて
      if (start.get(i)) {
        //再生をスタートさせる。この動画は先にinitが呼ばれて初期化されている想定
        imageDraw.start();
        //スタートフラグをfalseにして、再度再生されないようにする
        start.set(i, false);
        //プレイフラグを立てて、どれを再生しているのかわかるようにする
        playing.set(i, true);

        //次の動画がある場合、それを初期化する
        if (imageDraws.size() < i + 1) {
          final int index = i + 1;
          Thread thread = new Thread(new Runnable() {
            public void run() {
              imageDraws.get(index).init();
            }
          }
          );

          thread.start();
        }
      }

      if (end.get(i)) {
        Thread thread = new Thread(new Runnable() {
          public void run() {
            imageDraw.end();
          }
        }
        );
        thread.start();
        end.set(i, false);
        playing.set(i, false);
      }
    }
  }
  }catch(Exception e){
   println(e); 
  }
}

void movieEvent(Movie m) {

  m.read();
  if (address != null) {
    OscMessage message = new OscMessage("/progress");

    message.add(m.time());
    message.add(m.duration());
    
    oscP5.send(message, address);
  }
}


void initAll() {

  try {
    movieList = fm.chooseFolder().listFiles();

    for (File f : movieList) {
      println(f.getName());

      imageDraws.add(new MoviePlayer(new Movie(this, f.getAbsolutePath())));
      start.add(false);
      playing.add(false);
      end.add(false);
    }

    if (imageDraws.size() > 0) {

      imageDraws.get(0).init();
    }
  }
  catch(Exception e) {
    println("ファイルの読み込みをキャンセルしないでください");
  }
}


void keyPressed() {

  if (key == ' ' && settingsWindow) {
    settingsWindow = false;
  } else if (key == ' ' && !settingsWindow) {

    settingsWindow = true;
  }
  if (key == 'r') {
    initAll();
  }
}

/**
 OSCを受信して動画の再生をしたりする
 */
void oscEvent(OscMessage theOscMessage) {


  //startを受け取ると動画を再生
  if (theOscMessage.checkAddrPattern("/start")) {

    start.set(theOscMessage.get(0).intValue(), true);
  }

  // endを受け取ると動画を停止
  if (theOscMessage.checkAddrPattern("/end")) {

    if (playing.get(theOscMessage.get(0).intValue())) {
      end.set(theOscMessage.get(0).intValue(), true);
      playing.set(theOscMessage.get(0).intValue(), false);
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

    address = new NetAddress(ip, port);

    OscMessage message = new OscMessage("/movieList");
    message.add(number);

    for (File f : movieList) {
      message.add(f.getName());
    }

    oscP5.send(message, address);
  }
}