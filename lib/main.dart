import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Special Vip Turkiye',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black, // Uygulamanın genel arka planı siyah olsun.
      ),
      home: WebViewExample(),
    );
  }
}

class WebViewExample extends StatefulWidget {
  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  late InAppWebViewController _webViewController;
  bool _isConnected = true;
  bool _locationPermissionGranted = false;
  late PullToRefreshController pullToRefreshController;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();

    // Pull-to-refresh controller'ı başlatıyoruz.
    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        // Platforma göre sayfayı yenileme işlemi.
        if (Platform.isAndroid) {
          _webViewController.reload();
        } else if (Platform.isIOS) {
          var currentUrl = await _webViewController.getUrl();
          _webViewController.loadUrl(
              urlRequest: URLRequest(url: currentUrl));
        }
      },
    );

    // Başlangıçta konum izni istemiyoruz; ilgili sayfaya girildiğinde isteyeceğiz.
  }

  // İnternet bağlantısını kontrol eder.
  Future<void> _checkConnectivity() async {
    final connectivity = Connectivity();
    final status = await connectivity.checkConnectivity();
    setState(() {
      _isConnected = status != ConnectivityResult.none;
    });
    connectivity.onConnectivityChanged.listen((status) {
      setState(() {
        _isConnected = status != ConnectivityResult.none;
      });
    });
  }

  // Belirli bir sayfa yüklendiğinde konum iznini ister.
  Future<void> _requestLocationPermissionIfNeeded(String url) async {
    if (url.contains("/tasiyici/specialvipturkiye") && !_locationPermissionGranted) {
      if (await Permission.location.request().isGranted) {
        setState(() {
          _locationPermissionGranted = true;
        });
        debugPrint("Konum izni verildi.");
      } else {
        debugPrint("Konum izni reddedildi veya kalıcı olarak reddedildi.");
      }
    }
  }

  // Geri tuşu kontrolü: WebView'de önceki sayfa varsa geri dön, yoksa uygulamayı kapat.
  Future<bool> _onWillPop() async {
    if (await _webViewController.canGoBack()) {
      _webViewController.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black, // Scaffold arka planı siyah.
        body: _isConnected
            ? SafeArea(
                child: Container(
                  color: Colors.black, // Container arka planı siyah.
                  child: InAppWebView(
                    initialUrlRequest: URLRequest(
                      url: WebUri('https://www.specialvipturkiye.com/'),
                    ),
                    pullToRefreshController: pullToRefreshController,
                    onLoadStart: (controller, url) {
                      if (url != null) {
                        _requestLocationPermissionIfNeeded(url.toString());
                      }
                    },
                    onLoadStop: (controller, url) async {
                      pullToRefreshController.endRefreshing();
                    },
                    onLoadError: (controller, url, code, message) {
                      pullToRefreshController.endRefreshing();
                    },
                    androidOnGeolocationPermissionsShowPrompt:
                        (InAppWebViewController controller, String origin) async {
                      return GeolocationPermissionShowPromptResponse(
                          origin: origin, allow: true, retain: true);
                    },
                    initialOptions: InAppWebViewGroupOptions(
                      android: AndroidInAppWebViewOptions(
                        useWideViewPort: true,
                        geolocationEnabled: true,
                      ),
                      ios: IOSInAppWebViewOptions(
                        allowsInlineMediaPlayback: true,
                        allowsAirPlayForMediaPlayback: true,
                        allowsBackForwardNavigationGestures: true,
                        allowsLinkPreview: true,
                      ),
                    ),
                    onWebViewCreated: (controller) {
                      _webViewController = controller;
                    },
                  ),
                ),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.wifi_off,
                            size: 50,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            "İnternet bağlantısı yok!",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _checkConnectivity,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              "Tekrar Dene",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
