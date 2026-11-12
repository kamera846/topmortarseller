import 'package:flutter/material.dart';
import 'package:topmortarseller/model/contact_model.dart';
import 'package:topmortarseller/screen/auth_screen.dart';
import 'package:topmortarseller/services/live_chat_api.dart';
import 'package:topmortarseller/services/live_chat_service.dart';
import 'package:topmortarseller/util/auth_settings.dart';
import 'package:topmortarseller/util/colors/color.dart';

/// Prepares the chat session before the native chat screen is presented.
class LiveChatScreen extends StatefulWidget {
  const LiveChatScreen({super.key, this.openChat, this.signInAgain});

  /// Allows the connection flow to be tested without opening a native screen.
  final Future<void> Function({bool Function()? isActive})? openChat;

  /// Tests can replace the login transition without opening the full auth flow.
  final Future<void> Function()? signInAgain;

  @override
  State<LiveChatScreen> createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends State<LiveChatScreen> {
  bool _isConnecting = true;
  bool _requestInProgress = false;
  bool _isLeaving = false;
  bool _isSigningIn = false;
  bool _requiresLogin = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _connect());
  }

  bool _isActive() {
    return mounted &&
        !_isLeaving &&
        (ModalRoute.of(context)?.isCurrent ?? false);
  }

  Future<void> _connect() async {
    if (!_isActive() || _requestInProgress) return;
    _requestInProgress = true;
    setState(() {
      _isConnecting = true;
      _errorMessage = null;
      _requiresLogin = false;
    });

    try {
      final openChat = widget.openChat ?? LiveChatService.instance.openChat;
      await openChat(isActive: _isActive);
      // The native screen now owns the conversation. Returning removes the
      // waiting page so closing chat brings the customer back to their task.
      if (mounted && _isActive()) await Navigator.of(context).maybePop();
    } on LiveChatException catch (error) {
      if (!_isActive()) return;
      setState(() {
        _isConnecting = false;
        _errorMessage = error.message;
        _requiresLogin = error.requiresLogin;
      });
    } catch (_) {
      if (!_isActive()) return;
      setState(() {
        _isConnecting = false;
        _errorMessage =
            'Chat belum dapat dibuka. Periksa koneksi internet Anda, lalu coba lagi.';
      });
    } finally {
      _requestInProgress = false;
    }
  }

  void _goBack() {
    if (_isSigningIn) return;
    _isLeaving = true;
    Navigator.of(context).maybePop();
  }

  Future<void> _signInAgain() async {
    if (!_isActive() || _isSigningIn) return;
    setState(() => _isSigningIn = true);
    try {
      final signInAgain = widget.signInAgain;
      if (signInAgain != null) {
        await signInAgain();
      } else {
        await removeLoginState();
        await removeContactModel();
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthScreen()),
          (_) => false,
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Halaman masuk belum dapat dibuka. Silakan coba lagi.';
      });
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: !_isSigningIn,
      child: Scaffold(
        backgroundColor: cWhite,
        appBar: AppBar(
          title: const Text('Chat CS'),
          leading: IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: _isSigningIn ? null : _goBack,
            icon: const BackButtonIcon(),
          ),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: (constraints.maxHeight - 48).clamp(
                      0,
                      double.infinity,
                    ),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF9E9E7),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isConnecting
                                  ? Icons.support_agent_rounded
                                  : Icons.chat_bubble_outline_rounded,
                              color: cPrimary100,
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Semantics(
                            liveRegion: true,
                            child: Column(
                              children: [
                                Text(
                                  _isConnecting
                                      ? 'Menghubungkan ke tim CS'
                                      : 'Chat belum dapat dibuka',
                                  textAlign: TextAlign.center,
                                  style: textTheme.titleLarge?.copyWith(
                                    color: cDark100,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _errorMessage ??
                                      'Sebentar, kami sedang menyiapkan ruang chat Anda.',
                                  textAlign: TextAlign.center,
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: cDark200,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          if (_isConnecting)
                            const CircularProgressIndicator.adaptive(
                              semanticsLabel: 'Menyiapkan chat',
                              valueColor: AlwaysStoppedAnimation(cPrimary100),
                            )
                          else
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: _isSigningIn
                                    ? null
                                    : (_requiresLogin
                                          ? _signInAgain
                                          : _connect),
                                icon: _isSigningIn
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Icon(
                                        _requiresLogin
                                            ? Icons.login_rounded
                                            : Icons.refresh_rounded,
                                      ),
                                label: Text(
                                  _isSigningIn
                                      ? 'Menyiapkan…'
                                      : (_requiresLogin
                                            ? 'Masuk kembali'
                                            : 'Coba lagi'),
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: cPrimary100,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(48, 48),
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: _isSigningIn ? null : _goBack,
                            style: TextButton.styleFrom(
                              foregroundColor: cPrimary100,
                              minimumSize: const Size(88, 48),
                            ),
                            child: Text(_isConnecting ? 'Batal' : 'Kembali'),
                          ),
                          if (_isConnecting) ...[
                            const SizedBox(height: 24),
                            Text(
                              'Bantuan seputar pesanan, produk, dan pembayaran.',
                              textAlign: TextAlign.center,
                              style: textTheme.bodySmall?.copyWith(
                                color: cDark200,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
