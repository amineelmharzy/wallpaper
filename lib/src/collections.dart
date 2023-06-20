import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'collections.dart';
import 'favorite.dart';
import 'drawer.dart';
import 'viewimage.dart';
import 'buttomNarbar.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../main.dart';

class Collection extends StatefulWidget {
  final JsonFileManager jsonFileManager;

  const Collection({super.key, required this.jsonFileManager});
  @override
  State<Collection> createState() => _CollectionState();
}

class _CollectionState extends State<Collection> {
  int currentIndex = 0;
  List<String> images = [
    "https://images.pexels.com/photos/1770809/pexels-photo-1770809.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
    "https://images.pexels.com/photos/3473541/pexels-photo-3473541.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
    "https://images.pexels.com/photos/2255564/pexels-photo-2255564.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
    "https://images.pexels.com/photos/2559484/pexels-photo-2559484.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
    "https://images.pexels.com/photos/1274260/pexels-photo-1274260.jpeg?auto=compress&cs=tinysrgb&w=1600",
    "https://images.pexels.com/photos/333525/pexels-photo-333525.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2"
  ];

  List<String> titles = ["Nature", "Dark", "Animal", "Sky", "Space", "Travel"];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading delay
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Collections",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Menu(
          currentIndex: 1,
          jsonFileManager: widget.jsonFileManager,
        ),
      ),
      body: Stack(
        children: [
          if (isLoading)
            Center(
                child: CircularProgressIndicator(
              color: Colors.indigo[600],
            ))
          else
            Container(
              margin: EdgeInsets.all(12),
              child: StaggeredGridView.countBuilder(
                crossAxisCount: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 12,
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Homepage(
                              searchValue: titles[index],
                            ),
                          ),
                        );
                      },
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(0, 0, 0, 0),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                            ),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              child: FadeInImage.memoryNetwork(
                                placeholder: kTransparentImage,
                                image: images[index],
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 50,
                            left: 4,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Container(
                                color: Color.fromRGBO(0, 0, 0, 0.5),
                                padding: EdgeInsets.all(4.0),
                                child: Text(
                                  titles[index],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ));
                },
                staggeredTileBuilder: (index) {
                  return StaggeredTile.count(1, index.isEven ? 0.3 : 0.35);
                },
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomBottomNavigationBar(
                currentIndex: 1,
                onTabTapped: (int index) {
                  if (index == 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Homepage(),
                      ),
                    );
                  }
                  if (index == 2) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Favorite(
                          jsonFileManager: widget.jsonFileManager,
                        ),
                      ),
                    );
                  }
                }),
          ),
        ],
      ),
    );
  }
}
