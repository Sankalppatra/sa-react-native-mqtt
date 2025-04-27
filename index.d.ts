export type QoS = 0 | 1 | 2;

interface IMqttClientOptions {
	clientId: string;
	uri: string;
	host?: string;
	port?: number;
	protocol?: 'mqtt' | 'tcp' | 'wss' | 'mqtts' | 'ws';
	tls?: boolean;
	keepalive?: number; // seconds
	protocolLevel?: number;
	clean?: boolean;
	auth?: boolean;
	user?: string; // only used when auth is true
	pass?: string; // only used when auth is true
	will?: boolean;
	willMsg?: string; // only used when will is true
	willtopic?: string; // only used when will is true
	willQos?: QoS; // only used when will is true
	willRetainFlag?: boolean; // only used when will is true
	automaticReconnect?: boolean; // android only
	timeout?: number; // connection timeout in seconds
	maxReconnectAttempts?: number; // maximum number of reconnection attempts
	reconnectInterval?: number; // interval between reconnection attempts in milliseconds
	messageQueueSize?: number; // maximum size of offline message queue
	compression?: boolean; // enable message compression
	maxMessageSize?: number; // maximum message size in bytes (default: 1MB)
	minTLSVersion?: 'TLSv1' | 'TLSv1.1' | 'TLSv1.2' | 'TLSv1.3'; // minimum TLS version
	certificates?: {
		ca?: string; // CA certificate (optional)
		cert?: string; // client certificate (optional)
		key?: string; // client private key (optional)
		rejectUnauthorized?: boolean; // reject unauthorized certificates (default: true)
	};
}

export class IMqttClient {
	constructor(options: IMqttClientOptions);

	on(event: 'closed', cb: (msg: string) => void): void;

	on(event: 'error', cb: (msg: string) => void): void;

	on(
		event: 'message',
		cb: (msg: { data: string; qos: QoS; retain: boolean; topic: string }) => void,
	): void;

	on(event: 'connect', cb: (msg: { reconnect: boolean }) => void): void;

	connect(): void;

	disconnect(): void;

	subscribe(topic: string, qos: QoS): void;

	unsubscribe(topic: string): void;

	publish(topic: string, payload: string, qos: QoS, retain: boolean): void;

	reconnect(): void;

	isConnected(): Promise<boolean>;

	getTopics(): string[];

	isSubbed(topic: string): boolean;

	flushMessageQueue(): void;
}

declare namespace mqtt {
	function createClient(options: IMqttClientOptions): Promise<IMqttClient>;
	function removeClient(client: IMqttClient): void;
	function disconnectAll(): void;
}

export default mqtt;

