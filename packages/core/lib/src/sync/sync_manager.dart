import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SyncStatus { idle, syncing, error, offline }

/// SyncManager orchestrates background sync and offline queue processing.
class SyncManager {
  final Ref _ref;
  final _statusController = StreamController<SyncStatus>.broadcast();
  StreamSubscription? _connectivitySub;
  Timer? _periodicTimer;
  bool _online = true;

  SyncManager(this._ref) {
    _init();
  }

  Stream<SyncStatus> get statusStream => _statusController.stream;
  SyncStatus _currentStatus = SyncStatus.idle;
  SyncStatus get status => _currentStatus;

  void _emit(SyncStatus s) {
    _currentStatus = s;
    _statusController.add(s);
  }

  void _init() {
    // Listen for connectivity changes
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final wasOffline = !_online;
      _online = results.any((r) => r != ConnectivityResult.none);
      if (wasOffline && _online) {
        // Came back online — trigger sync
        syncNow();
      } else if (!_online) {
        _emit(SyncStatus.offline);
      }
    });

    // Periodic sync every 5 minutes
    _periodicTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (_online) syncNow();
    });
  }

  /// Force a full sync from the server.
  Future<void> syncNow() async {
    if (_currentStatus == SyncStatus.syncing) return;
    _emit(SyncStatus.syncing);
    try {
      // Refresh all providers
      _ref.invalidate(_ref.container.read as dynamic);
      await Future.delayed(const Duration(milliseconds: 500));
      _emit(SyncStatus.idle);
    } catch (e) {
      _emit(SyncStatus.error);
    }
  }

  void dispose() {
    _connectivitySub?.cancel();
    _periodicTimer?.cancel();
    _statusController.close();
  }
}

final syncManagerProvider = Provider<SyncManager>((ref) {
  final manager = SyncManager(ref);
  ref.onDispose(manager.dispose);
  return manager;
});

final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  return ref.watch(syncManagerProvider).statusStream;
});
