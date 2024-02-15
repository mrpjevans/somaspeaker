from paho.mqtt import client as mqtt_client
import subprocess
from time import sleep

FIRST_RECONNECT_DELAY = 1
RECONNECT_RATE = 2
MAX_RECONNECT_COUNT = 12
MAX_RECONNECT_DELAY = 60

broker = '192.168.1.10'
port = 1883
topic = "study/sonos1/somafm"
client_id = "soma1"

current_channel = "groovesalad"
current_volume = 60

def connect_mqtt():
    def on_connect(client, userdata, flags, rc):
        if rc == 0:
            print("Connected to MQTT Broker!")
        else:
            print("Failed to connect, return code %d\n", rc)
    # Set Connecting Client ID
    client = mqtt_client.Client(client_id)
    client.on_connect = on_connect
    client.connect(broker, port)
    return client


def on_disconnect(client, userdata, rc):
    print("Disconnected with result code: %s", rc)
    reconnect_count, reconnect_delay = 0, FIRST_RECONNECT_DELAY
    while reconnect_count < MAX_RECONNECT_COUNT:
        print("Reconnecting in %d seconds...", reconnect_delay)
        sleep(reconnect_delay)

        try:
            client.reconnect()
            print("Reconnected successfully!")
            return
        except Exception as err:
            print("%s. Reconnect failed. Retrying...", err)

        reconnect_delay *= RECONNECT_RATE
        reconnect_delay = min(reconnect_delay, MAX_RECONNECT_DELAY)
        reconnect_count += 1
    print("Reconnect failed after %s attempts. Exiting...",
                 reconnect_count)

def subscribe(client: mqtt_client):
    def on_message(client, userdata, msg):
        print(f"Received `{msg.payload.decode()}` from `{msg.topic}` topic")
        trigger(msg.payload.decode())

    client.subscribe(topic)
    client.on_message = on_message

def trigger(msg):
    global current_channel, current_volume
    parts = msg.split(':')
    
    if parts[0] == "volume":
        
        if parts[1] == "up":
            current_volume += 5
        elif parts[1] == "down":
            current_volume -= 5
        else:
            current_volume = int(parts[1])

        if current_volume > 100:
            current_volume = 100
        elif current_volume < 0:
            current_volume = 0

        subprocess.Popen(['amixer', 'cset', 'numid=1', str(current_volume) + '%'])
        
        return
            
    subprocess.Popen(['killall', 'mpv'])
    if parts[0] == "channel":
        current_channel = parts[1]
        subprocess.Popen(['./somafm.sh', 'play', parts[1]])
    elif parts[0] == "play":
        subprocess.Popen(['./somafm.sh', 'play', current_channel])

client = connect_mqtt()
subscribe(client)
client.loop_forever()