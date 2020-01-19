import 'package:contacts/Vm.dart';
import 'package:contacts/contacts.dart';
import 'package:contacts/sample_data.dart';
import 'package:test/test.dart';

void main() {
  Vm.isVm = true;

  test('Import parseJSON', () async {
    String jsonText = SampleData.contactsJsonText;
    List<Contact> contacts1 = Contacts.fromJsonTextSync(jsonText);
    expect(contacts1.length, 255);

    List<Contact> contacts2 = await Contacts.fromJsonTextAsync(jsonText);
    expect(contacts2.length, 255);

    Db db = Db(true);

    void onDbChange() {
      print("onDbChange: ${db.contactCount}");
    }

    db.addListener(onDbChange);

    await db.addContactsFromJson(jsonText);
    expect(db.contactCount, 255);

//
//    await app.db.importFromJsonAsset();
//    print(app.db.contactCount);
  });
}
