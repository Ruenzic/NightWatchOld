class Timeslot {

  final String startTime;
  final String endTime;
  final int numberUsers;
  String id;
  Map signups;

  Timeslot({ this.startTime, this.endTime, this.numberUsers, this.id, this.signups });

  Map<String, dynamic> toJson() =>
    {
      'startTime': startTime,
      'endTime': endTime,
      'numberUsers': numberUsers
    };

//  List<Map<String, dynamic>> listOMaps = listOStuff
//    .map((something) => {
//      "what": something.what,
//      "the": something.the,
//      "fiddle": something.fiddle,
//    })
//    .toList();
}
