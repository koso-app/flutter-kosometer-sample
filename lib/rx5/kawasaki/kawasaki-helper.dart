
var _kSequenceNum = 0;

int getSequenceNumber(){
  _kSequenceNum += 1;
  _kSequenceNum %= 256;
  return _kSequenceNum;
}