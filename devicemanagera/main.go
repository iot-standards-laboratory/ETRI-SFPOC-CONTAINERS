package main

import (
	"devicemanagera/config"
	"devicemanagera/router"
	"errors"
	"io/ioutil"
	"net/http"
	"os"
	"strings"

	"github.com/google/uuid"
)

func registerToEdge() {
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

	b, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		panic(err)
	}

	config.Set("sid", string(b))
}

func reconnectToEdge(sid string) {
	req, err := http.NewRequest("PUT", "http://"+config.Params["serverAddr"].(string)+"/api/v1/svcs/"+sid, nil)
	if err != nil {
		panic(err)
	}

	req.Header.Add("sname", config.Params["sname"].(string))
	req.Header.Add("port", config.Params["bind"].(string))

	_, err = http.DefaultClient.Do(req)
	if err != nil {
		panic(err)
	}

}

func main() {
	if _, err := os.Stat("./config.properties"); errors.Is(err, os.ErrNotExist) {
		// path/to/whatever does not exist
		config.CreateInitFile()
	}

	config.LoadConfig()
	// register
	if strings.Compare(config.Params["sid"].(string), "blank") == 0 {
		if strings.Compare(config.Params["mode"].(string), string(config.MANAGEDBYEDGE)) == 0 {
			registerToEdge()
		} else {
			_uuid, err := uuid.NewUUID()
			if err != nil {
				panic(err)
			}
			config.Set("sid", _uuid.String())
		}
	} else {
		if strings.Compare(config.Params["mode"].(string), string(config.MANAGEDBYEDGE)) == 0 {
			reconnectToEdge(config.Params["sid"].(string))
		}
	}

	router.NewRouter(config.Params["sid"].(string)).Run(config.Params["bind"].(string))
}
