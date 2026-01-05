import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import 'combine_dashboard.dart';

class WebViewAuthScreen extends StatefulWidget {
  final String authorizationUrl;
  final String state;

  const WebViewAuthScreen({
    super.key,
    required this.authorizationUrl,
    required this.state,
  });

  @override
  State<WebViewAuthScreen> createState() => _WebViewAuthScreenState();
}

class _WebViewAuthScreenState extends State<WebViewAuthScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;
  Timer? _pollingTimer;
  int _pollingAttempts = 0;
  bool _authCompleted = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
    // Start polling immediately - just like React does
    _startPolling();
  }

  void _initWebView() {
    debugPrint('🔗 Loading authorization URL: ${widget.authorizationUrl}');

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            debugPrint('📄 Page started: $url');
            setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            debugPrint('✅ Page finished: $url');
            setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            debugPrint('❌ WebView error: ${error.description}');
            // Don't show error for cancelled navigations or custom schemes
            if (error.errorCode != -999 && error.errorCode != -1) {
              // Only show error if it's not related to mplocker:// scheme
              if (error.url == null || !error.url!.startsWith('mplocker://')) {
                setState(() {
                  _error = error.description;
                  _isLoading = false;
                });
              }
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authorizationUrl));
  }

  void _startPolling() {
    debugPrint('🔄 Starting session polling...');
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      const Duration(milliseconds: AppConstants.sessionPollingIntervalMs),
      (_) => _pollSessionStatus(),
    );
  }

  Future<void> _pollSessionStatus() async {
    if (_authCompleted) {
      _pollingTimer?.cancel();
      return;
    }

    _pollingAttempts++;
    // debugPrint('🔍 Polling attempt $_pollingAttempts/${AppConstants.maxPollingAttempts}');

    if (_pollingAttempts > AppConstants.maxPollingAttempts) {
      _pollingTimer?.cancel();
      if (mounted) {
        setState(() {
          _error = 'Authentication timed out. Please try again.';
        });
      }
      return;
    }

    try {
      final authProvider = context.read<AuthProvider>();
      final status = await authProvider.apiService.getSessionStatus(widget.state);

      debugPrint('📊 Session status: completed=${status.completed}, hasToken=${status.token != null}, hasUserId=${status.userId != null}');

      if (status.completed && status.token != null && status.userId != null) {
        debugPrint('🎉 Authentication successful!');
        _authCompleted = true;
        _pollingTimer?.cancel();

        await authProvider.completeAuthentication(
          token: status.token!,
          userId: status.userId!,
          name: status.name,
          email: status.email,
        );

        if (mounted) {
         // Navigator.pop(context, true);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CombinedDashboard(isLoggedIn: true),
            ),
          );
        }
      }
    } catch (e) {
      // Continue polling on error, might be temporary
      debugPrint('⚠️ Polling error (will retry): $e');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CombinedDashboard(isLoggedIn: false),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign in with DigiLocker'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, false),
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: _error != null
          ? _buildErrorView()
          : Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Authentication Error',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'An unknown error occurred',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _error = null;
                      _isLoading = true;
                      _authCompleted = false;
                      _pollingAttempts = 0;
                    });
                    _controller.loadRequest(Uri.parse(widget.authorizationUrl));
                    _startPolling();
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
