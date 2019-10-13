/**
@author Ishan Vermani
@version May 1 2019

Class file to be used with ComputerVision.PDE

Shape class to create new shapes, which 
group pixels and then draws the boxes 
around these condensed pixel groups

To be used in Processing
**/


import java.awt.Point;


public class Shape{
public Point initPoint;
public int shapeWidth;
public int shapeHeight;
public int minX;
public int maxX;
public int minY;
public int maxY;
//Holds all points
public ArrayList<Point> points = new ArrayList<Point>();

  public Shape(int x, int y){
    //Initial point. Set starting values to initial point
    initPoint = new Point(x, y);
    minX = x;
    maxX = x;
    minY = y;
    maxY = y;
    points.add(initPoint);
    
  }
  //Adding a point, adjusting min max values
  public void addPoint(int x, int y){
    points.add(new Point(x,y));
    minX = min(x, minX);
    minY = min(y, minY);
    maxX = max(x, maxX);
    maxY = max(y, maxY);
   
  }
  //Adding another point, but with a different argument as an input
  public void addPoint(Point p){
    points.add(p);
    int x = (int)p.getX();
    int y = (int)p.getY();
    minX = min(x, minX);
    minY = min(y, minY);
    maxX = max(x, maxX);
    maxY = max(y, maxY);
    
  }
  //Checking to see if a shape includes the specified point
  public boolean pointIncluded(int x, int y){
    Point testPoint = new Point(x,y);
    boolean ans = points.contains(testPoint) ? true : false;
    return ans;
  }
  
  //Returns the bounding box, the outer dimensions, of the shape
  public Rectangle getBoundingBox(){
    shapeWidth = maxX - minX;
    shapeHeight = maxY - minY;
    Rectangle boundingBox = new Rectangle(minX, minY, shapeWidth, shapeHeight);
    return boundingBox;
  }
  //Extended bounding box, used to search if internal bounding boxes of 
  //other shapes exist
  public Rectangle getExtendedBoundingBox(){
    shapeWidth = maxX - minX;
    shapeHeight = maxY - minY;
    Rectangle boundingBox = new Rectangle(minX - 5, minY - 5, shapeWidth + 10, shapeHeight + 10);
    return boundingBox;
  }
  
  public void clearPoints(){ 
    points.clear();
    maxX = 0; minX = 0; maxY = 0; minY = 0;
  }
  
  public int getArea(){
    shapeWidth = maxX - minX;
    shapeHeight = maxY - minY;
    return shapeWidth*shapeHeight;
  }
    
}
