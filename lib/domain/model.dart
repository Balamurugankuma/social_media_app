class Model {
  String? uid;
  String? name;
  String? email;
  String? password;
  String? imageUrl;

  Model({
    required this.uid,
    required this.name,
    required this.email,
    required this.password,
    required this.imageUrl,
  });

  factory Model.fromMap(Map<String, dynamic> map) {
    return Model(
      uid: map['uid']?.toString(),
      name: map['name'],
      email: map['email'],
      password: map['password'],
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> map() {
    final mapping = <String, dynamic>{};
    mapping['uid'] = uid;
    mapping['name'] = name;
    mapping['email'] = email;
    mapping['password'] = password;
    mapping['imageUrl'] = imageUrl;
    return mapping;
  }
}
