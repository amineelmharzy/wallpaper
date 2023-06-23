import 'dart:async';
import 'dart:io';
import 'package:alex/src/buttomNarbar.dart';
import 'package:alex/src/collections.dart';
import 'package:alex/src/drawer.dart';
import 'package:alex/src/favorite.dart';
import 'package:alex/src/viewimage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';

const String pexelsApiKey =
    'nhyaYthSvv68nZ0kf1YACx7L5u2FyuR98m8ekRfttnO4Y0W4J0Ix4wJT';

List<String> favorites = [];
int counter = 0;

class PexelsApiClient {
  static const String _baseUrl = 'https://api.pexels.com/v1';

  Future<List<String>> searchPhotos(String query,
      {int perPage = 20, int page = 1}) async {
    final url =
        Uri.parse('$_baseUrl/search?query=$query&per_page=$perPage&page=$page');
    final response =
        await http.get(url, headers: {'Authorization': pexelsApiKey});

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final photos = jsonBody['photos'] as List<dynamic>;

      return photos
          .map((photo) => photo['src']['large2x'])
          .cast<String>()
          .toList();
    } else {
      throw Exception('Failed to search for photos');
    }
  }
}

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

  Future<void> deleteJsonData(List<String> jsonDataList, String url) async {
    jsonDataList.remove(url);
    File file = await getJsonFile();
    String jsonData = json.encode(jsonDataList);
    await file.writeAsString(jsonData);
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'opensans'),
      home: SplashScreen(),
      routes: {
        '/home': (context) => Homepage(),
      },
      debugShowCheckedModeBanner: false,
      builder: (BuildContext context, Widget? child) {
        return WillPopScope(
          onWillPop: () async {
            if (Navigator.of(context).userGestureInProgress) {
              return true;
            } else {
              Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
              return false;
            }
          },
          child: child!,
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      // Navigate to the main application screen after the delay
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set your desired background color
      body: Center(
        child: FlutterLogo(
            size: 150), // Replace this with your own splash screen UI
      ),
    );
  }
}

class Homepage extends StatefulWidget {
  final String searchValue;

  Homepage({this.searchValue = "nature"});

  @override
  _HomepageState createState() => _HomepageState(this.searchValue);
}

class _HomepageState extends State<Homepage> {
  final PexelsApiClient pexelsApiClient = PexelsApiClient();
  final JsonFileManager jsonFileManager = JsonFileManager();

  List<String> _apiImages = [];
  int currentPage = 1;
  bool isLoading = false;
  late String searchValue;
  ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;

  _HomepageState(this.searchValue);

  void readJsonData() async {
    List<String> data = await jsonFileManager.readJsonData();
    setState(() {
      favorites = data;
    });
  }

  void writeJsonData(String url) async {
    List<String> data = favorites;
    await jsonFileManager.writeJsonData(data);
    setState(() {
      favorites = data;
    });
  }

  void deleteJsonData(String url) async {
    List<String> data = favorites.remove(url) as List<String>;
    await jsonFileManager.writeJsonData(data);
    setState(() {
      favorites = data;
    });
  }

  // void _createInterstitialAd() {
  //   InterstitialAd.load(
  //       adUnitId: "ca-app-pub-2084763273619512/7767818268",
  //       request: AdRequest(),
  //       adLoadCallback: InterstitialAdLoadCallback(
  //         onAdLoaded: (InterstitialAd ad) {
  //           print('$ad loaded');
  //           _interstitialAd = ad;
  //           _interstitialAd!.setImmersiveMode(true);
  //         },
  //         onAdFailedToLoad: (LoadAdError error) {
  //           print('InterstitialAd failed to load: $error.');
  //         },
  //       ));
  // }

  // void _showInterstitialAd() {
  //   if (_interstitialAd == null) {
  //     print('Warning: attempt to show interstitial before loaded.');
  //     return;
  //   }
  //   _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
  //     onAdShowedFullScreenContent: (InterstitialAd ad) =>
  //         print('ad onAdShowedFullScreenContent.'),
  //     onAdDismissedFullScreenContent: (InterstitialAd ad) {
  //       print('$ad onAdDismissedFullScreenContent.');
  //       ad.dispose();
  //       _createInterstitialAd();
  //     },
  //     onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
  //       print('$ad onAdFailedToShowFullScreenContent: $error');
  //       ad.dispose();
  //       _createInterstitialAd();
  //     },
  //   );
  //   _interstitialAd!.show();
  //   _interstitialAd = null;
  // }

  Future<InitializationStatus> _initGoogleMobileAds() {
    // TODO: Initialize Google Mobile Ads SDK
    return MobileAds.instance.initialize();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    readJsonData();
    fetchPexelsImages();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        fetchPexelsImages();
      }
    });
    BannerAd(
      adUnitId: 'ca-app-pub-2084763273619512/9437528124',
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    ).load();
    // _createInterstitialAd();
  }

  Future<void> fetchPexelsImages() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final images = await pexelsApiClient.searchPhotos(searchValue,
          page: currentPage, perPage: 20);

      setState(() {
        if (currentPage == 1) {
          _apiImages =
              images; // Replace the existing images with the new ones for the first page
        } else {
          _apiImages.addAll(
              images); // Append images to the existing list for subsequent pages
        }
        currentPage++;
        isLoading = false;
      });
    } catch (error) {
      print('Error fetching images: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    if (value.isEmpty) {
      value = "nature";
    }
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchImages(value);
    });
  }

  Future<void> searchImages(String query) async {
    if (isLoading) return;

    setState(() {
      if (query.isEmpty) {
        searchValue = "nature";
      } else {
        searchValue = query;
      }
      isLoading = true;
      _apiImages.clear();
      currentPage = 1;
    });

    try {
      final images = await pexelsApiClient.searchPhotos(query, perPage: 20);
      setState(() {
        _apiImages = images;
        isLoading = false;
      });
    } catch (error) {
      print('Error searching images: $error');
      setState(() {
        isLoading = false;
      });
    }
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
          "Home",
          // style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      drawer: Drawer(
        child: Menu(currentIndex: 0, jsonFileManager: jsonFileManager),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    height: 50,
                    margin: EdgeInsets.only(top: 10, left: 20, right: 20),
                    child: CupertinoTextField(
                      prefix: Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(
                          CupertinoIcons.search,
                          color: Colors.grey,
                        ),
                      ),
                      placeholder: 'Search',
                      style: TextStyle(fontSize: 18.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      onChanged: _onSearchChanged,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(12),
                      child: GridView.builder(
                        controller: _scrollController,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 12,
                          childAspectRatio:
                              0.7, // Adjust this value to increase or decrease height
                        ),
                        itemCount: _apiImages.length,
                        itemBuilder: (BuildContext context, int index) {
                          final imageUrl = _apiImages[index];

                          return GestureDetector(
                            onTap: () {
                              // _showInterstitialAd();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewImage(
                                    url: imageUrl,
                                    jsonFileManager: jsonFileManager,
                                  ),
                                  // builder: (context) => viewImage(url: imageUrl),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15.0),
                                ),
                                image: DecorationImage(
                                  image: CachedNetworkImageProvider(imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  if (isLoading)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
              if (_apiImages.isEmpty && !isLoading)
                Center(
                  child: Text(
                    'No images found',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Your content here
                        ],
                      ),
                    ),
                  ),
                  if (_bannerAd != null)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: _bannerAd!.size.width.toDouble(),
                        height: _bannerAd!.size.height.toDouble(),
                        child: AdWidget(ad: _bannerAd!),
                      ),
                    ),
                  CustomBottomNavigationBar(
                    currentIndex: 0,
                    onTabTapped: (int index) {
                      if (index == 1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Collection(
                              jsonFileManager: jsonFileManager,
                            ),
                          ),
                        );
                      }
                      if (index == 2) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Favorite(
                              jsonFileManager: jsonFileManager,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
