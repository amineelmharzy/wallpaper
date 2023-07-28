import 'dart:async';
import 'dart:io';
import 'package:alex/src/buttomNarbar.dart';
import 'package:alex/src/collections.dart';
import 'package:alex/src/drawer.dart';
import 'package:alex/src/favorite.dart';
import 'package:alex/src/viewimage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:applovin_max/applovin_max.dart';
import 'dart:math' as m;

const String pexelsApiKey =
    'nhyaYthSvv68nZ0kf1YACx7L5u2FyuR98m8ekRfttnO4Y0W4J0Ix4wJT';

List<String> favorites = [];
int icounter = 0;
int rcounter = 0;


String  banner_ad_unit_id = "248e1c93d095f543";
String  interstitial_ad_unit_id= "248e1c93d095f543";
String  rewarded_ad_unit_id = "248e1c93d095f543";

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Map? sdkConfiguration = await AppLovinMAX.initialize(
      "8N5SdrgtH5et2LBTO3iv_kVHruDvchz7Z58claQA05fwrpSUeVsemsTaMHf6o33DSH0mZlaGqpWcFamTLoUTLK");
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/app.png', // Replace 'your_image.png' with the path to your custom image
              width: 150, // Set the desired width of the image
              height: 150, // Set the desired height of the image
            ),
            SizedBox(
                height: 16), // Add some spacing between the image and the title
            Text(
              'Wallpapers', // Replace 'Your Title' with your desired title text
              style: TextStyle(
                fontSize: 24, // Set the desired font size of the title
                fontWeight:
                    FontWeight.bold, // Set the desired font weight of the title
              ),
            ),
          ],
        ),
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
  var _interstitialRetryAttempt = 0;
  var _rewardedAdRetryAttempt = 0;
  _HomepageState(this.searchValue);

// SDK is initialized, start loading ads

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

  void initializeInterstitialAds() {
    AppLovinMAX.setInterstitialListener(InterstitialListener(
      onAdLoadedCallback: (ad) {
        // Interstitial ad is ready to be shown. AppLovinMAX.isInterstitialReady(_interstitial_ad_unit_id) will now return 'true'
        print('Interstitial ad loaded from ' + ad.networkName);

        // Reset retry attempt
        _interstitialRetryAttempt = 0;
      },
      onAdLoadFailedCallback: (adUnitId, error) {
        // Interstitial ad failed to load
        // We recommend retrying with exponentially higher delays up to a maximum delay (in this case 64 seconds)
        _interstitialRetryAttempt = _interstitialRetryAttempt + 1;

        int retryDelay = m.pow(2, m.min(6, _interstitialRetryAttempt)).toInt();

        print('Interstitial ad failed to load with code ' +
            error.code.toString() +
            ' - retrying in ' +
            retryDelay.toString() +
            's');

        Future.delayed(Duration(milliseconds: retryDelay * 1000), () {
          AppLovinMAX.loadInterstitial(interstitial_ad_unit_id);
        });
      },
      onAdDisplayedCallback: (ad) {},
      onAdDisplayFailedCallback: (ad, error) {},
      onAdClickedCallback: (ad) {},
      onAdHiddenCallback: (ad) {},
    ));

    // Load the first interstitial
    AppLovinMAX.loadInterstitial(interstitial_ad_unit_id);
  }

  void initializeRewardedAds() {
    AppLovinMAX.setRewardedAdListener(RewardedAdListener(
        onAdLoadedCallback: (ad) {
          // Rewarded ad is ready to be shown. AppLovinMAX.isRewardedAdReady(_rewarded_ad_unit_id) will now return 'true'
          print('Rewarded ad loaded from ' + ad.networkName);

          // Reset retry attempt
          _rewardedAdRetryAttempt = 0;
        },
        onAdLoadFailedCallback: (adUnitId, error) {
          // Rewarded ad failed to load
          // We recommend retrying with exponentially higher delays up to a maximum delay (in this case 64 seconds)
          _rewardedAdRetryAttempt = _rewardedAdRetryAttempt + 1;

          int retryDelay = m.pow(2, m.min(6, _rewardedAdRetryAttempt)).toInt();
          print('Rewarded ad failed to load with code ' +
              error.code.toString() +
              ' - retrying in ' +
              retryDelay.toString() +
              's');

          Future.delayed(Duration(milliseconds: retryDelay * 1000), () {
            AppLovinMAX.loadRewardedAd(rewarded_ad_unit_id);
          });
        },
        onAdDisplayedCallback: (ad) {},
        onAdDisplayFailedCallback: (ad, error) {},
        onAdClickedCallback: (ad) {},
        onAdHiddenCallback: (ad) {},
        onAdReceivedRewardCallback: (ad, reward) {}));

    AppLovinMAX.loadRewardedAd(rewarded_ad_unit_id);
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
        child: Menu(
          currentIndex: 0,
          jsonFileManager: jsonFileManager, initializeRewardedAds: initializeRewardedAds,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    height: 45,
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
                            onTap: () async {
                              if (icounter == 0)
                                initializeInterstitialAds();
                              icounter++;
                              if (icounter == 5) {
                                bool isReady =
                                    (await AppLovinMAX.isInterstitialReady(
                                        interstitial_ad_unit_id))!;
                                if (isReady) {
                                  AppLovinMAX.showInterstitial(
                                      interstitial_ad_unit_id);
                                }
                                icounter = 0;
                              }
                              MaxAdView(
                                  adUnitId: interstitial_ad_unit_id,
                                  adFormat: AdFormat.mrec,
                                  listener: AdViewAdListener(
                                      onAdLoadedCallback: (ad) {},
                                      onAdLoadFailedCallback:
                                          (adUnitId, error) {},
                                      onAdClickedCallback: (ad) {},
                                      onAdExpandedCallback: (ad) {},
                                      onAdCollapsedCallback: (ad) {}));
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewImage(
                                    url: imageUrl,
                                    jsonFileManager: jsonFileManager,
                                    initializeRewardedAds: initializeRewardedAds,
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
                   Container(
                    child: MaxAdView(
                        adUnitId: banner_ad_unit_id,
                        adFormat: AdFormat.banner,
                        listener: AdViewAdListener(
                            onAdLoadedCallback: (ad) {},
                            onAdLoadFailedCallback: (adUnitId, error) {},
                            onAdClickedCallback: (ad) {},
                            onAdExpandedCallback: (ad) {},
                            onAdCollapsedCallback: (ad) {})),
                  ),
                  CustomBottomNavigationBar(
                    currentIndex: 0,
                    onTabTapped: (int index) {
                      if (index == 1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Collection(
                              jsonFileManager: jsonFileManager, initializeRewardedAds: initializeRewardedAds,
                            ),
                          ),
                        );
                      }
                      if (index == 2) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Favorite(
                              jsonFileManager: jsonFileManager, initializeRewardedAds: initializeRewardedAds,
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
