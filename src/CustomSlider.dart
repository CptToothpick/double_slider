import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class CustomSlider extends StatefulWidget {
  const CustomSlider({required this.onChangeEnd, Key? key}) : super(key: key);

  final double width = 320;
  final double height = 70;

  //Function that will be called with changed values
  final Function(List<double> values) onChangeEnd;

  @override
  _CustomSliderState createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {

  double width = 0;
  int curIndex = -1;
  List<double> values = [0,80,160,240];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      padding: EdgeInsets.all(10),
      child:GestureDetector(
        child: LayoutBuilder(
          builder: (context, constraints){
            width = constraints.maxWidth;
            return Container(
              height: constraints.minHeight+5,
              width: constraints.maxWidth,
              color: Colors.transparent,
              child: CustomPaint(
                painter: SliderPainter(values: values),
              ),
            );
          },
        ),
        dragStartBehavior: DragStartBehavior.down,
        onHorizontalDragStart: _onHoDragSt,
        onHorizontalDragUpdate: _onHoDrag,
        onHorizontalDragEnd: _onHoDragEnd,
        onTapUp: _onTapUp,
      ),
    );
  }

  void _onHoDragSt(DragStartDetails update){
    curIndex = _selectClosest(update.localPosition.dx);
    _movePoint(update.localPosition.dx);
    print(curIndex);
  }

  void _onHoDrag(DragUpdateDetails update){
    _movePoint(update.localPosition.dx);
  }

  void _onHoDragEnd(DragEndDetails update){
    curIndex = -1;
    widget.onChangeEnd([values[0]/width,values[1]/width,values[2]/width,values[3]/width]);
  }

  void _onTapUp(TapUpDetails update){
    _moveClosest(update.localPosition.dx);
  }


  void _movePoint(double newPos){
    //kontrola spodni hranice
    if(newPos < (curIndex==0?0:values[curIndex-1])){
      setState(() {
        values[curIndex] = curIndex==0?0:values[curIndex-1];
      });
    }
    //kontrola horni hranice
    else if(newPos > (curIndex ==3?width:values[curIndex+1])){
      setState(() {
        values[curIndex] = curIndex ==3?width:values[curIndex+1];
      });
    }
    else{
      setState(() {
        values[curIndex] = newPos;
      });
    }

  }


  void _moveClosest(double newPos){
    int index = _selectClosest(newPos);

    setState(() {
      values[index] = newPos;
    });

    print(values);


  }

  int _selectClosest(double newPos){

    List<double> deltas = [ (values[0]-newPos).abs(),(values[1]-newPos).abs(),(values[2]-newPos).abs(),(values[3]-newPos).abs()];
    List<double> temp = deltas;

    double tempVal = temp.reduce(min);

    return deltas.indexOf(tempVal);
  }

}


class SliderPainter extends CustomPainter{

  Offset startP = Offset(0,0);
  Offset endP = Offset(0,0);

  late Color aColor;
  late Color iColor;
  List<double> values;



  SliderPainter({Color? activeColor, Color? inactiveColor,required this.values}){
    aColor = activeColor == null? Colors.blue[800]! : activeColor;
    iColor = inactiveColor == null? Colors.white70 : inactiveColor;
  }

  @override
  void paint(Canvas canvas, Size size){
    startP = Offset(0,size.height/2);
    endP = Offset(size.width,size.height/2);

    _paintBase(canvas, size);
    _paintPoints(canvas, size);
    _paintConLines(canvas, size);
  }



  _paintBase(Canvas canvas, Size size){

    Paint inactivePnt = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 5
    ..color = iColor;

    canvas.drawLine(startP,endP,inactivePnt);
  }

  _paintPoints(Canvas canvas, Size size){

    Paint activePnt = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 10
      ..color = aColor;

    canvas.drawCircle(Offset(values[0],endP.dy), 7, activePnt);
    canvas.drawCircle(Offset(values[1],endP.dy), 7, activePnt);
    canvas.drawCircle(Offset(values[2],endP.dy), 7, activePnt);
    canvas.drawCircle(Offset(values[3],endP.dy), 7, activePnt);
  }

  _paintConLines(Canvas canvas,Size size){

    Paint activePnt = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 7
      ..color = aColor;

    canvas.drawLine(Offset(values[0],endP.dy), Offset(values[1],endP.dy), activePnt);
    canvas.drawLine(Offset(values[2],endP.dy), Offset(values[3],endP.dy), activePnt);

  }

  @override
  bool shouldRepaint(SliderPainter old){
    return true;
  }

}