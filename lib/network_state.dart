import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class NetworkConfig {
  static List<String> pingUrls;
  static int pollIntervalMs = 500;
  static int timeoutMs = 500;
}

class NetworkState with ChangeNotifier {
  static NetworkState _instance;
  static http.Client _client;
  bool _hasConnection;
  Completer<bool> _initialNetworkTestCompleter;

  static bool _isPolling = false;
  factory NetworkState() => _instance ??= new NetworkState._internal();

  NetworkState._internal() {
    _client = new http.Client();
    _initialNetworkTestCompleter = new Completer();
  }

  Future<bool> get isConnected async {
    await _initialNetworkTestCompleter.future;
    return _hasConnection;
  }

  setHasConnection(bool c) {
    _hasConnection = c;

    if (!_initialNetworkTestCompleter.isCompleted) {
      _initialNetworkTestCompleter.complete();
    }

    notifyListeners();
  }

  static startPolling() {
    if (_isPolling) {
      return;
    }

    assert(NetworkConfig.pingUrls != null);
    assert(NetworkConfig.pingUrls.length > 0);

    _isPolling = true;

    Future.doWhile(() async {
      await _ping();

      if (!_isPolling) return _isPolling;

      await Future.delayed(
        Duration(milliseconds: NetworkConfig.pollIntervalMs),
      );

      return true;
    });
  }

  static stopPolling() {
    _isPolling = false;
    _client.close();
    _client = new http.Client();
  }

  static Future<void> _ping() async {
    dynamic result;
    final _ns = new NetworkState();

    try {
      result = await Future.any([
        Future.wait(
          NetworkConfig.pingUrls.map(
            (url) => _client.head(url),
          ),
        ),
        Future.delayed(Duration(milliseconds: NetworkConfig.timeoutMs)),
      ]);
    } on Exception {} finally {
      if (result is List<http.Response> &&
          result.every((res) => res.statusCode == 200)) {
        _ns.setHasConnection(true);
      } else {
        _client.close();
        _client = new http.Client();
        _ns.setHasConnection(false);
      }
    }
  }
}

typedef NetworkStateChildBuilder = Widget Function(
  BuildContext,
  AsyncSnapshot<bool>,
);

class NetworkStateBuilder extends StatefulWidget {
  final NetworkStateChildBuilder builder;

  NetworkStateBuilder({@required this.builder});

  @override
  _NetworkStateBuilderState createState() => _NetworkStateBuilderState();
}

class _NetworkStateBuilderState extends State<NetworkStateBuilder> {
  bool _hasConnection;
  NetworkState _ns;

  @override
  void initState() {
    _ns = new NetworkState();
    _ns.addListener(_onNetworkStateChange);
    super.initState();
  }

  _onNetworkStateChange() async {
    final isConnected = await _ns.isConnected;

    setState(() {
      _hasConnection = isConnected;
    });
  }

  @override
  void dispose() {
    _ns.removeListener(_onNetworkStateChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      _hasConnection == null
          ? AsyncSnapshot.nothing()
          : AsyncSnapshot.withData(
              ConnectionState.done,
              _hasConnection,
            ),
    );
  }
}
