import java.awt.*;
import java.util.Arrays;


public class FolderMovies {


  /**
   ファイル選択ダイアログを出し、選択されたファイルのあるフォルダを返す。
   */
  File chooseFolder() {

    FileDialog fd = new FileDialog(new Frame(), "Choose a folder", FileDialog.LOAD);
    fd.setVisible(true);
    if (fd.getFile()==null) {
      println("Canceled");
    } else {
    }

    File folder = new File(fd.getDirectory());

    return folder;
  }

  /**
   DataFolderの中のファイルを一覧で返す
   */
  ArrayList<File> getDataFileList() {

    File file = new File(dataPath(""));

    return new ArrayList<File>(Arrays.asList(file.listFiles()));
  }
  
  
  
  
}