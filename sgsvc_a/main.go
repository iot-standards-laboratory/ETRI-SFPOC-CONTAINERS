package main

import (
	"bufio"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io"
	"net/http"
	"os"
	"sgsvca/consul_api"
	"sgsvca/model"
	"sgsvca/mqtthandler"
	"sgsvca/router"
	"strings"
)

func initService() {
	// {
	// 	myIP := getIP()
	// 	idx := strings.LastIndex(myIP, ".")
	// 	model.ServerAddr = myIP[:idx+1] + "1:3000"
	// 	// model.ServerAddr = "localhost:3000"
	// }

	// model.ServerAddr = "host.docker.internal:9995"
	model.ServerAddr = "code.godopu.com:9995"

	_uuid := os.Getenv("uuid")
	fmt.Println(_uuid)

	req, err := http.NewRequest("PUT", fmt.Sprintf("http://%s/api/v2/svcs", model.ServerAddr), nil)
	if err != nil {
		panic(err)
	}

	req.Header.Add("id", _uuid)
	// req.Header.Add("port", config.Params["bind"].(string))
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		panic(err)
	}

	payload := map[string]interface{}{}
	dec := json.NewDecoder(resp.Body)
	err = dec.Decode(&payload)
	if err != nil {
		panic(err)
	}

	connParam, ok := payload["conn_param"].(map[string]interface{})
	if !ok {
		panic(errors.New("invalid connection parameters error"))
	}

	origin, ok := payload["origin"].(string)
	if !ok {
		panic(errors.New("invalid origin address error"))
	}

	consulAddr, ok := connParam["consulAddr"]
	if !ok {
		panic(errors.New("invalid consul address error"))
	}
	mqttAddr, ok := connParam["mqttAddr"]
	if !ok {
		panic(errors.New("invalid mqtt address error"))
	}

	model.ConsulAddr = consulAddr.(string)
	model.MQTTAddr = mqttAddr.(string)
	model.Origin = origin
	model.SvcId = _uuid
}

func makeIndex() {
	template, err := os.Open("./www/template.index.html")
	if err != nil {
		panic(err)
	}
	defer template.Close()
	index, err := os.Create("./www/index.html")
	if err != nil {
		panic(err)
	}
	defer index.Close()

	reader := bufio.NewReader(template)
	for {
		line, _, err := reader.ReadLine()
		if err != nil {
			panic(err)
		} else if strings.Contains(string(line), `<base href="/svc/{{serviceid}}">`) {
			fmt.Fprintf(index, `<base href="/svc/%s/">`, model.SvcId)
			break
		} else {
			fmt.Fprintln(index, string(line))
		}
	}

	_, err = io.Copy(index, reader)
	if err != nil {
		panic(err)
	}
}

func connectConsul(svcId, consulAddr, originAddr string) error {
	key := fmt.Sprintf("svcs/%s", svcId)

	err := consul_api.Connect(consulAddr)
	if err != nil {
		return err
	}

	err = consul_api.RegisterAgent(key, fmt.Sprintf("http://%s:3456", originAddr))
	if err != nil {
		return err
	}

	go consul_api.UpdateTTL(func() (bool, error) { return true, nil }, key)

	// go consul_api.Monitor(func(s string) { fmt.Println(s) }, context.Background())

	return nil
}

func main() {
	// init
	flag.Parse()
	fmt.Println("Hello world")
	initService()
	// makeIndex()
	// model.PrintParam()
	// err := connectConsul(model.SvcId, model.ConsulAddr, model.Origin)
	// if err != nil {
	// 	panic(err)
	// }

	// mqtthandler.MQTTHandler = func(client mqtt.Client, msg mqtt.Message) {
	// 	if strings.Compare(msg.Topic(), "public/statuschanged") == 0 {
	// 		cachestorage.QueryCtrls("sgsvc_a")
	// 	}
	// }

	err := mqtthandler.ConnectMQTT("wss://mqtt.godopu.com", model.SvcId)
	if err != nil {
		panic(err)
	}
	// err = mqtthandler.Subscribe("public/statuschanged")
	// if err != nil {
	// 	panic(err)
	// }

	// err = cachestorage.QueryCtrls("sgsvc_a")
	// if err != nil {
	// 	panic(err)
	// }

	router.NewRouter(model.SvcId).Run(":3456")
}
