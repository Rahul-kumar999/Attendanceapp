import 'package:location/location.dart';

class LocationService{
  Location location = Location();
  late LocationData _locData;
  Future<void> initialize()async {
    bool _serviceEnableled;
    PermissionStatus _permission;
    _serviceEnableled = await location.serviceEnabled();
    if(!_serviceEnableled) {
      _serviceEnableled = await location.requestService();
      if(!_serviceEnableled){
        return;
      }
    }
    _permission = await location.hasPermission();
    if(_permission == PermissionStatus.denied){
      _permission  =await location.requestPermission();
      if(_permission !=PermissionStatus.granted){
        return;
      }
    }
  }
  Future<double?> getLatitude() async {
    _locData =await location.getLocation();
    return _locData.latitude;
  }
  Future<double?> getLongitude() async {
    _locData = await location.getLocation();
    return _locData.longitude;
  }

}