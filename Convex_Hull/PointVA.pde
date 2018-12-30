//PointVA class
class PointVA{
  double polarAngle;
  PVector vector;
  
  //Constructor 1
  PointVA(double polarAngle_, PVector vector_){
    this.polarAngle = polarAngle_;
    this.vector = vector_;
  }
  
  //Constructor 2
  PointVA(PVector vector_){
    this.vector = vector_;
  }
  
  //Returns polar angle
  double getPA(){
    return this.polarAngle;
  }
  
  //Returns vector
  PVector getVector(){
    return this.vector;
  }
}