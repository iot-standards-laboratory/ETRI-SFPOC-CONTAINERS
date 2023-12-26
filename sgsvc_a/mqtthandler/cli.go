package mqtthandler

import (
	"fmt"
	"time"

	mqtt "github.com/eclipse/paho.mqtt.golang"
)

const user = "etrimqtt"
const passwd = "fainal2311"

var client mqtt.Client

// var f mqtt.MessageHandler = func(client mqtt.Client, msg mqtt.Message) {
// 	if strings.Compare(msg.Topic(), "public/statuschanged") == 0 {
// 		cachestorage.QueryCtrls("devicemanagera")
// 	}
// }

var MQTTHandler func(client mqtt.Client, msg mqtt.Message) = nil

func ConnectMQTT(mqttAddr, id string) error {
	opts := mqtt.NewClientOptions().AddBroker(mqttAddr).SetClientID(id)

	opts.SetKeepAlive(60 * time.Second)
	// Set the message callback handler
	opts.SetDefaultPublishHandler(MQTTHandler)
	opts.SetPingTimeout(1 * time.Second)
	opts.SetUsername(user)
	opts.SetPassword(passwd)
	opts.SetAutoReconnect(true)

	client = mqtt.NewClient(opts)
	if token := client.Connect(); token.Wait() && token.Error() != nil {
		return token.Error()
	}

	return nil
}

func Publish(topic string, payload []byte) error {
	tkn := client.Publish(topic, 0, false, payload)
	return tkn.Error()
}

func Subscribe(topic string) error {
	if token := client.Subscribe(topic, 0, nil); token.Wait() && token.Error() != nil {
		return token.Error()
	}
	return nil
}

func Unsubscribe(topic string) {
	if token := client.Unsubscribe(topic); token.Wait() && token.Error() != nil {
		fmt.Println(token.Error())
	}
}
