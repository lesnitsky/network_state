# network_state

Service aware network state plugin for Flutter

Sends `HEAD` requests to your service to make sure it is available

> Support me

![GitHub stars](https://img.shields.io/github/stars/lesnitsky/network_state.svg?style=social)
![Twitter Follow](https://img.shields.io/twitter/follow/lesnitsky_a.svg?label=Follow%20me&style=social)

## Motivation

Sometimes even though other packages like [connectivity](https://pub.dev/packages/connectivity) tell, that connection is OK, your WiFi may have limited network access, so you might want to make sure _your_ service is available

## Installation

`pubspec.yaml`

```yaml
dependencies:
  network_state: ^0.0.1
```

## NetworkState

```dart
NetworkState.startPolling();

final ns = new NetworkState();

ns.addListener(() async {
    final hasConnection = await ns.isConnected;
});
```

## NetworkConfig

```dart
void main() {
    NetworkConfig.pingUrls = [
        'http://yourapi.com/ping',
        'http://yourotherapi.com/ping',
    ];
    // optional poll interval, defaults to 500
    NetworkConfig.pollIntervalMs = 300;
    // optional timeout, defaults to 500
    NetworkConfig.timeoutMs = 1000;

    runApp(MyApp);
}
```

## NetworkStateBuilder

```dart
void main() {
    // ...

    NetworkState.startPolling();
    runApp(MyApp);
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
```

## License

MIT

## Support me

![GitHub stars](https://img.shields.io/github/stars/lesnitsky/network_state.svg?style=social)
![Twitter Follow](https://img.shields.io/twitter/follow/lesnitsky_a.svg?label=Follow%20me&style=social)
