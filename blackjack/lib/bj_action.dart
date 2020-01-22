class Page {
  final String type;
  final String title;

  const Page._(this.type, this.title);

  static const Page ui1 = Page._("game1", "Blackjack - UI 1");

  static const Page ui2 = Page._("game2", "Blackjack - UI 2");

  static const Page home = Page._("home", "Blackjack - Home");

  String get name => this.type;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Page && runtimeType == other.runtimeType && type == other.type;

  @override
  int get hashCode => type.hashCode;
}




