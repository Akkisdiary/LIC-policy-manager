import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  static const routeName = '/WebViewScreen';

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculator'),
      ),
      body: WebView(
        initialUrl: 'https://ebiz.licindia.in/D2CPM/#qni/basicinfo',
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
