import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import 'collections.dart';
import 'favorite.dart';

class ShareHelper {
  static void shareMessage(String message) {
    Share.share(message);
  }
}

class Menu extends StatefulWidget {
  final int currentIndex;
  final JsonFileManager jsonFileManager;
  final VoidCallback showInterstitialAd;

  const Menu(
      {required this.currentIndex,
      required this.jsonFileManager,
      required this.showInterstitialAd});

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
          decoration: BoxDecoration(color: Color(0xff131416)),
          accountName: Text(
            " Wallpapers",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          accountEmail: Text(""),
          currentAccountPicture: CircleAvatar(
            radius: 10,
            backgroundImage: AssetImage(
              "assets/icons/drawer.png",
            ),
            backgroundColor: Colors.black,
          ),
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
                          showInterstitialAd: widget.showInterstitialAd,
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
                          showInterstitialAd: widget.showInterstitialAd,
                        )),
              );
            } else {
              Navigator.pop(context);
            }
          },
          selected: widget.currentIndex == 2,
        ),
        ListTile(
          leading: Container(
            width: 22,
            height: 22,
            child: Image.asset(
              'assets/icons/send.png',
              color:
                  widget.currentIndex == 3 ? Colors.indigo[600] : Colors.black,
            ),
          ),
          title: Text(
            'Share',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color:
                  widget.currentIndex == 3 ? Colors.indigo[600] : Colors.black,
            ),
          ),
          onTap: () {
            String message = "Applink";
            ShareHelper.shareMessage(message);
            Navigator.pop(context);
          },
          selected: widget.currentIndex == 3,
        ),
        Divider(),
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
          onTap: () async {
            Navigator.pop(context);
            if (await canLaunch(
                "https://sites.google.com/view/amine-dev/home")) {
              await launch("https://sites.google.com/view/amine-dev/home");
            } else {
              throw Exception('Could not launch url');
            }
          },
          selected: widget.currentIndex == 3,
        ),
      ],
    );
  }
}
