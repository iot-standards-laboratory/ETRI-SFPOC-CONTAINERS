package main

import (
	"bufio"
	"devicemanagera/consul_api"
	"devicemanagera/model"
	"devicemanagera/router"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
)

func initService() {
	req, err := http.NewRequest("PUT", "http://localhost:3000/api/v2/svcs", nil)
	if err != nil {
		panic(err)
	}

	req.Header.Add("name", "devicemanagera")
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

	info, ok := payload["info"].(map[string]interface{})
	if !ok {
		panic(errors.New("invalid service information error"))
	}

	origin, ok := payload["origin"].(string)
	if !ok {
		panic(errors.New("invalid origin address error"))
	}

	consulAddr, ok := connParam["consulAddr"]
	if !ok {
		panic(errors.New("invalid consul address error"))
	}
	mqttAddr, ok := connParam["consulAddr"]
	if !ok {
		panic(errors.New("invalid mqtt address error"))
	}
	svcId, ok := info["id"].(string)
	if !ok {
		panic(errors.New("invalid service id error"))
	}

	model.ConsulAddr = consulAddr.(string)
	model.MQTTAddr = mqttAddr.(string)
	model.Origin = origin
	model.SvcId = svcId
}

func makeIndex() {
	template, err := os.Open("./front/build/web/template.index.html")
	if err != nil {
		panic(err)
	}
	defer template.Close()
	index, err := os.Create("./front/build/web/index.html")
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
	initService()
	makeIndex()
	// model.PrintParam()
	err := connectConsul(model.SvcId, model.ConsulAddr, model.Origin)
	if err != nil {
		panic(err)
	}
	router.NewRouter(model.SvcId).Run(":3456")
}
