import 'dart:convert';

import 'package:flutter/material.dart';
import '../main.dart';
import 'collections.dart';
import 'favorite.dart';

class Menu extends StatefulWidget {
  final int currentIndex;
  final JsonFileManager jsonFileManager;

  const Menu({required this.currentIndex, required this.jsonFileManager});

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        UserAccountsDrawerHeader(
          decoration: BoxDecoration(color: const Color(0xff000000)),
          accountName: Text(
            "Amine0x01",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          accountEmail: Text(
            "amineone@gmail.com",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          currentAccountPicture: FlutterLogo(),
        ),
        ListTile(
          leading: Icon(
            Icons.home,
            color: widget.currentIndex == 0 ? Colors.indigo[600] : Colors.black,
          ),
          title: Text(
            'Home',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color:
                  widget.currentIndex == 0 ? Colors.indigo[600] : Colors.black,
            ),
          ),
          onTap: () {
            if (widget.currentIndex != 0) {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Homepage()),
              );
            } else {
              Navigator.pop(context);
            }
          },
          selected: widget.currentIndex == 0,
        ),
        ListTile(
          leading: Icon(
            Icons.auto_awesome_mosaic_rounded,
            color: widget.currentIndex == 1 ? Colors.indigo[600] : Colors.black,
          ),
          title: Text(
            'Collections',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color:
                  widget.currentIndex == 1 ? Colors.indigo[600] : Colors.black,
            ),
          ),
          onTap: () {
            if (widget.currentIndex != 1) {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Collection(
                          jsonFileManager: widget.jsonFileManager,
                        )),
              );
            } else {
              Navigator.pop(context);
            }
          },
          selected: widget.currentIndex == 1,
        ),
        ListTile(
          leading: Icon(
            Icons.favorite,
            color: widget.currentIndex == 2 ? Colors.indigo[600] : Colors.black,
          ),
          title: Text(
            'Favorite',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color:
                  widget.currentIndex == 2 ? Colors.indigo[600] : Colors.black,
            ),
          ),
          onTap: () {
            if (widget.currentIndex != 2) {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Favorite(
                          jsonFileManager: widget.jsonFileManager,
                        )),
              );
            } else {
              Navigator.pop(context);
            }
          },
          selected: widget.currentIndex == 2,
        ),
        ListTile(
          leading: Icon(
            Icons.send,
            color: widget.currentIndex == 2 ? Colors.indigo[600] : Colors.black,
          ),
          title: Text(
            'Share',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color:
                  widget.currentIndex == 2 ? Colors.indigo[600] : Colors.black,
            ),
          ),
          onTap: () {
            if (widget.currentIndex != 2) {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Favorite(
                          jsonFileManager: widget.jsonFileManager,
                        )),
              );
            } else {
              Navigator.pop(context);
            }
          },
          selected: widget.currentIndex == 2,
        ),
        ListTile(
          leading: Icon(
            Icons.info,
            color: widget.currentIndex == 3 ? Colors.indigo[600] : Colors.black,
          ),
          title: Text(
            'About',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color:
                  widget.currentIndex == 3 ? Colors.indigo[600] : Colors.black,
            ),
          ),
          onTap: () {
            if (widget.currentIndex != 3) {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Favorite(
                          jsonFileManager: widget.jsonFileManager,
                        )),
              );
            } else {
              Navigator.pop(context);
            }
          },
          selected: widget.currentIndex == 3,
        ),
      ],
    );
  }
}
