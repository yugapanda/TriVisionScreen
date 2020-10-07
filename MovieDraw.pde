class MovieDraw extends ImageDrawBase {

  public Movie _movie;

  MovieDraw(PApplet applet, Movie movie, boolean fadeIn, boolean fadeOut) {

    super(applet, fadeIn, fadeOut);
    _movie = movie;
    _movie.play();
    _movie.stop();
    //_movie.play();
  }

  void drawImage() {



    if (!_init) {
      _movie.play();
      _init = true;
    }

    _pg.beginDraw();
    _pg.background(0);
    _pg.image(_movie, 0, 0, width, height);
    _pg.endDraw();
  }

  //呼ばれると、FadeOutが設定されていたら０になるまでAlphaを下げてからtrueを返す。
  //されていなければ即０にしてtrueを返す
  boolean end() {


    if (_fadeOut) {
      _fadeAlpha = constrain(_fadeAlpha - _fadeOutSpeed, 0, 255);
    } else {
      _fadeAlpha = 0;
    }

    if (_fadeAlpha <= 0) {
      _movie.stop();
      _movie.jump(0);
      _init = false;
      return true;
    }

    return false;
  }
}