import {
  NativeEventEmitter,
  NativeModules,
  Platform
} from 'react-native';

var Mqtt = NativeModules.Mqtt;

// Default configuration
const DEFAULT_CONFIG = {
  keepalive: 60,
  protocolLevel: 4,
  clean: true,
  tls: true,
  timeout: 30,
  automaticReconnect: true,
  maxReconnectAttempts: 5,
  reconnectInterval: 1000,
  messageQueueSize: 1000,
  compression: false,
  maxMessageSize: 1024 * 1024, // 1MB
  minTLSVersion: 'TLSv1.2'
};

var MqttClient = function(options, clientRef) {
  this.options = { ...DEFAULT_CONFIG, ...options };
  this.clientRef = clientRef;
  this.eventHandler = {};
  this.messageQueue = [];
  this.reconnectAttempts = 0;
  this.isConnecting = false;
  this.connectionTimeout = null;

  // Validate options
  this.validateOptions();

  // Handle TLS configuration
  if (this.options.tls) {
    this.setupTLS();
  }

  this.dispatchEvent = function(data) {
    if (data && data.clientRef == this.clientRef && data.event) {
      if (this.eventHandler[data.event]) {
        this.eventHandler[data.event](data.message);
      }
    }
  }

  // Handle reconnection
  this.handleReconnect = () => {
    if (this.reconnectAttempts < this.options.maxReconnectAttempts) {
      this.reconnectAttempts++;
      setTimeout(() => {
        if (!this.isConnected()) {
          this.connect();
        }
      }, this.options.reconnectInterval * this.reconnectAttempts);
    } else {
      this.dispatchEvent({ event: 'error', message: 'Max reconnection attempts reached' });
    }
  }
}

MqttClient.prototype.validateOptions = function() {
  // Validate clientId
  if (!this.options.clientId || typeof this.options.clientId !== 'string') {
    throw new Error('clientId must be a non-empty string');
  }

  // Validate auth credentials if auth is enabled
  if (this.options.auth) {
    if (!this.options.user || !this.options.pass) {
      throw new Error('user and pass are required when auth is enabled');
    }
    if (this.options.pass.length < 8) {
      console.warn('Password is too short. Consider using a stronger password.');
    }
  }

  // Validate message queue size
  if (this.options.messageQueueSize < 0) {
    throw new Error('messageQueueSize must be a positive number');
  }
}

MqttClient.prototype.setupTLS = function() {
  try {
    // If certificates are provided, validate them
    if (this.options.certificates) {
      if (!this.options.certificates.ca && !this.options.certificates.cert) {
        console.warn('TLS is enabled with certificates but CA or client certificate is missing. Using default certificate validation.');
      }
      
      // Validate certificate paths if provided
      if (this.options.certificates.ca && !this.validateCertificatePath(this.options.certificates.ca)) {
        throw new Error('Invalid CA certificate path');
      }
      if (this.options.certificates.cert && !this.validateCertificatePath(this.options.certificates.cert)) {
        throw new Error('Invalid client certificate path');
      }
      if (this.options.certificates.key && !this.validateCertificatePath(this.options.certificates.key)) {
        throw new Error('Invalid private key path');
      }
    } else {
      // No certificates provided, use system default certificate validation
      this.options.certificates = {
        rejectUnauthorized: true
      };
    }
  } catch (error) {
    console.error('TLS setup failed:', error);
    throw error;
  }
}

MqttClient.prototype.validateCertificatePath = function(path) {
  // Basic path validation
  return typeof path === 'string' && path.length > 0;
}

MqttClient.prototype.on = function (event, callback) {
  console.log('setup event', event);
  this.eventHandler[event] = callback;
}

MqttClient.prototype.connect = function () {
  if (this.isConnecting) return;
  this.isConnecting = true;
  
  // Clear message queue on new connection
  this.messageQueue = [];
  
  // Set connection timeout
  this.connectionTimeout = setTimeout(() => {
    if (this.isConnecting) {
      this.isConnecting = false;
      this.dispatchEvent({ event: 'error', message: 'Connection timeout' });
    }
  }, this.options.timeout * 1000);

  Mqtt.connect(this.clientRef);
}

MqttClient.prototype.disconnect = function () {
  this.isConnecting = false;
  this.reconnectAttempts = 0;
  if (this.connectionTimeout) {
    clearTimeout(this.connectionTimeout);
    this.connectionTimeout = null;
  }
  Mqtt.disconnect(this.clientRef);
}

MqttClient.prototype.subscribe = function (topic, qos) {
  Mqtt.subscribe(this.clientRef, topic, qos);
}

MqttClient.prototype.unsubscribe = function (topic) {
  Mqtt.unsubscribe(this.clientRef, topic);
}

MqttClient.prototype.publish = function(topic, payload, qos, retain) {
  // Validate message size
  if (payload && payload.length > this.options.maxMessageSize) {
    this.dispatchEvent({ event: 'error', message: 'Message size exceeds maximum limit' });
    return;
  }

  if (!this.isConnected()) {
    // Queue message if offline
    if (this.messageQueue.length < this.options.messageQueueSize) {
      this.messageQueue.push({ topic, payload, qos, retain });
    } else {
      this.dispatchEvent({ event: 'error', message: 'Message queue is full' });
    }
    return;
  }
  
  // Apply compression if enabled
  if (this.options.compression) {
    payload = this.compressPayload(payload);
  }
  
  Mqtt.publish(this.clientRef, topic, payload, qos, retain);
}

MqttClient.prototype.compressPayload = function(payload) {
  // Implement compression logic here
  return payload;
}

MqttClient.prototype.flushMessageQueue = function() {
  while (this.messageQueue.length > 0) {
    const msg = this.messageQueue.shift();
    this.publish(msg.topic, msg.payload, msg.qos, msg.retain);
  }
}

MqttClient.prototype.reconnect = function() {
  Mqtt.reconnect(this.clientRef);
};

MqttClient.prototype.isConnected = function() {
  return Mqtt.isConnected(this.clientRef);
};

MqttClient.prototype.getTopics = function() {
  return Mqtt.getTopics(this.clientRef);
};

MqttClient.prototype.isSubbed = function(topic) {
  return Mqtt.isSubbed(this.clientRef, topic);
};

const emitter = new NativeEventEmitter(Mqtt)

module.exports = {
  clients: [],
  eventHandler: null,
  dispatchEvents: function(data) {
    this.clients.forEach(function(client) {
      client.dispatchEvent(data);
      
      // Handle reconnection on connection lost
      if (data.event === 'closed' && client.options.automaticReconnect) {
        client.handleReconnect();
      }
      
      // Flush message queue on successful connection
      if (data.event === 'connect') {
        if (client.connectionTimeout) {
          clearTimeout(client.connectionTimeout);
          client.connectionTimeout = null;
        }
        client.isConnecting = false;
        client.flushMessageQueue();
      }

      // Handle connection errors
      if (data.event === 'error') {
        client.isConnecting = false;
        if (client.connectionTimeout) {
          clearTimeout(client.connectionTimeout);
          client.connectionTimeout = null;
        }
      }
    });
  },
  createClient: async function(options) {
    if(options.uri) {
      var pattern = /^((mqtt[s]?|ws[s]?)?:(\/\/)([0-9a-zA-Z_\.\-]*):?(\d+))$/;
      var matches = options.uri.match(pattern);
      if (!matches) {
        throw new Error(`Uri passed to createClient ${options.uri} doesn't match a known protocol (mqtt:// or ws://).`);
      }
      var protocol = matches[2];
      var host = matches[4];
      var port = matches[5];

      options.port = parseInt(port);
      options.host = host;
      options.protocol = 'tcp';

      // Force TLS for mqtts and wss protocols
      if(protocol == 'wss' || protocol == 'mqtts') {
        options.tls = true;
      }
      if(protocol == 'ws' || protocol == 'wss') {
        options.protocol = 'ws';
      }
    }

    // Validate required options
    if (!options.clientId) {
      throw new Error('clientId is required');
    }

    // Set default timeout
    if (!options.timeout) {
      options.timeout = DEFAULT_CONFIG.timeout;
    }

    let clientRef = await Mqtt.createClient(options);
    var client = new MqttClient(options, clientRef);

    if(this.eventHandler === null) {
      this.eventHandler = emitter.addListener(
        "mqtt_events",
        (data) => this.dispatchEvents(data));
    }
    this.clients.push(client);

    return client;
  },
  removeClient: function(client) {
    var clientIdx = this.clients.indexOf(client);

    if(clientIdx > -1)
      this.clients.splice(clientIdx, 1);

    if(this.clients.length === 0) {
      this.eventHandler.remove();
      this.eventHandler = null;
    }

    Mqtt.removeClient(client.clientRef);
  },

  disconnectAll: function () {
    Mqtt.disconnectAll();
  },

};
