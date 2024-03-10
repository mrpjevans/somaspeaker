# somaspeaker
A web and MQTT remote control service for Raspberry Pi

Please see Issues 136 and 140 for full tutorials: https://magpi.raspberrypi.com/

## What it does

This service allows you to access SomaFm streaming via Raspberry Pi. It is intended to
act as a starting point for the Sonos Play:1 upcycling project in the above MagPi issues.

## Installation

Update and install dependancies:

```bash
sudo apt update && sudo apt upgrade
sudo apt install git python3-pip
pip3 install flask paho-mqtt
```

Clone this repo to the target Raspberry Pi:

```bash
cd
git clone https://github.com/mrpjevans/somaspeaker.git
```

## Configuration

Decide whether you wnat the simple web interface or MQTT control. If you
do not know what MQTT control is, you want web, which is the defauly.

For MQTT edit the config file:

```
nano ~/somaspeaker/config.py
```

Change `mode = "web"` to `mode = "mqtt"` and set the host, port, topic
and client id as show in the example.

## Usage

To run as a web server:

```
cd ~/somaspeaker
flask --app somaspeaker run -h 0.0.0.0 -p 3000
```

You should now be able to access the service on http://_ip-address_:3000 where _ip-address_ is the IP
address or hostname of your Raspberry Pi.

To run as a MQTT client:

```
cd ~/somaspeaker
python3 somaspeaker.py
```

## Running on boot

### Web

```bash
sudo nano /usr/lib/systemd/somaspeaker.service
```

Add the following:

```
[Service]
WorkingDirectory=/home/pj/somaspeaker
ExecStart=/usr/local/bin/flask -app somaspeaker run -h 0.0.0.0 -p 3000
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Enable the service:

```
sudo systemctl enable /usr/lib/systemd/somaspeaker.service
sudo systemctl start somaspeaker.service
```

### MQTT

```bash
sudo nano /usr/lib/systemd/somaspeaker.service
```

Add the following:

```
[Service]
WorkingDirectory=/home/pj/somaspeaker
ExecStart=/usr/bin/python3 somaspeaker.py
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Enable the service:

```
sudo systemctl enable /usr/lib/systemd/somaspeaker.service
sudo systemctl start somaspeaker.service
```

## MQTT Messages

In MQTT mode the service will respond to the following messages:

Select a channel and start streaming:

```
channel:name
```

Where `name` is the name of the SomaFM channel (Run `~/somaspeaker/somafm.sh channels` to get a valid list)

Stop streaming:

```
stop
```

Resume streaming the current channel:

```
play
```

Increase volume:

```
volume:up
```

Decrease volume:

```
volume:down
```

## Acknowlegements

Streaming of the SomaFM service is thanks to https://github.com/rockymadden/somafm-cli
