import 'package:flutter/cupertino.dart';
import 'package:mobile/widgets/TrackList.dart';

class AccordionWidget extends StatefulWidget {
  const AccordionWidget({Key? key}) : super(key: key);

  @override
  _AccordionWidgetState createState() => _AccordionWidgetState();
}

class AccordionItem {
  final String title;
  final Widget content;

  AccordionItem({required this.title, required this.content});
}

class _AccordionWidgetState extends State<AccordionWidget> {
  int _selectedIndex = -1;
  final List<AccordionItem> _items = [
    AccordionItem(title: "Tracklist", content: const TrackList())
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return Column(
          children: <Widget>[
            CupertinoButton(
              onPressed: () {
                setState(() {
                  _selectedIndex = _selectedIndex == index ? -1 : index;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  Icon(
                    _selectedIndex == index
                        ? CupertinoIcons.up_arrow
                        : CupertinoIcons.down_arrow,
                    size: 18.0,
                    color: CupertinoColors.systemGrey,
                  ),
                ],
              ),
            ),
            if (_selectedIndex == index)
              SizedBox(
                height: 80.0,
                child: Center(child: item.content),
              )
          ],
        );
      }).toList(),
    );
  }
}
