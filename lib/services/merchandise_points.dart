import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:topmortarseller/services/point_api.dart';
import 'package:topmortarseller/util/enum.dart';

/// Shared by the catalog and detail so neither can redeem against an old total.
class MerchandisePoints extends ChangeNotifier {
  MerchandisePoints({required this.idContact, this.onChanged});

  final String idContact;
  final ValueChanged<int?>? onChanged;
  int? total;
  bool isLoading = false;
  bool _disposed = false;
  int _revision = 0;
  Future<void>? _pending;

  String get _cacheKey => '$idContact-${GlobalEnum.savedTotalPoint}';

  Future<void> refresh() {
    if (_pending != null) return _pending!;
    late final Future<void> pending;
    pending = _load().whenComplete(() {
      if (identical(_pending, pending)) _pending = null;
    });
    _pending = pending;
    return pending;
  }

  Future<void> _load() async {
    final revision = ++_revision;
    isLoading = true;
    notifyListeners();
    bool success = false;
    final value = await PointApi.total(
      idContact: idContact,
      onSuccess: (_) => success = true,
      onCompleted: (_) {},
    );
    if (_disposed || revision != _revision) return;
    total = success ? value : null;
    isLoading = false;
    onChanged?.call(total);
    notifyListeners();
    await _save(total, revision);
  }

  /// A successful redeem invalidates the old balance, even if refresh fails.
  Future<void> invalidate() async {
    final revision = ++_revision;
    total = null;
    isLoading = false;
    _pending = null;
    onChanged?.call(null);
    notifyListeners();
    await _save(null, revision);
  }

  Future<void> _save(int? value, int revision) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_disposed || revision != _revision) return;
      if (value == null) {
        await prefs.remove(_cacheKey);
      } else {
        await prefs.setInt(_cacheKey, value);
      }
    } catch (error) {
      // Local persistence must not turn a completed redeem into a failure.
      debugPrint('Unable to cache point balance: $error');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
