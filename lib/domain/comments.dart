class Comments {
  String uid;
  String userName;
  String comments;
  Comments({required this.uid, required this.userName, required this.comments});
  Map<String, dynamic> tomap() {
    final mapping = <String, dynamic>{};
    mapping['uid'] = uid;
    mapping['userName'] = userName;
    mapping['comments'] = comments;
    return mapping;
  }

  factory Comments.fromMap(Map<String, dynamic> map) {
    return Comments(
      uid: map['uid'],
      userName: map['userName'],
      comments: map['comments'],
    );
  }
}
