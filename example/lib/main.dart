import 'package:flutter/material.dart';
import 'package:network_state/network_state.dart';

void main() {
  NetworkConfig.pingUrls = ['http://mockbin.com/request'];
  NetworkConfig.pollIntervalMs = 500;
  NetworkConfig.timeoutMs = 2000;

  NetworkState.startPolling();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Network State Demo',
      home: Scaffold(
        body: NetworkStateBuilder(
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            return Center(
              child: Text(
                snapshot.hasData
                    ? 'Has connection: ${snapshot.data}'
                    : 'Loading...',
              ),
            );
          },
        ),
      ),
    );
  }
}
