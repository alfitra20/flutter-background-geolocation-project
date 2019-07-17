import 'package:flutter/material.dart';
import 'package:geolocation/geolocation.dart';
import 'package:local_notifications/local_notifications.dart';
import 'dart:async';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Geolocation App',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String locationText = "no data";
  List<LocationResult> locations = [];
  StreamSubscription<LocationResult> streamSubscription;
  bool trackLocation = false;

  static const AndroidNotificationChannel channel = const AndroidNotificationChannel(
      id: 'default_notification',
      name: 'Default',
      description: 'Grant this app the ability to show notifications',
      importance: AndroidNotificationChannelImportance.HIGH
  );

  @override
  void initState() {
    super.initState();
    checkGps();

    trackLocation = false;
    locations = [];
  }

  sendNotification(LocationResult result) async {
    await LocalNotifications.createAndroidNotificationChannel(channel: channel);
    await LocalNotifications.createNotification(
        title: "Influenzanet",
        content: result.toString(),
        id: 0,
        androidSettings: new AndroidSettings(
            channel: channel
        )
    );
  }

  getLocations() {
    if (trackLocation) {
      debugPrint("tracklocation - false");
      setState(() => trackLocation = false);
      streamSubscription.cancel();
      streamSubscription = null;
    } else {
      debugPrint("tracklocation - true");
      setState(() => trackLocation = true);
      streamSubscription = Geolocation.locationUpdates(
        accuracy: LocationAccuracy.best,
        displacementFilter: 0.0,
        inBackground: true,
      )
          .listen((result) {
            if (result.isSuccessful) {
              debugPrint( result.toString());
              sendNotification(result);
              setState(() => locationText = result.toString());
            }
          });

      streamSubscription.onDone(() => setState(() => trackLocation = false));
    }
  }

  endTracking() {
    debugPrint("endTracking - "+ trackLocation.toString());
    setState(() => trackLocation = false);
  }

  checkGps() async {
    final GeolocationResult result = await Geolocation.requestLocationPermission(const LocationPermission(
      android: LocationPermissionAndroid.fine,
      ios: LocationPermissionIOS.always
    ));

    if (result.isSuccessful) {
      print('success');
    } else {
      print('Failed - location is not operational');
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Geolocation App'),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              locationText,
            ),
            new FlatButton(
              onPressed: getLocations,
              child: new Text('Start Geolocation', style: new TextStyle(
                  color: Colors.black,
                  fontSize: 24.0,
                  fontFamily: 'San Francisco'
              ),
              ),
            ),
            new FlatButton(
              color: Colors.blueGrey,
              onPressed: endTracking,
              child: new Text('Stop Geolocation', style: new TextStyle(
                  fontSize: 24.0,
                  color: Colors.blueAccent,
                  fontFamily: 'San Francisco'
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
