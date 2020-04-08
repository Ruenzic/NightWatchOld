class WatchGroup {

  String watchGroupId = '';
  final String adminId;
  final String name;
  final List<String> users;
  final bool isPrivate;

  WatchGroup({ this.name, this.users, this.adminId, this.isPrivate });
}