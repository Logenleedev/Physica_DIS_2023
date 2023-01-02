import controlP5.*;

ControlP5 cp5;
public static boolean DEBUG = true;
int myColor = color(255);
int c1, c2;
float n, n1;

String sketchPath = "/Users/mac/[path of the processing folder]";
String cmd = "usr/local/bin/processing-java --sketch=" + sketchPath + " --run";

void setup() {
  size(400, 600);
  noStroke();
  cp5 = new ControlP5(this);

  // create a new button with name 'launchGravity'
  cp5.addButton("launchGravity")
    .setLabel("Gravity Simulation")
    .setPosition(100, 100)
    .setSize(200, 19);
    
    
  
}



 
  
void draw() {
  background(0,0,0);
}

public void launchGravity(){
  print("Hi!");
  //launch("processing-java","--sketch=/Users/mac/Desktop/Research/Ken/Physica/Demo/toio_processing_gravity","--run");
  try{
    Runtime.getRuntime().exec(cmd);
  } catch (Exception e){
   print(e); 
  }
}
