import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class JsonFileManager {
  Future<File> getJsonFile() async {
    Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    String filePath = '${appDocumentsDir.path}/data.json';
    File file = File(filePath);
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    return file;
  }

  Future<List<String>> readJsonData() async {
    File file = await getJsonFile();
    String jsonData = await file.readAsString();
    if (jsonData.isNotEmpty) {
      List<dynamic> jsonDataList = json.decode(jsonData);
      return jsonDataList.map((item) => item.toString()).toList();
    }
    return [];
  }

  Future<void> writeJsonData(List<String> jsonDataList) async {
    File file = await getJsonFile();
    String jsonData = json.encode(jsonDataList);
    await file.writeAsString(jsonData);
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final JsonFileManager jsonFileManager = JsonFileManager();
  List<String> jsonDataList = [];

  @override
  void initState() {
    super.initState();
    readJsonData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('My App'),
        ),
        body: Center(
          child: jsonDataList.isEmpty
              ? CircularProgressIndicator()
              : ListView.builder(
                  itemCount: jsonDataList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(jsonDataList[index]),
                    );
                  },
                ),
        ),
      ),
    );
  }

  void readJsonData() async {
    List<String> data = await jsonFileManager.readJsonData();
    setState(() {
      jsonDataList = data;
    });
  }

  void writeJsonData() async {
    List<String> data = ['Item 1', 'Item 2', 'Item 3'];
    await jsonFileManager.writeJsonData(data);
    setState(() {
      jsonDataList = data;
    });
    print('JSON data written to file.');
  }
}