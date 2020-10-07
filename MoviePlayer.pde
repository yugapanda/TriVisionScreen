class MoviePlayer {

  public Movie _movie;


  public MoviePlayer(Movie movie) {
    _movie = movie;
    _movie.play();
    _movie.pause();
  }

  public void start() {
    
    _movie.play();
  }
  
  public void init(){
    _movie.play();
    //_movie.jump(0);
    _movie.pause();
  }
  
  public void end(){
   _movie.stop(); 
  }

  public void draw() {

    image(_movie, 0, 0, width, height);
  }
}