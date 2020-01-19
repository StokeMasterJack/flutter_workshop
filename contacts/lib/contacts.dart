import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:contacts/Vm.dart';
import 'package:contacts/perms.dart';
import 'package:contacts/random_contacts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quiver/check.dart';
import 'package:ssutil/ssutil.dart' as ss;

enum Col { Red, Green, Blue }
enum Level { Beginner, Intermediate, Advanced }

typedef T ContactGetter<T>(Contact receiver);

class MutableContacts extends DelegatingList<Contact> {
  List<Contact> _base;

  MutableContacts(List<Contact> base) : super(base) {
    this._base = base;
  }

  Contacts immutable() {
    return Contacts(_base);
  }
}

class Contacts extends UnmodifiableListView<Contact> {
  final List<Contact> _base;

  Contacts([List<Contact> base])
      : this._base = base ?? <Contact>[],
        super(base ?? <Contact>[]);

  static final Contacts _empty = Contacts();

  static Contacts get empty => _empty;

  static List<Contact> fromJsonSync(dynamic jsonData) {
    List<Contact> contacts = [];
    if (jsonData is Map) {
      Contact contact = Contact.fromJson(jsonData);
      contacts.add(contact);
    } else if (jsonData is List) {
      for (Map<String, dynamic> jsonMap in jsonData) {
        Contact contact = Contact.fromJson(jsonMap);
        contacts.add(contact);
      }
    } else {
      ss.throwStateErr();
    }
    return contacts;
  }

  void sortByName() {
    Comparator<Contact> comparator = (Contact a, Contact b) => a.fullName.compareTo(b.fullName);
    this.sort(comparator);
  }

  static List<Contact> fromJsonTextSync(String jsonText) {
    try {
      dynamic jsonData = json.decode(jsonText);
      return fromJsonSync(jsonData);
    } catch (e, st) {
      debugPrint("Error parsing json");
      debugPrint("  $e");
      debugPrint("  $st");
      return [];
    }
  }

  static Future<List<Contact>> fromJsonTextAsync(String jsonText) async {
    return compute(fromJsonTextSync, jsonText);
  }

  static List<Map<String, dynamic>> toJsonSync(Map<Id, Contact> map) {
    List<Map<String, dynamic>> a = <Map<String, dynamic>>[];
    for (Contact contact in map.values) {
      a.add(contact.toJson());
    }
    return a;
  }

  static String toJsonTextSync(Map<Id, Contact> map) {
    List<Map<String, dynamic>> jsonData = toJsonSync(map);
    return json.encode(jsonData);
  }

  static Future<String> toJsonText(Map<Id, Contact> map) {
    return compute(toJsonTextSync, map);
  }

  Contacts filter(Filter filter) {
    return Contacts(where((Contact c) => filter(c)).toList());
  }

  Contacts byKey(TabKey tabKey) {
    return filter(Filters.map[tabKey]);
  }

  Contacts favorites() => filter(Filters.favFilter);

  Contacts favorites2() => filter(Filters.favFilter);

  Contacts actives() => filter(Filters.activeFilter);

  Contacts all() => this;
}

class Id {
  static final _rng = Random();
  final int value;

  Id(this.value) : assert(value != null);

  @override
  String toString() {
    return value.toString();
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is Id && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;

  static Id gen() => new Id(_rng.nextInt(1 << 32));

  static Id parse(String sId) {
    checkArgument(int.tryParse != null);
    int iId = int.parse(sId);
    return Id(iId);
  }
}

class IdSet extends UnmodifiableSetView<Id> {
  static final IdSet _empty1 = new IdSet(Set<Id>());

  IdSet(Set<Id> ids)
      : assert(ids != null),
        super(ids);

  static IdSet get empty {
    assert(_empty1 != null);
    return _empty1;
  }
}

class MutableIdSet extends DelegatingSet<Id> {
  MutableIdSet() : super(new Set<Id>());

  IdSet immutable() {
    return IdSet(this);
  }

  void toggleSelection(Id id) {
    if (contains(id))
      remove(id);
    else
      add(id);
  }
}

Col parseCol(String sCol) {
  if (sCol == null || sCol.trim().isEmpty) return Col.Red;
  assert(sCol is String);
  for (Col value in Col.values) {
    if (describeEnum(value) == sCol) {
      assert(value is Col);
      return value;
    }
  }
  throw ArgumentError();
}

Level parseLevel(String sLevel) {
  if (sLevel == null || sLevel.trim().isEmpty) return Level.Beginner;
  for (Level value in Level.values) {
    if (describeEnum(value) == sLevel) {
      return value;
    }
  }
  throw ArgumentError();
}

class NameValue {
  String name;
  String value;

  NameValue({this.name, this.value});

  static NameValue fromEntry(MapEntry<String, dynamic> e) {
    return NameValue(name: e.key, value: e.value == null ? null : e.value.toString());
  }

  Widget toColumnWidget() {
    return Column(
      children: <Widget>[Text(name), Text(value ?? "")],
    );
  }

  Widget toListTileWidget() {
    return ListTile(
      title: Text("$name $value"),
//      trailing:Text(value ?? "")
    );
  }
}

class Contact {
  final Id id;
  final String firstName;
  final String lastName;
  final Col color;
  final Level level;
  final bool active;
  final bool favorite;
  final String nat;
  final String largeImg;
  final String mediumImg;
  final String thumbnail;

  const Contact({
    @required this.id,
    this.firstName,
    this.lastName,
    this.level = Level.Beginner,
    this.color = Col.Red,
    this.active = false,
    this.favorite = false,
    this.nat = "US",
    this.largeImg,
    this.mediumImg,
    this.thumbnail,
  });

  static Contact copy(Contact c, {bool isNullNormalize = false}) {
    String n(String s) => isNullNormalize ? ss.nullNormalize(s) : s;
    return Contact(
        id: c.id,
        firstName: n(c.firstName),
        lastName: n(c.lastName),
        level: c.level,
        color: c.color,
        active: c.active,
        favorite: c.favorite,
        nat: n(c.nat),
        largeImg: n(c.largeImg),
        mediumImg: n(c.mediumImg),
        thumbnail: n(c.thumbnail));
  }

  Contact nullNormalize() {
    return copy(this, isNullNormalize: true);
  }

  String get bestImage {
    return largeImg ?? mediumImg ?? thumbnail;
  }

  Contact.empty() : this(id: Id.gen());

  String get fullName => "$firstName $lastName";

  @override
  String toString() {
    return 'Person{firstName: $firstName, lastName: $lastName, col: $color, active: $active}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Contact &&
          runtimeType == other.runtimeType &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          color == other.color &&
          level == other.level &&
          active == other.active &&
          favorite == other.favorite &&
          nat == other.nat &&
          largeImg == other.largeImg &&
          mediumImg == other.mediumImg &&
          thumbnail == other.thumbnail;

  @override
  int get hashCode =>
      firstName.hashCode ^
      lastName.hashCode ^
      color.hashCode ^
      level.hashCode ^
      active.hashCode ^
      favorite.hashCode ^
      nat.hashCode ^
      largeImg.hashCode ^
      mediumImg.hashCode ^
      thumbnail.hashCode;

  Map<String, dynamic> toJson() {
    assert(nat == null || nat is String);
    assert(color != null && color is Col);
    return {
      'id': id.value,
      'firstName': firstName,
      'lastName': lastName,
      'color': describeEnum(color),
      'level': describeEnum(level),
      'active': active,
      'favorite': favorite,
      'nat': nat,
      'largeImg': largeImg,
      'mediumImg': mediumImg,
      'thumbnail': thumbnail,
    };
  }

  /*

  MappedIterable<MapEntry<String, dynamic>, NameValue>
    is not a subtype of type
  List<NameValue>

   */

  List<NameValue> nvList() {
    Map<String, dynamic> jsonMap = toJson();

    Iterable<MapEntry<String, dynamic>> entries = jsonMap.entries;

    List<NameValue> list = <NameValue>[];
    for (MapEntry<String, dynamic> entry in entries) {
      NameValue nv = NameValue.fromEntry(entry);
      list.add(nv);
    }

    return list;
  }

  String toJsonText() {
    Map<String, dynamic> jsonMap = toJson();
    String jsonText = json.encode(jsonMap);
    return jsonText;
  }

  static Contact fromJson(Map<String, dynamic> map) {
    return new Contact(
      id: Id(map["id"]),
      firstName: map["firstName"],
      lastName: map["lastName"],
      color: parseCol(map["color"]),
      level: parseLevel(map["level"]),
      active: map["active"],
      favorite: map["favorite"],
      nat: map["nat"],
      largeImg: map["largeImg"],
      mediumImg: map["mediumImg"],
      thumbnail: map["thumbnail"],
    );
  }

  static Contact fromJsonText(String jsonText) {
    Map<String, dynamic> map = json.decode(jsonText);
    return fromJson(map);
  }

  String get avatarChar => ss.avatarChar(fullName);

  bool matchesSearchFilter(String query) {
    assert(query != null);
    String q = query.trim().toUpperCase();
    if (q == "") return true;
    return fullName.toUpperCase().contains(q);
  }

  void validate() {
    assert(id != null);
  }
}

class Field<T> {
  final ContactGetter<T> getter;
  final ss.EzComparator<T> ezComparator;

  const Field(this.getter, this.ezComparator);

  void sort(MutableContacts contacts, [bool asc = true]) {
    return contacts.sort(comparator(asc));
  }

  Comparator<Contact> comparator(bool asc) {
    return asc ? compareAsc : compareDesc;
  }

  int compareAsc(Contact a, Contact b) {
    return _nullSafeFieldCompare(a, b);
  }

  int compareDesc(Contact a, Contact b) {
    return -_nullSafeFieldCompare(a, b);
  }

  int _nullSafeFieldCompare(Contact a, Contact b) {
    return ss.nullSafeCompare<Contact>(a, b, _ezFieldCompare);
  }

  int _ezFieldCompare(Contact a, Contact b) {
    T aa = getter(a);
    T bb = getter(b);
    return ss.nullSafeCompare<T>(aa, bb, ezComparator);
  }

  static String _fullNameGetter(Contact c) => c.fullName;

  static bool _activeGetter(Contact c) => c.active;

  static const Field fullName = const Field<String>(_fullNameGetter, ss.ezStringCompare);
  static final Field active = Field<bool>(_activeGetter, ss.ezBoolCompare);
}

enum TabKey { favorites, active, all }

class Sort {
  final Field field;
  final bool asc;

  const Sort({this.field = Field.fullName, this.asc = true});

  void sort(MutableContacts contacts) {
    field.sort(contacts, asc);
  }

  static final Sort fullNameAsc = new Sort(field: Field.fullName, asc: true);
  static final Sort fullNameDesc = new Sort(field: Field.fullName, asc: false);

  static final Sort activeAsc = new Sort(field: Field.active, asc: true);
  static final Sort activeDesc = new Sort(field: Field.active, asc: false);
}

typedef bool Filter(Contact contact);

class Filters {
  static Map<TabKey, Filter> map = {TabKey.favorites: favFilter, TabKey.active: activeFilter, TabKey.all: trueFilter};

  static bool activeFilter(Contact c) => c.active;

  static bool inactiveFilter(Contact c) => !c.active;

  static bool trueFilter(Contact c) => true;

  static bool favFilter(Contact c) => c.favorite;

  static Filter createSearchStringFilter(String q) {
    return (Contact c) => c.matchesSearchFilter(q);
  }
}

class DbQuery {
  final Sort _sort;
  final Filter _filter;

  DbQuery([Filter filter, Sort sort])
      : this._sort = sort ?? Sort.fullNameAsc,
        this._filter = filter ?? Filters.trueFilter;

  static DbQuery fav = new DbQuery(Filters.favFilter, Sort.fullNameAsc);

  void sort(MutableContacts a) {
    _sort.sort(a);
  }

  Filter get filter => _filter;
}

typedef DbListener(Db db);

class Db extends ChangeNotifier {
  static const defaultLocalFileName = "contacts.json";
  static const defaultLocalAssetName = "data/contacts.json";

  Future<PermissionStatus> externalStoragePerm;

  final Map<Id, Contact> map = <Id, Contact>{};

  Sort defaultSort = Sort.fullNameAsc;

  get contactCount => map.length;

  Db([bool vm = false]) {
    print("db constructor");
  }

  void cleanUp() {
    dispose();
  }

  MutableContacts filter(Filter filter) {
    MutableContacts results = MutableContacts([]);
    for (Contact contact in iterable) {
      assert(contact != null);
      if (filter(contact)) {
        results.add(contact);
      }
    }
    return results;
  }

  Contacts executeQuery(DbQuery q) {
    MutableContacts a = filter(q.filter);
    q.sort(a);
    return a.immutable();
  }

  Contacts select(Filter filter) {
    return executeQuery(DbQuery(filter, defaultSort));
  }

  void delete(Id id) {
    map.remove(id);
    notifyListeners();
  }

  void deleteAll(IdSet ids) {
    map.removeWhere((Id id, _) => ids.contains(id));
    notifyListeners();
  }

  void clearDb() async {
    map.clear();
    notifyListeners();
  }

  //null if bad id
  Contact getById(Id id) {
    return map[id];
  }

  void put(Contact contact) {
    contact.validate();
    map[contact.id] = contact;
    notifyListeners();
  }

  void putAll(Iterable<Contact> contacts) {
    for (Contact contact in contacts) {
      map[contact.id] = contact;
    }
    notifyListeners();
  }

  Iterable<Contact> get iterable {
    return map.values;
  }

  Future<void> importFromRandom() async {
    return importNRecordsFromRandomUser(500);
  }

  Future<void> importNRecordsFromRandomUser(int n) async {
    Contacts contacts = await fetchSampleDataFromRandomUser3(n);
    int size1 = map.length;
    this.putAll(contacts);
    int size2 = map.length;
    assert(size2 > size1);
    notifyListeners();
  }

  Future<bool> addContactsFromJson(String jsonText) async {
    final contacts = await Contacts.fromJsonTextAsync(jsonText);
    _addAll(contacts);
    notifyListeners();
    return true;
  }

  void _addAll(Iterable<Contact> contacts) {
    for (Contact contact in contacts) {
      map[contact.id] = contact;
    }
  }

  void importFromJsonAssetSync() {
    Future<String> future = loadJsonAssetAsync();
    future.then((String text) {
      List<Contact> contacts = Contacts.fromJsonTextSync(text);
      _addAll(contacts);
      notifyListeners();
    }, onError: (err) {
      print("err $err");
    });
  }

  Future<bool> importFromJsonAssetAsync() async {
    String jsonText = await loadJsonAssetAsync();
    List<Contact> contacts = await Contacts.fromJsonTextAsync(jsonText);
    _addAll(contacts);
    notifyListeners();
    return true;
  }

  Future<bool> importFromDocDir() async {
    String jsonText = await readTextFromDocDir(defaultLocalFileName);
    if (jsonText == null) return false;
    List<Contact> contacts = await Contacts.fromJsonTextAsync(jsonText);
    _addAll(contacts);
    notifyListeners();
    return true;
  }

  Future<PermissionStatus> maybeRequestExtStoragePerm() {
    if (externalStoragePerm == null) {
      externalStoragePerm = requestExtStoragePerm();
    }
    return externalStoragePerm;
  }

  Future<void> importFromExtDir() async {
    final PermissionStatus perm = await maybeRequestExtStoragePerm();
    if (perm != PermissionStatus.granted) {
      throw Exception("Permission not granted: $perm");
    }
    String jsonText = await readTextFromExtDir(defaultLocalFileName);
    if (jsonText == null) {
      throw Exception("External file $defaultLocalFileName is empty");
    }
    List<Contact> contacts = await Contacts.fromJsonTextAsync(jsonText);
    _addAll(contacts);
    notifyListeners();
  }

  Future<void> exportToExtDir() async {
    final PermissionStatus perm = await maybeRequestExtStoragePerm();
    if (perm != PermissionStatus.granted) {
      throw Exception("Permission not granted: $perm");
    }
    String jsonText = await Contacts.toJsonText(map);
    await writeTextToExtDir(defaultLocalFileName, jsonText);
  }

  Future<File> exportToDocDir() async {
    String jsonText = await Contacts.toJsonText(map);
    return await writeTextToDocDir(defaultLocalFileName, jsonText);
  }

  Future<File> exportToTmpDir() async {
    String jsonText = await Contacts.toJsonText(map);
    return await writeTextToTmpDir(defaultLocalFileName, jsonText);
  }

  List<Contact> toList() {
    List<Contact> a = <Contact>[];
    for (Contact contact in iterable) {
      a.add(contact);
    }
    return a;
  }

  static Future<String> loadJsonAssetAsync() async {
    AssetBundle assetBundle = Vm.assetBundle();
    return assetBundle.loadString(defaultLocalAssetName);
  }

  Future<Directory> docDir() async {
    return getApplicationDocumentsDirectory();
  }

  Future<Directory> tmpDir() async {
    return getTemporaryDirectory();
  }

  Future<Directory> extDir() async {
    return getExternalStorageDirectory();
  }

  static Future<File> writeTextToDocDir(String localName, String data) async {
    final dir = await getApplicationDocumentsDirectory();
    String dirPath = dir.path;
    File file = new File('$dirPath/$localName');
    print("docDir: $file");
    return await file.writeAsString(data);
  }

  static Future<String> readTextFromDocDir(String localName) async {
    final dir = await getApplicationDocumentsDirectory();
    String dirPath = dir.path;
    File file = new File('$dirPath/$localName');
    bool exists = await file.exists();
    if (!exists) return null;
    return file.readAsString();
  }

  static Future<String> readTextFromExtDir(String localName) async {
    final dir = await getExternalStorageDirectory();
    String dirPath = dir.path;
    File file = new File('$dirPath/$localName');
    bool exists = await file.exists();
    if (!exists) {
      throw Exception("External file $file does not exist");
    }
    return await file.readAsString();
  }

  static Future<bool> writeTextToExtDir(String localName, String data) async {
    final dir = await getExternalStorageDirectory();
    String dirPath = dir.path;
    File file = new File('$dirPath/$localName');
    print("extDir: $file");
    try {
      await file.writeAsString(data);
      return true;
    } catch (e, s) {
      debugPrint("---------");
      debugPrint("Error attempting to writeTextToExtDir");
      debugPrint(e.toString());
      debugPrint("StackTrace returned from future:");
      debugPrint(s.toString());
      debugPrint("StackTrace current:");
      debugPrint(StackTrace.current.toString());
      debugPrint("---------");
      return false;
    }
  }

  static Future<File> writeTextToTmpDir(String localName, String data) async {
    final dir = await getTemporaryDirectory();
    String dirPath = dir.path;
    File file = new File('$dirPath/$localName');
    print("tmpDir: $file");
    return await file.writeAsString(data);
  }

  static int safeHash(Db db) {
    return identityHashCode(db);
  }

  static String safeToString(Db db) {
    if (db == null)
      return "DbNull[${safeHash(db)}]";
    else
      return "DbNonNull[${safeHash(db)}]";
  }

  void printDirs() {
    print("tmp: ${tmpDir()}");
    print("docDir: ${docDir()}");
    print("extDir: ${extDir()}");
  }

  void printHasListeners() {
    print("hasListeners: $hasListeners");
  }
}
