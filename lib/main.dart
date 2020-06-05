import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Connected Carr'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

calculateDistance(initialpos, finalpos) async {
  if (initialpos == null && finalpos == null) {
    return null;
  }
  var distance = await Geolocator().distanceBetween(initialpos.latitude,
      initialpos.longitude, finalpos.latitude, finalpos.longitude);
  return distance;
}

calculateTime(distance, from, to) {
  return (((2 * (distance / 1000) * (to - from)) / (to * to - from * from)) *
          60 *
          60)
      .round();
}

class _MyHomePageState extends State<MyHomePage> {
  Position _position;
  //Position _initialPosition;
  //Position _finalPosition;
  bool startSWatch = false;
  bool startSWatchFinal = false;
  int timeOne;
  int timeTwo;
  StreamSubscription<Position> _streamSubscription;
  @override
  void initState() {
    super.initState();
    var stopWatch = Stopwatch();
    var geolocator = Geolocator();
    var locationOptions =
        LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
    _streamSubscription = geolocator
        .getPositionStream(locationOptions)
        .listen((Position position) {
      setState(() {
        _position = position;
        print((position.speed * 3.6).truncate());
        if ((position.speed * 3.6).truncate() >= 10 &&
            (position.speed * 3.6).truncate() < 30 &&
            startSWatch == false &&
            startSWatchFinal == false) {
          stopWatch.start();
          startSWatch = true;
        } else if ((position.speed * 3.6).truncate() >= 30 &&
            startSWatch == true) {
          stopWatch.stop();
          timeOne = stopWatch.elapsed.inSeconds;
          print(timeOne);
          stopWatch.reset();
          startSWatch = false;
          stopWatch.start();
          startSWatchFinal = true;
        } else if ((position.speed * 3.6).truncate() <= 10 &&
            stopWatch.isRunning == true &&
            startSWatchFinal == true) {
          stopWatch.stop();
          timeTwo = stopWatch.elapsed.inSeconds;
          print(timeTwo);
          stopWatch.reset();
          stopWatch = Stopwatch();
          startSWatchFinal = false;
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(height: 60.0),
            Text('Current Speed',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            SizedBox(height: 20.0),
            Text(
                '${(_position == null) ? 0.00 : (_position.speed * 3.6).toStringAsFixed(2)}',
                style: TextStyle(
                    color: Colors.green, fontFamily: 'digital', fontSize: 70)),
            SizedBox(height: 15.0),
            Text('Kmh',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 60.0),
            Text(
              'From 10 to 30',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            Text('${(timeOne == null) ? 0 : timeOne}',
                style: TextStyle(
                    color: Colors.green, fontFamily: 'digital', fontSize: 70)),
            SizedBox(height: 15.0),
            Text('Seconds',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 40.0),
            Text('From 30 to 10',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                )),
            SizedBox(height: 10.0),
            Text('${(timeTwo == null) ? 0 : timeTwo}',
                style: TextStyle(
                    color: Colors.green, fontFamily: 'digital', fontSize: 70)),
            SizedBox(height: 15.0),
            Text('Seconds',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
