class User {
  final String? name;

  List<String> history = [];

  List<String> date = [];

  User({this.name});

  String? get getname => name;

  List<String> get getHistory => history;

  List<String> get getDate => date;

  void addHistory(String item) {
    history.add(item);
  }

  void removeHistory(String item) {
    history.remove(item);
  }

  void addDate(String item) {
    date.add(item);
  }

  void removeDate(String item) {
    date.remove(item);
  }
}
