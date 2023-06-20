import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import 'package:image_gallery_saver/image_gallery_saver.dart';

class DownloadingDialog extends StatefulWidget {
  final String url;
  final int location;
  const DownloadingDialog({Key? key, required this.url, required this.location})
      : super(key: key);

  @override
  _DownloadingDialogState createState() => _DownloadingDialogState();
}

class _DownloadingDialogState extends State<DownloadingDialog> {
  Dio dio = Dio();
  double progress = 0.0;
  bool showErrorDialog = false;

  void startDownloading() async {
    const String fileName = "amine.jpg";

    String path = await _getFilePath(fileName);

    await dio.download(
      widget.url,
      path,
      onReceiveProgress: (receivedBytes, totalBytes) {
        setState(() {
          progress = receivedBytes / totalBytes;
        });
      },
      deleteOnError: true,
    ).then((_) async {
      // Save image to gallery
      if (widget.location == -1)
        final result = await ImageGallerySaver.saveFile(path);
      if (widget.location != -1) {
        WallpaperManager.setWallpaperFromFile(path, widget.location);
      }
      Navigator.pop(context);
    });
  }

  Future<String> _getFilePath(String filename) async {
    final downloadsDirectory = await getExternalStorageDirectory();
    final filePath = p.join(downloadsDirectory!.path, filename);
    return filePath;
  }

  Future<void> _requestStoragePermission() async {
    PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      startDownloading();
    } else if (status.isDenied || !status.isGranted) {
      setState(() {
        showErrorDialog = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _requestStoragePermission();
  }

  @override
  Widget build(BuildContext context) {
    if (showErrorDialog) {
      return AlertDialog(
        backgroundColor: Colors.black,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Permission Denied',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Storage permission not found.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    String downloadingProgress = (progress * 100).toInt().toString();

    return AlertDialog(
      backgroundColor: Colors.black,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator.adaptive(),
          SizedBox(height: 20),
          Text(
            widget.location == -1
                ? "Downloading: $downloadingProgress%"
                : "Setting Wallpaper",
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
}
