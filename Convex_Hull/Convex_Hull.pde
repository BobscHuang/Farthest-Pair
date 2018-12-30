//NOTE: in this program I used PVector as points and vectors interchangeably
//Creates initial variables
int pointNum = 1000;
PVector startPoint;
ArrayList<PointVA> inputHull;
float [] angle;

ArrayList<PVector> outputHull = new ArrayList<PVector>();
PVector[] farV = new PVector [2];

long startTime, elapsedTime;

//Setup procedure
void setup(){
  noLoop();
  size(1000, 1000);
  background(0);
  ellipseMode(RADIUS);

  //To get visuals, use the small section of code below
  //To change number of random points, adjust variable pointNum
  //If you only want the pair of points farthest away from each other
  //Use the getFarthestPoints function (it dosen't have visuals though)
  inputHull = randomPointVA(pointNum);
  startTime = millis();
  outputHull = convexHull(inputHull);
  farV = bruteForce(outputHull);
  elapsedTime = millis() - startTime;
  println("Overall Computation Time: " + elapsedTime + "ms");
  println("The two furthest points are:");
  printArray(farV);
  
  //startTime = millis();
  //getFarthestPoints(randomPoints(1000000));
  //elapsedTime = millis() - startTime;
  //println("Overall Computation Time: " + elapsedTime + "ms");

}

//Draws all points as circles 
//Lines that connects the convex hull
//Line that connects the two points farthest away
void draw(){
  background(0);
  fill(255, 0, 0);
  for (int i = 0; i < inputHull.size(); i++){
    fill(255, 0, 0);
    ellipse(inputHull.get(i).getVector().x, inputHull.get(i).getVector().y, 5, 5);
  }
  stroke(0, 255, 0);
  line(farV[0].x, farV[0].y, farV[1].x, farV[1].y);
  
  stroke(255);
  for (int i = 0; i < outputHull.size(); i++){
    
    if (i != 0){
      line(outputHull.get(i - 1).x, outputHull.get(i - 1).y, outputHull.get(i).x, outputHull.get(i).y);
    }
    if (i == outputHull.size() - 1){
      line(outputHull.get(i).x, outputHull.get(i).y, outputHull.get(0).x, outputHull.get(0).y);
    }
  }
  
  fill(0, 0, 255);
  ellipse(startPoint.x, startPoint.y, 5, 5);
}

//Takes an array of PVector points
//Outputs the farthest pairs
//Essentially, combining all other functions together
void getFarthestPoints(PVector [] input){
  PVector[] farthestPair = new PVector [2];
  ArrayList<PVector> output = new ArrayList<PVector>();
  ArrayList<PointVA> Pva = new ArrayList<PointVA>();
  
  for (int i = 0; i < input.length; i++){
    Pva.add(new PointVA(input[i]));
  }
  output = convexHull(Pva);
  farthestPair = bruteForce(output);
  printArray(farthestPair);
}

//Main function that calculates points that are on the convex hull
//Given an ArrayList with objects PointVA
//Based off of Graham Scan algorithm with modifications (not output sensitive)
ArrayList<PVector> convexHull(ArrayList<PointVA> input){
  ArrayList<PVector> stack = new ArrayList<PVector>();
  long Time, Time2;
  
  //Finds the start points and "polar angles"
  Time = millis();
  startPoint = startValue(input);
  for (int i = 0; i < input.size(); i++){
    input.get(i).polarAngle = polarAngle(input.get(i).getVector(), startPoint);
  }
  Time2 = millis() - Time;
  println("Polar Angle Computation Time: " + Time2 + "ms");
  
  //Sorts all the points
  Time = millis();
  input = mergeSort(input, 0, input.size() - 1);
  Time2 = millis() - Time;
  println("Merge Sort Computation Time: " + Time2 + "ms");
  
  //Creates a stack (ArrayList)
  push(stack, startPoint);
  push(stack, input.get(0).getVector());
  push(stack, input.get(1).getVector());
  
  //Using orientation, either keep or discard points
  //Points that are kept are on the convex hull
  //Points that are discarded are not on the convex hull
  Time = millis();
  for (int i = 2; i < input.size(); i++){
    PVector pointI = input.get(i).getVector();
    
    while (orientation(stack.get(stack.size() - 2), stack.get(stack.size() - 1), pointI).equals("counterclockwise") == false){
      pop(stack);
    }
    push(stack, pointI);
  }
  Time2 = millis() - Time;
  println("Convex Hull Computation Time: " + Time2 + "ms");
  return stack;
}

//Calculates the distance between two points
float getDist(PVector a, PVector b){
  float dist = sqrt(pow((b.x - a.x), 2) + pow((a.y - b.y), 2));
  return dist;
}

//pop function for ArrayList
void pop(ArrayList<PVector> a){
  a.remove(a.size() - 1);
}

//push function for ArrayList
void push(ArrayList<PVector> a, PVector p){
  a.add(p);
}

//Finds the largest y-value and smallest x-value
//Basically the point in the most bottom left corner
PVector startValue(ArrayList<PointVA> a){
  int maxIndex = 0;
  for (int i = 1; i < a.size(); i++){
    if (a.get(i).getVector().y > a.get(maxIndex).getVector().y){
      maxIndex = i;
    }
    else if (a.get(i).getVector().y == a.get(maxIndex).getVector().y){
      if (a.get(i).getVector().x < a.get(maxIndex).getVector().x){
        maxIndex = i;
      }
    }
  }
  PVector max = a.get(maxIndex).getVector();
  a.remove(maxIndex);
  return max;
}

//Determins the orientation of three vectors
//Either clockwise, counterclockwise, or collinear
String orientation(PVector p1, PVector p2, PVector p3){
  float difference = (p2.y - p1.y) * (p3.x - p2.x) - (p3.y - p2.y) * (p2.x - p1.x);
  
  if (difference > 0){
    return "counterclockwise";
  }
  else if (difference < 0){
    return "clockwise";
  }
  else{
    return "collinear";
  }
}

//NOTE:
//The greater a.b / |a||b|, the smaller the angle
//The smaller a.b / |a||b|, the greater the angle
//For cosx in interval [0, pi]
//By doing this, it saves computation time

//Dosen't actually calculate the polar angle
//Simply evaluates inverse that would produce the angle (arc-cos)
//Uses dot product of two vectors
double polarAngle(PVector p1, PVector p2){
  PVector directionalV = new PVector(1, 0);
  PVector temp = pointsToVector(p1, p2);
  double PA = temp.dot(directionalV) / (temp.mag() * directionalV.mag());
  return PA;
}

//Takes two points and calculates the vector that connects them
PVector pointsToVector(PVector p1, PVector p2){
  PVector v = new PVector(p1.x - p2.x, p1.y - p2.y);
  return v;
}

//Creates an ArrayList with objects PointVA that has random points
ArrayList<PointVA> randomPointVA(int n){
  ArrayList<PointVA> random = new ArrayList<PointVA>();
  for (int i = 0; i < n; i++){
    PVector v = new PVector(int(random(10, 991)), int(random(10, 991)));
    random.add(new PointVA(v));
  }
  return random;
}

//Creates an array with random PVector points
PVector [] randomPoints(int n){
  PVector [] random = new PVector[n];
  for (int i = 0; i < n; i++){
    random[i] = new PVector(int(random(0, 1001)), int(random(0, 1001)));
  }
  return random;
}

//Modified mergesort that works with an ArrayList with object PointVA
//Sorts the PointVA objects by their "polar angles" in ascending order
ArrayList<PointVA> mergeSort(ArrayList<PointVA> a, int start, int end ) {

  if ( start == end ) {  
    ArrayList<PointVA> arrayWithOneElement = new ArrayList<PointVA>();
    arrayWithOneElement.add(a.get(start));
    return arrayWithOneElement;
  } 
  
  else {
    int middle = (end + start) / 2;

    ArrayList<PointVA> sortedLeftHalf = mergeSort( a, start, middle );         // recursive call
    ArrayList<PointVA> sortedRightHalf = mergeSort( a, middle + 1, end );      // recursive call

    return merge( sortedLeftHalf, sortedRightHalf );  // merge the two sorted halves
  }
}

//Combines two sorted arrays into a single sorted array
//Based off of the "polar angle" of object PointVA
//Also removes points that have same "polar angle" (keep point farther away)
ArrayList<PointVA> merge( ArrayList<PointVA> a, ArrayList<PointVA> b ) {
  ArrayList<PointVA> c = new ArrayList<PointVA>();
  int i = 0;
  int j = 0;

  while ( i < a.size() && j < b.size() ) {

    if ( a.get(i).getPA() > b.get(j).getPA() ) {
      c.add(a.get(i));
      i++;
    }
    else if (a.get(i).getPA() < b.get(j).getPA()){
      c.add(b.get(j));
      j++;
    }
    else{
      if (getDist(startPoint, a.get(i).getVector()) > getDist(startPoint, b.get(j).getVector())){
        c.add(a.get(i));
      }
      else{
        c.add(b.get(j));
      }
      i++;
      j++;
    }

  }
  if ( i == a.size() ) 
    for ( int m = j; m < b.size(); m++ ) {
      c.add(b.get(m));
    } 
  else 
    for (int m = i; m < a.size(); m++) {
      c.add(a.get(m));
    }
  return c;
}

//Finds the farthest two points and its distance
//Given a list of points that makes up a convex hull
PVector [] bruteForce(ArrayList<PVector> hull){
  PVector [] FarthestPair = new PVector[2];
  int size = hull.size();
  float maxDist = 0;
  int [] furthestPairIndex = {0, 0};
  
  for (int i = 0; i < size - 1; i++){
    for (int j = i; j < size; j++){
      float dist = getDist(hull.get(i), hull.get(j));
      if (dist > maxDist){
        maxDist = dist;
        furthestPairIndex[0] = i;
        furthestPairIndex[1] = j;
      }
    }
  }
  FarthestPair[0] = hull.get(furthestPairIndex[0]);
  FarthestPair[1] = hull.get(furthestPairIndex[1]);
  return FarthestPair;
}
