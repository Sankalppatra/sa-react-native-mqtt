# sa-react-native-mqtt

[![npm version](https://img.shields.io/npm/v/sa-react-native-mqtt.svg)](https://www.npmjs.com/package/sa-react-native-mqtt)
[![npm downloads](https://img.shields.io/npm/dt/sa-react-native-mqtt.svg)](https://www.npmjs.com/package/sa-react-native-mqtt)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/your-repo/sa-react-native-mqtt/pulls)

> MQTT client for React Native with new architecture support

---

## Features

- 📱 Works on both iOS and Android
- 🔒 SSL/TLS support
- ⚡ Native performance (no websockets)
- 🛠️ Simple, promise-based API
- 🧩 Supports multi-nested domains
- 🔄 Subscribe, publish, and manage topics easily

---

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage](#usage)
- [API](#api)
- [Contributing](#contributing)
- [Todo](#todo)
- [License](#license)

---

## Installation

```bash
npm install sa-react-native-mqtt --save
```
or
```bash
yarn add sa-react-native-mqtt
```

## Version Compatibility

- React: >= 18.2.0
- React Native: >= 0.73.0
- iOS: >= 12.0
- Android: API level >= 21 (Android 5.0)

## Linking

```bash
react-native link sa-react-native-mqtt
```

### iOS

- Add the following to your `ios/Podfile` if not already present:
  ```ruby
  pod 'MQTTClient'
  ```
- Run `cd ios && pod install && cd ..`

### Android

- Update `android/settings.gradle`:

  ```gradle
  include ':sa-react-native-mqtt'
  project(':sa-react-native-mqtt').projectDir = new File(rootProject.projectDir,  '../node_modules/sa-react-native-mqtt/android')
  ```

- Update `android/app/build.gradle`:

  ```gradle
  dependencies {
      implementation project(':sa-react-native-mqtt')
  }
  ```

---

## Quick Start

```javascript
import MQTT from 'sa-react-native-mqtt';

MQTT.createClient({
  uri: 'mqtt://broker.hivemq.com:1883',
  clientId: 'exampleClientId'
}).then(client => {
  client.on('connect', () => {
    client.subscribe('test/topic', 0);
    client.publish('test/topic', 'Hello world!', 0, false);
  });
  client.connect();
});
```

---

## Usage

```javascript
import MQTT from 'sa-react-native-mqtt';

/* create mqtt client */
MQTT.createClient({
  uri: 'mqtt://test.mosquitto.org:1883',
  clientId: 'your_client_id'
}).then(function(client) {

  client.on('closed', function() {
    console.log('mqtt.event.closed');
  });

  client.on('error', function(msg) {
    console.log('mqtt.event.error', msg);
  });

  client.on('message', function(msg) {
    console.log('mqtt.event.message', msg);
  });

  client.on('connect', function() {
    console.log('connected');
    client.subscribe('/data', 0);
    client.publish('/data', "test", 0, false);
  });

  client.connect();
}).catch(function(err){
  console.log(err);
});
```

---

## API

### mqtt.createClient(options)

Creates a new client instance with the given options (returns a Promise).

**Options:**

- `uri` (string): `protocol://host:port`, protocol is [mqtt | mqtts]
- `host` (string): IP address or host name (overridden by `uri` if set)
- `port` (number): Port number (overridden by `uri` if set)
- `tls` (boolean): Enable TLS/SSL (overridden by `uri` if set to mqtts or wss)
- `user` (string): Username
- `pass` (string): Password
- `auth` (boolean): Set to true if `user` or `pass` exist (overrides default)
- `clientId` (string): Client ID
- `keepalive` (number): Keepalive interval in seconds

### client

- `on(event, callback)`: Add event listener
  - `event: "connect"` - client connected (`callback(): void`)
  - `event: "closed"` - client disconnected (`callback(): void`)
  - `event: "error"` - error occurred (`callback(error: any): void`)
  - `event: "message"` - message received (`callback(msg: Message): void`)
- `connect()`: Begin connection
- `disconnect()`: Disconnect
- `subscribe(topic: string, qos: number)`: Subscribe to a topic
- `publish(topic: string, payload: string, qos: number, retain: boolean)`: Publish a message

### Message object

- `retain` (boolean): Whether the message is retained (default: `false`)
- `qos` (number): Quality of Service (default: `2`)
- `data` (string): Message payload (default: `"test message"`)
- `topic` (string): Topic name (default: `"/data"`)

---

## Contributing

Contributions, issues and feature requests are welcome!  
Feel free to check [issues page](https://github.com/your-repo/sa-react-native-mqtt/issues) or submit a [pull request](https://github.com/your-repo/sa-react-native-mqtt/pulls).

See [CONTRIBUTING.md](./CONTRIBUTING.md) for more information.

---

## Todo

- [ ] Use WeakReference for timer
- [ ] Add disconnecting event
- [ ] Add async versions of:
  - [ ] connect
  - [ ] subscribe
  - [ ] disconnect
  - [ ] unsubscribe
- [x] Allow for multi-nested domains (e.g., na.est.example.com)
- [x] Add isConnected implementation for iOS
- [x] Add isSubbed for iOS & Android
- [x] Add getTopics for iOS & Android
- [x] This all u need to do 

---

## License

This project inherits its license from the underlying MQTT libraries. See the [LICENSE](./LICENSE) file for details.

---

<!--
If you have a screenshot or GIF, add it here for extra appeal!
-->
