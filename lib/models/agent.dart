class Agent {
  String id;
  String name;
  String imgUrl;
  String email;

  Agent({this.id, this.name, this.imgUrl, this.email});

  toJson() {
    return {
      'name': name,
      'imgUrl': imgUrl,
      'email': email,
    };
  }
}
