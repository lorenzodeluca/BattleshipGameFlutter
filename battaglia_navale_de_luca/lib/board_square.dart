
class BoardSquare {

  bool ship;
  bool hitted;
  int shipNumber;
  int shipLenght;
  int progressiveNumber;//number of the same ship from up-down right-left
  bool shipOrientationHorizontal;
  BoardSquare({this.ship = false, this.shipNumber = 0, this.hitted=false});
  bool get isShip{
    return ship;
  }
  set isShip(bool value){
    ship=value;
  }
}
