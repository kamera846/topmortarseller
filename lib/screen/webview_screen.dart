import 'package:flutter/material.dart';
import 'package:topmortarseller/widget/snackbar/show_snackbar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewScreen extends StatefulWidget {
  final String? contentUrl;
  final Map<String, String>? contentHeaders;
  const WebviewScreen({
    super.key,
    required this.contentUrl,
    this.contentHeaders,
  });

  @override
  State<WebviewScreen> createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {
  final controller = WebViewController();
  double loadProgress = 0;
  bool isLoading = true;
  bool isValidUri = true;

  @override
  void initState() {
    super.initState();
    final uri = Uri.tryParse(widget.contentUrl ?? '');

    setState(() {
      isValidUri =
          uri != null &&
          (uri.isScheme('http') || uri.isScheme('https')) &&
          uri.isAbsolute;
    });

    if (isValidUri) {
      controller
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (progress) {
              double calculateProgress = progress / 100;
              if (calculateProgress < 0) calculateProgress = 0.0;
              if (calculateProgress > 100) calculateProgress = 1.0;
              setState(() {
                loadProgress = calculateProgress;
              });
            },
            onPageStarted: (url) {
              setState(() {
                isLoading = true;
              });
            },
            onPageFinished: (url) {
              setState(() {
                isLoading = false;
              });
            },
            onHttpError: (error) {
              showSnackBar(context, "Failed load url. Error $error");
            },
            onWebResourceError: (error) {
              showSnackBar(context, "Failed load web resources. Error $error");
            },
            onNavigationRequest: (request) {
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(
          Uri.parse(widget.contentUrl!),
          headers: widget.contentHeaders != null ? widget.contentHeaders! : {},
        );
    } else {
      setState(() {
        isLoading = false;
        loadProgress = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("MyTop Seller Webview")),
      body: !isLoading
          ? isValidUri
                ? WebViewWidget(controller: controller)
                : Center(
                    child: Text(
                      'The target url "${widget.contentUrl}" is not valid.',
                    ),
                  )
          : Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator.adaptive(),
                  const SizedBox(width: 8),
                  Text("Memuat ${loadProgress * 100} %"),
                ],
              ),
            ),
    );
  }
}
