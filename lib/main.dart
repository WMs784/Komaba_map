import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:appbar_textfield/appbar_textfield.dart';
import 'package:styled_text/styled_text.dart';
import 'dart:math';

import 'search_building.dart';
import 'apikey.dart';
import 'map_setting.dart';
import 'package:geolocator/geolocator.dart';

int count = 0;
double cur_lat = 0,cur_lng = 0;
void main() => runApp(MyApp());

void getLocate() async{
  Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  print(position);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Komaba map',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        home:Scaffold(
          body:MapScreen(),
        )
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  double _originLatitude = cur_lat,
      _originLongitude = cur_lng; //駒場東大前駅
  double _destLatitude = dest_lat(cn),
      _destLongitude = dest_lng(cn);
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPIKey = api_key;

//目的地の緯度経度


  @override
  void initState() {
    super.initState();
    getLocation();
    /// origin marker
    _addMarker(LatLng(_originLatitude, _originLongitude), "origin",
        BitmapDescriptor.defaultMarker);

    /// destination marker
    _addMarker(LatLng(dest_lat(cn), dest_lng(cn)), "destination",
        BitmapDescriptor.defaultMarkerWithHue(90));
    _getPolyline();
  }

  void getLocation() async {
    // 現在の位置を返す
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    cur_lat = position.latitude;
    cur_lng = position.longitude;
  } //現在地座標の取得


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBarTextField(
            title: Text(guide),
            onChanged: (text) {
              cn = text;
              _addMarker(LatLng(dest_lat(cn), dest_lng(cn)), "destination",
                  BitmapDescriptor.defaultMarkerWithHue(90));
              if (search(cn) >= 100) {
                mapController.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(dest_lat(cn), dest_lng(cn)),
                      zoom: 17.5,
                    ),
                  ),
                );
              }
              else {
                mapController.animateCamera(
                    CameraUpdate.newLatLngBounds(
                        LatLngBounds(
                          southwest: LatLng(
                              ori_lat, min(ori_lng, _destLongitude)),
                          northeast: LatLng(
                              dest_lat(cn), max(ori_lng, _destLongitude)),
                        ),
                        100.0
                    )
                );
              }
              polylines = {};
              polylineCoordinates = [];
              //main();
              _getPolyline();
            }
        ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              DrawerHeader(
                child: StyledText(
                  text: '<set/>&space;' + setting,
                  style: TextStyle(
                      fontSize: 24
                  ),
                  tags: {
                    'set': StyledTextIconTag(
                      Icons.settings,
                      size: 30,
                    ),
                  },
                ),
                decoration: BoxDecoration(
                  color: Theme
                      .of(context)
                      .primaryColor,
                ),
              ),
              ListTile(
                title: Text("日本語"),
                onTap: () {
                  guide = "教室番号";
                  ec = "正しい教室番号を入力してください";
                  setting = "言語設定";
                  Navigator.pop(context);
                  main();
                },
              ),
              ListTile(
                title: Text("English"),
                onTap: () {
                  guide = "classroom number";
                  ec = "Enter the correct classroom number.";
                  setting = "language setting";
                  Navigator.pop(context);
                  main();
                },
              ),
            ],
          ),
        ),
        body: Stack(
          children: <Widget>[
            GoogleMap(
              initialCameraPosition: CameraPosition(
                  target: LatLng(dest_lat(cn), dest_lng(cn)), zoom: 17.5),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              tiltGesturesEnabled: true,
              compassEnabled: true,
              scrollGesturesEnabled: true,
              zoomGesturesEnabled: true,
              onMapCreated: _onMapCreated,
              markers: Set<Marker>.of(markers.values),
              polylines: Set<Polyline>.of(polylines.values),
            ),
            Container(
                color: Colors.white,
                //width: double.infinity,
                height: 40,
                margin: EdgeInsets.all(10.0),
                padding: EdgeInsets.all(5.0),
                alignment: Alignment.topCenter,
                child: Text(mark_name(cn),
                    style: TextStyle(
                        fontSize: 20
                    )
                )
            )
          ],
        ),
        // floatingActionButton: FloatingActionButton.extended(
        //   onPressed: () {
        //     setState(() {
        //       mapController.animateCamera(
        //         CameraUpdate.newCameraPosition(
        //           CameraPosition(
        //             target: setOrigin(_originLatitude,_originLongitude),
        //             zoom: 17.5,
        //           ),
        //         ),
        //       );
        //       main();
        //       _getPolyline();
        //     });
        //   },
        //   label: Text("現在地に変更"),
        // ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
    Marker(
        markerId: markerId,
        icon: descriptor,
        position: position,
        infoWindow: InfoWindow(title: mark_name(cn))
    );
    markers[markerId] = marker;
  }

  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id, color: Colors.red, points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  _getPolyline() async {
    main();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPIKey,
      PointLatLng(ori_lat, (ori_lng)),
      PointLatLng(dest_lat(cn), dest_lng(cn)),
      travelMode: TravelMode.walking,
      //wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")]
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
  }
}
class setOriginButton extends StatefulWidget{
  const setOriginButton({Key? key}) : super(key: key);

  @override
  _setOriginButtonState createState() => _setOriginButtonState();
}
class _setOriginButtonState extends State<setOriginButton>{
  double _originLatitude = 0,_originLongitude = 0;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: FloatingActionButton.extended(
        onPressed: () {
          count++;
          setState(() {
            _originLatitude = setOriLat(count);
            _originLongitude = setOriLng(count);
            // mapController.animateCamera(
            //   CameraUpdate.newCameraPosition(
            //     CameraPosition(
            //       target: LatLng(_originLatitude,_originLongitude),
            //       zoom: 17.5,
            //     ),
            //   )
            // );
            main();
            //_getPolyline();
          });
        },
        label: Text("現在地に変更"),
      ),
    );
  }
}
// class _getPolyline extends StatelessWidget{
//   const _getPolyline({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     PolylineResult result = polylinePoints.getRouteBetweenCoordinates(
//       googleAPIKey,
//       PointLatLng(_originLatitude, _originLongitude),
//       PointLatLng(dest_lat(cn), dest_lng(cn)),
//       travelMode: TravelMode.walking,
//       //wayPoints: [PolylineWayPoint(location: "Sabo, Yaba Lagos Nigeria")]
//     );
//     if (result.points.isNotEmpty) {
//       result.points.forEach((PointLatLng point) {
//         polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//       });
//     }
//   }
// }