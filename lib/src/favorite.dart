import 'package:alex/src/collections.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'drawer.dart';
import 'viewimage.dart';
import 'buttomNarbar.dart';
import 'package:transparent_image/transparent_image.dart';
import '../main.dart';

class Favorite extends StatefulWidget {
  final JsonFileManager jsonFileManager;

  const Favorite({super.key, required this.jsonFileManager});

  @override
  State<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  int currentIndex = 0;
  bool isLoading = true;
  bool hasInternet = true; // Replace with your internet connectivity logic

  @override
  void initState() {
    super.initState();
    // Simulate loading delay
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        isLoading = false;
      });
    });

    Connectivity().checkConnectivity().then((connectivityResult) {
      setState(() {
        hasInternet =
            connectivityResult != ConnectivityResult.none ? true : false;
      });
    });

    // Subscribe to internet connectivity changes
    Connectivity().onConnectivityChanged.listen((connectivityResult) {
      setState(() {
        hasInternet =
            connectivityResult != ConnectivityResult.none ? true : false;
      });
    });
  }

  Future<void> _refreshData() async {
    // Simulate loading delay
    await Future.delayed(Duration(milliseconds: 1000));
    setState(() {
      // Refresh the data here
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Favorite",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Menu(
          currentIndex: 2,
          jsonFileManager: widget.jsonFileManager,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Stack(
          children: [
            if (isLoading)
              Center(
                child: CircularProgressIndicator(
                  color: Colors.indigo[600],
                ),
              )
            else if (!hasInternet || favorites.isEmpty)
              Center(
                child: Text(
                  !hasInternet ? 'No internet connection' : "No Favorites",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Container(
                margin: EdgeInsets.all(12),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // Handle tap event
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewImage(
                              url: favorites[index],
                              jsonFileManager: widget.jsonFileManager,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                          child: FadeInImage.memoryNetwork(
                            placeholder: kTransparentImage,
                            image: favorites[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CustomBottomNavigationBar(
                currentIndex: 2,
                onTabTapped: (int index) {
                  if (index == 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Homepage(),
                      ),
                    );
                  }
                  if (index == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Collection(
                          jsonFileManager: widget.jsonFileManager,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
