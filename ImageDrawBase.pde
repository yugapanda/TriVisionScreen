abstract class ImageDrawBase {

  protected boolean _fadeIn;
  protected boolean _fadeOut;
  protected float _fadeAlpha = 0;
  protected float _fadeInSpeed = 5;
  protected float _fadeOutSpeed = 5;
  protected boolean _init;
  protected PGraphics _pg;


  ImageDrawBase(PApplet applet, boolean fadeIn, boolean fadeOut) {

    _fadeIn = fadeIn;
    _fadeOut = fadeOut;
    _pg = applet.createGraphics(applet.width,applet.height,P2D);

    //フェードインが設定されていたら透明
    if (_fadeIn) {
      _fadeAlpha = 0;
    } else {
      //そうでなければくっきり
      _fadeAlpha = 255;
    }
  }


  abstract void drawImage();

  //fadeAlphaが0より大きければ、0になるまでfadeAlphaを減算
  void doFadeIn() {

    if (_fadeAlpha <= 255) {
      _fadeAlpha = constrain(_fadeAlpha +_fadeInSpeed, 0, 255);
    }

  }





  //フェードインスピードを設定する
  protected void setFeedInSpeed(int fadeSpeed) {    
    _fadeInSpeed = fadeSpeed;
  }

  //フェードアウトスピードを設定する
  protected void setFeedOutSpeed(int fadeSpeed) {    
    _fadeInSpeed = fadeSpeed;
  }


  void side(){
    
    _pg.beginDraw();
    _pg.noStroke();
    _pg.fill(0);
    _pg.rect(0,0,_pg.width*(1/16),height);
    _pg.rect(width - width*(1/16),0,_pg.width,height);
    _pg.endDraw();
    
  }


  //呼ばれると、FadeOutが設定されていたら0になるまでAlphaを下げてからtrueを返す。
  //されていなければ即０にしてtrueを返す
  protected boolean end() {


    if (_fadeOut) {
      _fadeAlpha = constrain(_fadeAlpha - _fadeOutSpeed, 0, 255);
    } else {
      _fadeAlpha = 0;
    }

    if (_fadeAlpha <= 0) {
      return true;
    }

    return false;
  }
}