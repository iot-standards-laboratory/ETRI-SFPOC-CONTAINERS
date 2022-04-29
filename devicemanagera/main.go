package main

import (
	"devicemanagera/config"
	"devicemanagera/router"
	"encoding/json"
	"errors"
	"net/http"
	"os"
)

func registerToServer() {
	req, err := http.NewRequest("PUT", "http://"+config.Params["serverAddr"].(string)+"/api/v1/svcs", nil)
	if err != nil {
		panic(err)
	}

	req.Header.Add("sname", config.Params["sname"].(string))
	req.Header.Add("port", config.Params["bind"].(string))

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		panic(err)
	}
	var info map[string]interface{}
	dec := json.NewDecoder(resp.Body)
	dec.Decode(&info)

	config.Set("sid", info["sid"].(string))
}

func main() {
	if _, err := os.Stat("./config.properties"); errors.Is(err, os.ErrNotExist) {
		// path/to/whatever does not exist
		config.CreateInitFile()
	}

	config.LoadConfig()
	// register
	if config.Params["sid"] == "blank" {
		if config.Params["mode"] == config.MANAGEDBYEDGE {
			registerToServer()
		} else {
			config.Set("sid", "")
		}
	}

	router.NewRouter(config.Params["sid"].(string)).Run(config.Params["bind"].(string))
}
