package main

import (
	"bufio"
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
		line, err := reader.ReadString('\n')
		if err != nil {
			panic(err)
		} else if strings.Contains(line, `<base href="/svc/{{serviceid}}/">`) {
			fmt.Fprintf(index, `<base href="/svc/%s/">`, model.SvcId)
			break
		} else {
			fmt.Fprint(index, line)
		}
	}

	_, err = io.Copy(index, reader)
	if err != nil {
		panic(err)
	}
}

func main() {
	// init
	initService()
	model.PrintParam()
	router.NewRouter(model.SvcId).Run(":3579")
}
