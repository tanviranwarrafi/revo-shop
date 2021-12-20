import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nyoba/services/Session.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CheckoutWebView extends StatefulWidget {
  final url;
  final Future<dynamic> Function() onFinish;
  final bool fromOrder;

  CheckoutWebView({Key key, this.url, this.onFinish, this.fromOrder = false}) : super(key: key);

  @override
  CheckoutWebViewState createState() => CheckoutWebViewState();
}

class CheckoutWebViewState extends State<CheckoutWebView> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  WebViewController _webViewController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      snackBar(context, color: Colors.red, message: 'Could not launch $url');
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(!widget.fromOrder ? 'Checkout Order' : 'Payment Order', style: TextStyle(color: Colors.black)),
          leading: IconButton(
            color: Colors.black,
            onPressed: () => Navigator.pop(context),
            icon: Platform.isIOS ? Icon(Icons.arrow_back_ios) : Icon(Icons.arrow_back),
          ),
        ),
        body: Stack(
          children: [
            WebView(
              initialUrl: widget.url,
              javascriptMode: JavascriptMode.unrestricted,
              onProgress: (int progress) {
                print("WebView is loading (progress : $progress%)");
                progress != 100 ? setState(() => isLoading = true) : setState(() => isLoading = false);
                _webViewController.evaluateJavascript("document.getElementById('headerwrap').style.display= 'none';");
                _webViewController.evaluateJavascript("document.getElementById('footerwrap').style.display= 'none';");
                _webViewController.evaluateJavascript("document.getElementsByTagName('header')[0].style.display= 'none';");
                _webViewController.evaluateJavascript("document.getElementsByTagName('footer')[0].style.display= 'none';");
                _webViewController.evaluateJavascript("document.getElementsByClassName('return-to-shop')[0].style.display= 'none';");
                _webViewController.evaluateJavascript("document.getElementsByClassName('page-title')[0].style.display= 'none';");
                _webViewController.evaluateJavascript("document.getElementsByClassName('woocommerce-error')[0].style.display= 'none';");
                _webViewController
                    .evaluateJavascript("document.getElementsByClassName('woocommerce-breadcrumb')[0].style.display= 'none';");
                _webViewController.evaluateJavascript("document.getElementsByClassName('entry-title')[0].style.display= 'none';");
              },
              onWebViewCreated: (WebViewController webViewController) {
                _webViewController = webViewController;
                _controller.complete(webViewController);
              },
              navigationDelegate: (NavigationRequest request) {
                if (request.url.startsWith('gojek:')) {
                  print('blocking navigation to $request}');
                  _launchUrl(request.url);
                  return NavigationDecision.prevent;
                }
                if (request.url.contains("/checkout/order-received/")) {
                  final items = request.url.split("/checkout/order-received/");
                  if (items.length > 1) {
                    final number = items[1].split("/")[0];
                    Session.data.setString('order_number', number);
                  }
                  if (!widget.fromOrder) {
                    widget.onFinish();
                  } else {
                    Navigator.pop(context, '200');
                    snackBar(context, color: Colors.green, message: 'Payment Success');
                  }
                  return NavigationDecision.prevent;
                }
                print('allowing navigation to $request');
                return NavigationDecision.navigate;
              },
              onPageStarted: (String url) {
                print('Page started loading: $url');
              },
              onPageFinished: (String url) {
                print('Page finished loading: $url');
                _webViewController.evaluateJavascript("document.getElementById('headerwrap').style.display= 'none';");
                _webViewController.evaluateJavascript("document.getElementById('footerwrap').style.display= 'none';");
                _webViewController.evaluateJavascript("document.getElementsByTagName('header')[0].style.display= 'none';");
                _webViewController.evaluateJavascript("document.getElementsByTagName('footer')[0].style.display= 'none';");
                _webViewController.evaluateJavascript("document.getElementsByClassName('return-to-shop')[0].style.display= 'none';");
                _webViewController.evaluateJavascript("document.getElementsByClassName('page-title')[0].style.display= 'none';");
                _webViewController.evaluateJavascript("document.getElementsByClassName('woocommerce-error')[0].style.display= 'none';");
                _webViewController
                    .evaluateJavascript("document.getElementsByClassName('woocommerce-breadcrumb')[0].style.display= 'none';");
                _webViewController.evaluateJavascript("document.getElementsByClassName('entry-title')[0].style.display= 'none';");
              },
              gestureNavigationEnabled: true,
            ),
            isLoading ? Center(child: customLoading()) : Stack()
          ],
        ));
  }
}
