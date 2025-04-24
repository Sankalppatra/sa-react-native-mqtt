[![npm](https://img.shields.io/npm/dt/react-native-mqtt.svg)]()

# chromeellite-react-native-mqtt

MQTT client for react-native with new architecture support

## Description

A [react-native](https://github.com/facebook/react-native) mqtt client module that works

## MQTT Features (inherited from the native MQTT framework)
* Uses [MQTT Framework](https://github.com/ckrey/MQTT-Client-Framework) for IOS, [Paho MQTT Client](https://eclipse.org/paho/clients/android/) for Android
* Supports both IOS and Android
* SSL/TLS
* Native library, support mqtt over tcp (forget websockets, we're on **mobile**)


## Installation

```bash
npm install chromeellite-react-native-mqtt --save
```

or

```bash
yarn add chromeellite-react-native-mqtt
```

## Linking

```bash
react-native link chromeellite-react-native-mqtt
```

### iOS

* Run `cd ios && pod install && cd ..`

### Android

* Update `android/settings.gradle`:

```gradle
include ':chromeellite-react-native-mqtt'
project(':chromeellite-react-native-mqtt').projectDir = new File(rootProject.projectDir,  '../node_modules/chromeellite-react-native-mqtt/android')
```

* Update `android/app/build.gradle`:

```gradle
dependencies {
    implementation project(':chromeellite-react-native-mqtt')
}
```

## Usage

```javascript
import MQTT from 'chromeellite-react-native-mqtt';

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

## API

* `mqtt.createClient(options)`  create new client instance with `options`, async operation
  * `uri`: `protocol://host:port`, protocol is [mqtt | mqtts]
  * `host`: ipaddress or host name (override by uri if set)
  * `port`: port number (override by uri if set)
  * `tls`: true/false (override by uri if set to mqtts or wss)
  * `user`: string username
  * `pass`: string password
  * `auth`: true/false - override = true Set to true if `user` or `pass` exist
  * `clientId`: string client id
  * `keepalive`

* `client`
  * `on(event, callback)`: add event listener for
    * event: `connect` - client connected
    * event: `closed` - client disconnected
    * event: `error` - error
    * event: `message` - message object
  * `connect`: begin connection
  * `disconnect`: disconnect
  * `subscribe(topic, qos)`
  * `publish(topic, payload, qos, retain)`

* `message`
  * `retain`: *boolean* `false`
  * `qos`: *number* `2`
  * `data`: *string* `"test message"`
  * `topic`: *string* `"/data"`

## Todo

* [ ] Use WeakReference for timer
* [ ] Add disconnecting event
* [ ] Add async versions of:
 - [ ] connect
 - [ ] subscribe
 - [ ] disconnect
 - [ ] unsubscribe

* [X] Allow for multi nested domains ie: na.est.example.com
* [X] Add isConnected implementation for iOS
* [X] Add isSubbed for iOS & Android
* [X] Add getTopics for iOS & Android

## LICENSE

```text
INHERIT FROM MQTT LIBRARY (progress)
```
