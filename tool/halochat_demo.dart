// Isolated debug entry point: no seller account or production API required.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:topmortarseller/services/halochat_service.dart';
import 'package:topmortarseller/util/auth_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kDebugMode || !HaloChatService.isDemo) {
    throw StateError(
      'This preview requires a debug build with HALOCHAT_MODE=demo.',
    );
  }
  // Mock preferences are in-memory: never replace a real user's saved login.
  // This standalone manual test harness intentionally uses the test-only store.
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues({});
  await saveLoginState('08000000000', 'demo-only-not-a-real-password');
  runApp(const MaterialApp(home: _DemoPreview()));
}

class _DemoPreview extends StatefulWidget {
  const _DemoPreview();
  @override
  State<_DemoPreview> createState() => _DemoPreviewState();
}

class _DemoPreviewState extends State<_DemoPreview> {
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _open());
  }

  Future<void> _open() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await HaloChatService.openChat();
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is PlatformException
              ? error.message
              : 'Demo belum dapat dibuka.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Preview HaloChat — Demo')),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Percakapan contoh lokal. Tidak menghubungi backend toko atau CS sungguhan.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _busy ? null : _open,
              child: Text(_busy ? 'Membuka…' : 'Buka Chat Demo'),
            ),
            TextButton(
              onPressed: _busy
                  ? null
                  : () async {
                      setState(() => _busy = true);
                      await HaloChatService.clearUser();
                      if (mounted) await _open();
                    },
              child: const Text('Reset percakapan demo'),
            ),
          ],
        ),
      ),
    ),
  );
}
