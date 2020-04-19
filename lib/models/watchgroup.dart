import 'package:i_am_rich/models/timeslot.dart';

class WatchGroup {

  final String watchGroupId = '';
  final String adminId;
  final String name;
  final List<String> users;
  final bool isPrivate;
  final String location;
  final double latitude;
  final double longitude;
  List<Timeslot> timeslots;
  List<String> daysOfWeek;

  WatchGroup({ this.name, this.users, this.adminId, this.isPrivate, this.location, this.timeslots, this.daysOfWeek, this.latitude, this.longitude });
}