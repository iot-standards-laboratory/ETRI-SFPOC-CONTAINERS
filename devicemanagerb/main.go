package main

import (
	"bytes"
	"devicemanagerb/config"
	"devicemanagerb/router"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
)

func registerToServer() {

	var obj map[string]string = make(map[string]string)
	obj["name"] = "devicemanagerb"
	obj["addr"] = config.MyIP + ":3000"

	b, err := json.Marshal(obj)
	if err != nil {
		panic(err)
	}

	req, err := http.NewRequest("PUT", "http://"+config.ServerAddr+":3000/api/v1/svcs", bytes.NewBuffer(b))
	if err != nil {
		panic(err)
	}

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		panic(err)
	}

	b, err = ioutil.ReadAll(resp.Body)
	if err != nil {
		panic(err)
	}
	fmt.Println(string(b))
}

func main() {
	registerToServer()
	err := http.ListenAndServe(":3000", router.NewRouter())
	if err != nil {
		panic(err)
	}
}
