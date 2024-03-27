import '../XmppElement.dart';
import 'named_element.dart';

class ListElement extends NamedElement {
  ListElement(String name) {
    this.name = 'list';
    setName(name);
  }

  void setItems(List<XmppElement> items) {
    for (var element in items) {
      addChild(element);
    }
  }

  void addItem(XmppElement item) {
    addChild(item);
  }
}
