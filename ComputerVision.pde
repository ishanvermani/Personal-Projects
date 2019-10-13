/**
* @author Ishan Vermani

* @version May 1 2019

This program is designed to be fed an input color, and then extract
all instances of that color from the image. It then analyzes the extracted
pixels and groups them into shapes according to their positioning and location.

**/





import processing.video.*;
import java.awt.Rectangle;
import java.awt.Point;
import java.awt.Color;
import java.awt.Image;

Capture cam;

//Unversal vairables
int camWidth = 1080;
int camHeight = 606;
//Pixel editing mode enable/disable
boolean pixelEditing = false;
int thresholding = 0;
//Help mode enable/disable
boolean helpToggle = false;
//Minimum area of a shape
int areaThreshold = 1000;
//Radius of shape
int shapeThreshold = 5;

//Rectangles in the GUI
public Rectangle toggleEdit = new Rectangle(270, 612, 60, 30);
public Rectangle currentColorRect = new Rectangle (540, 610, 35, 35);
public Rectangle lockedColorRect = new Rectangle (500, 610,35, 35);
public Rectangle thresholdingRectangle = new Rectangle(840, 610, 200, 35);
public Rectangle help = new Rectangle(70, 613, 25, 25);

//Colors
public Color liveColor = new Color(255, 255, 255);
public Color lockedColor = new Color(255, 255, 255);

//Storing shapes and points, as well as a registry of shapes corresponding to points
public ArrayList<Shape> shapes = new ArrayList<Shape>();
public ArrayList<Point> matchingPixels = new ArrayList<Point>();
public HashMap<Point, Shape> insertedPixels = new HashMap<Point, Shape>();

void setup() {
  size(1080, 650);
  frameRate(30);
  colorMode(RGB, 255);
  String[] cameras = Capture.list();
  
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
    println(cameras.length);
    
   //If my webcam shows up, it comes into slot 15
   //If not, go with built in cam slot 0
    try{
    cam = new Capture(this, cameras[15]);
    }
    catch (ArrayIndexOutOfBoundsException e) {
    cam = new Capture(this, cameras[0]);
    }
    cam.start();     
  }      
  
   
}

void draw() {
  
  /**
  
  GUI- INLCUDUING THRESHOLDING BOX, COLOR BOXES, HELP, TOGGLES SWITCH, AND ALL ASSOCIATED FUNCTIONS
  
  **/
  
  background(200);
  noStroke();
  strokeWeight(1);
  textSize(15);
  //If in help mode
  if(helpToggle){
    //Help Messages
    fill(0);
    textSize(40);
    text("Help", 100, 60);
    textSize(15);
    text("Click the 'Pixel Select' switch to toggle pixel selection mode", 100, 100);
    text("The 'Locked Color' box shows the pixel color that you are currently tracking", 100, 150);
    text("When Pixel Selecting is on, hover over the image and see the color of the pixel at the location of the mouse in the 'current color' box", 100, 200);
    text("When Pixel Selecting is on, click any pixel in the frame to lock it. The lock color box will update", 100, 250);
    text("Click on the 'Thresholding' box to set the thresholding value. This controls the range of color accepted to track", 100, 300);
    text("The left and right arrow keys can also be used to change the thresholding value", 100, 350);
    text("Click the 'Help' box to exit this menu", 100, 400);
    
  } else {
    if (cam.available() == true) {
      cam.read();
      
    }
    //Drawing the image
    image(cam, (width - camWidth)/2, 0, camWidth, camHeight);
  
    loadPixels();
  }
  //If not searching for pixels
  if (!pixelEditing){
     //Draws the switch, in off position
    fill(255);
    rect((int)toggleEdit.getX(), (int)toggleEdit.getY(), (int)toggleEdit.getWidth(), (int)toggleEdit.getHeight(), 20);
    fill(220);
    circle((int)toggleEdit.getX() + (int)toggleEdit.getWidth()/4 + 3, (int)toggleEdit.getY() + (int)toggleEdit.getHeight()/2, (int)toggleEdit.getHeight() -5);
    fill(0);
    text("Pixel Select Off", 150, height - 19);
  }
  else if (pixelEditing){
    //Draws the switch in the on position
    fill(255);
    rect((int)toggleEdit.getX(), (int)toggleEdit.getY(), (int)toggleEdit.getWidth(), (int)toggleEdit.getHeight(), 20);
    fill(0, 255, 0);
    circle((int)(toggleEdit.getX() + toggleEdit.getWidth() - toggleEdit.getWidth()/4 - 3), (int)(toggleEdit.getY() + toggleEdit.getHeight()/2), (int)toggleEdit.getHeight() -5);
    fill(0);
    text("Pixel Select On", 150, height - 19);  
}
    

if (pixelEditing == true && mouseY < camHeight){
  //If in pixels editing mode, read the live color off the cursor
  cursor(CROSS);
  double redPixels = 0;
  double greenPixels = 0;
  double bluePixels = 0;
  int num = 0;
  //Average color of 3x3 grid with mouse in the centre
   for(int x = -1; x<2;x++){
     for(int y = -1; y<2; y++){
       
    int location = (mouseX+x) + width*(mouseY+y);
    int r = (int)red(pixels[location]);
    int b = (int)blue(pixels[location]);
    int g = (int)green(pixels[location]);
    
    redPixels += Math.pow(r, 2);
    greenPixels += Math.pow(g, 2);
    bluePixels += Math.pow(b, 2);
   num++;
     }
   }
    int red = (int)Math.sqrt((redPixels)/num);
    int green = (int)Math.sqrt((greenPixels)/num);
    int blue = (int)Math.sqrt((bluePixels)/num);
    liveColor = new Color(red, green, blue);
    stroke(1);
    //The boxes of live and locked colors
    fill(lockedColor.getRGB());
    rect((int)lockedColorRect.getX(), (int)lockedColorRect.getY(), (int)lockedColorRect.getWidth(), (int)lockedColorRect.getHeight());
    fill(liveColor.getRGB());
    rect((int)currentColorRect.getX(), (int)currentColorRect.getY(), (int)currentColorRect.getWidth(), (int)currentColorRect.getHeight());
    noStroke();
    fill(0);
    text("Locked Color >", 380, 633);
    text("< Current Pixel", 590, 633);
}
else {
  //Not pixel editing, so just the locked color
  cursor(ARROW);
  stroke(1);
  fill(lockedColor.getRGB());
  rect((int)lockedColorRect.getX(), (int)lockedColorRect.getY(), (int)lockedColorRect.getWidth(), (int)lockedColorRect.getHeight());
  noStroke();
  fill(0);
  text("Locked Color > ", 380, 633);
}

   stroke(1);
   fill(0);
   //Thresholding box with live thresholding value
   text("Thresholding Value", (int)thresholdingRectangle.getX() - 100, 633);
   String thresholdingValue = "" + thresholding;
   text(thresholdingValue, (int)thresholdingRectangle.getX() + 205, 633);
   fill(255);
   rect((int)thresholdingRectangle.getX(), (int)thresholdingRectangle.getY(), (int)thresholdingRectangle.getWidth(), (int)thresholdingRectangle.getHeight(), 2);
   rect((int)thresholdingRectangle.getX()+thresholding, 610, 1, 35);
   fill(0,0,255);
   rect((int)thresholdingRectangle.getX(), (int)thresholdingRectangle.getY(), thresholding, (int)thresholdingRectangle.getHeight());
   
   if(helpToggle){
     //Drawing Help box when enabled
     stroke(4);
     fill(0, 0, 255);
     rect((int)help.getX(), (int)help.getY(), (int)help.getWidth(), (int)help.getHeight());
     fill(255);
     text("?", (int)help.getX() + 10, (int)help.getY() + 19);
     noStroke();   
   } else {
     //Non enabled help box
   noStroke();
   fill(255);
   rect((int)help.getX(), (int)help.getY(), (int)help.getWidth(), (int)help.getHeight());
   fill(0, 0, 255);
   text("?", (int)help.getX() + 10, (int)help.getY() + 19);
   }
  
  /**
  
  
  END OF GUI AND ASSOCIATED FUNCTIONS
  
  START OF VISION ALGORITHM
  
  **/
  
 if (!helpToggle){
   int pixelCounter = 0;
   
  //Iterating through each pixel
  for (int x=0; x<camWidth; x++){
    for (int y=0; y<camHeight;y++){
      int location = x + y*camWidth;
      //Reading pixel color
      int r = (int)red(pixels[location]);
      int b = (int)blue(pixels[location]);
      int g = (int)green(pixels[location]);
      color white = color(255);

      //Get euclidian 3d Distance from the current color to the locked color
      float distance = dist(r, g, b, lockedColor.getRed(), lockedColor.getGreen(), lockedColor.getBlue());
     //If the distance is withing the threshold
      if (distance < thresholding){
        //Set the pixel to white, add it to the patching pixels arraylist
        pixelCounter++;
        set(x, y, white);
        matchingPixels.add(new Point(x,y));
      
      }
     
    }
  }//End of pixel iteration
 
     
    Point closestPoint = null;
    float closestPointDistance = 500000;
    boolean inserted = false;
    for (Point p : matchingPixels){
      //For each point
      //Is inserted into a shape
      inserted = false;
      //Point in a shape it is closest to
      closestPoint = null;
      //distance to closest point
      closestPointDistance = 5000000;
      int x = (int)p.getX();
      int y = (int)p.getY();
      if (x!=0 && y!=0){
        //For each pixel in the shape radius
      for(int xx=-shapeThreshold; xx<(shapeThreshold+1); xx++){
        for(int yy=-shapeThreshold; yy<(shapeThreshold+1); yy++){
          
          Point currentPoint = new Point(x+xx,y+yy);
          //See if the radius pixel in the radius has been implanted into the shape directory
          if (insertedPixels.containsKey(currentPoint)){
            //If so, find the distane to the pixel
             float distance = dist(x + xx, y + yy, x, y); 
             //If it's closer than the current closest radius pixel, set it as the closet radius pixel 
             if (distance <= closestPointDistance){
               closestPointDistance = distance;
               closestPoint = currentPoint;
             }
             inserted = true;
          }
          } 
        }
      
      if (inserted){
        //Get the shape of the closest radius point
        //Add that point to the shape
        //Add the point and shape to the directory
        Shape current = insertedPixels.get(closestPoint);
        current.addPoint(p);
        insertedPixels.put(p, current);
      }
      else if(!inserted){
        //If no pixel in the radius exists, create a new shape. Add to directory
        Shape newShape = new Shape(x,y);
        insertedPixels.put(p, newShape);
        shapes.add(newShape);
      }
    }
  }
    
    
  //Storing shapes that I will be removing later 
  ArrayList<Shape> shapesToRemove = new ArrayList<Shape>();
  
  //Loop to get rid of tiny shapes that were within larger ones
  //An issue I had earlier on
    for (Shape a : shapes){
      for (Shape b: shapes){
        if(a!=b){
          
          //For each shape, iterate through each other shape
          //If the initial shape fully contains the second shape
          //Add each point of the second shape into the first one
          //And clear the second one
          //Mildly reduces iteration time and makes it easier to debug
          if(a.getExtendedBoundingBox().contains(b.getBoundingBox())){
            for (Point p : b.points){
              a.addPoint(p);
            }
            shapesToRemove.add(b);
          }
        }
      }  
    }
    
    //Remove all cleared shapes
    for (Shape s : shapesToRemove){
      shapes.remove(s);
    }
    
    println(pixelCounter);
    println("ShapeSize" + shapes.size());
     
     //Draw the box around each shape, provided they exceed the threshold
    for (Shape s : shapes){
      if (s.getArea() > areaThreshold){
        noFill();
        stroke(8, 232, 222);
        strokeWeight(3);
        rect(
        (int)s.getBoundingBox().getX(),
        (int)s.getBoundingBox().getY(),
        (int)s.getBoundingBox().getWidth(),
        (int)s.getBoundingBox().getHeight());
      }
    }
   
   //Clear the three stotage parameters, so that they can be rebuilt
   //in the next iteration
   shapes.clear();
   matchingPixels.clear();
   insertedPixels.clear();
 }

}

void mouseClicked(MouseEvent e){
  int x = e.getX();
  int y = e.getY();
  
  Point click = new Point(x,y);
  //If clicking the switch to toggle pixel editing mode
  if(toggleEdit.contains(click)){
    //Love these little one line if statements
    pixelEditing = (pixelEditing == true) ? false : true;
  }
  //Click in the thresholding rectangle
  else if(thresholdingRectangle.contains(click)){
    thresholding = x - (int)thresholdingRectangle.getX();
  }
  //Click on the help button
  else if(help.contains(click)){
    helpToggle = helpToggle == true ? false : true;
  }
  //Click in the video feed and in pixel editing mode
  //Get color of click rotation
  if(pixelEditing == true && mouseY < camHeight){
    int location = mouseX + width*mouseY;
    int r = (int)red(pixels[location]);
    int b = (int)blue(pixels[location]);
    int g = (int)green(pixels[location]);
    
    
    lockedColor = new Color(r, g, b);
  }

}
  
//Control of thresholding with left and right arrow keys
void keyPressed(){
   if(keyCode == 37){
     thresholding = thresholding > 0 ? thresholding - 1: thresholding;
   }
   if(keyCode == 39){
     thresholding = thresholding < 200 ? thresholding + 1: thresholding;
   }
   
 }
