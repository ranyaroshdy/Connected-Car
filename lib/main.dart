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
  Position _initialPosition;
  Position _finalPosition;
  double distanceOne;
  double distanceTwo;
  StreamSubscription<Position> _streamSubscription;
  @override
  void initState() {
    super.initState();
    var geolocator = Geolocator();
    var locationOptions =
        LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
    _streamSubscription = geolocator
        .getPositionStream(locationOptions)
        .listen((Position position) {
      setState(() {
        _position = position;
        if ((position.speed * 3.6).truncate() == 10) {
          _initialPosition = position;
          distanceTwo = calculateDistance(_finalPosition, _initialPosition);
          if (distanceTwo != null) {
            _initialPosition = _finalPosition = null;
          }
        } else if ((position.speed * 3.6).truncate() == 30) {
          _finalPosition = position;
          distanceOne = calculateDistance(_initialPosition, _finalPosition);
          if (distanceOne != null) {
            _initialPosition = _finalPosition = null;
          }
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
            Text(
                '${(distanceOne == null) ? 0 : calculateTime(distanceOne, 10, 30)}',
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
            Text(
                '${(distanceTwo == null) ? 0 : calculateTime(distanceTwo, 30, 10)}',
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
