import 'package:flutter/material.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';

import 'download.dart';

class ButtonList extends StatefulWidget {
  final String url;

  const ButtonList({super.key, required this.url});
  @override
  _ButtonListState createState() => _ButtonListState();
}

class _ButtonListState extends State<ButtonList> {
  bool isButtonListVisible = true;

  void hideButtonList() {
    setState(() {
      isButtonListVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isButtonListVisible,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Add your logic here for the lock screen button
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => DownloadingDialog(
                      url: widget.url,
                      location: WallpaperManager.LOCK_SCREEN,
                    ),
                  );
                  hideButtonList(); // Hide the button list
                },
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      "Lock Screen",
                      style: TextStyle(fontSize: 17.0),
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  backgroundColor: Colors.black87,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  minimumSize: Size(double.infinity, 60.0),
                  elevation: 0.0,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => DownloadingDialog(
                      url: widget.url,
                      location: WallpaperManager.HOME_SCREEN,
                    ),
                  );
                  // Add your logic here for the home screen button
                  hideButtonList(); // Hide the button list
                },
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Home Screen",
                      style: TextStyle(fontSize: 17.0),
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  backgroundColor: Colors.black87,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  minimumSize: Size(double.infinity, 60.0),
                  elevation: 0.0,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => DownloadingDialog(
                      url: widget.url,
                      location: WallpaperManager.BOTH_SCREEN,
                    ),
                  );
                  // Add your logic here for the home screen and lock screen button
                  hideButtonList(); // Hide the button list
                },
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Home Screen and Lock Screen",
                      style: TextStyle(fontSize: 17.0),
                    ),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  backgroundColor: Colors.black87,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  minimumSize: Size(double.infinity, 60.0),
                  elevation: 0.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
