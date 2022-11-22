package main

import (
	"bufio"
	"devicemanagerb/config"
	"devicemanagerb/router"
	"errors"
	"fmt"
	"io"
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

func makeIndex(sid string) {
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
			fmt.Fprintf(index, `<base href="/svc/%s/">`, sid)
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

		// make index file
		makeIndex(config.Params["sid"].(string))
	} else {
		if strings.Compare(config.Params["mode"].(string), string(config.MANAGEDBYEDGE)) == 0 {
			reconnectToEdge(config.Params["sid"].(string))
		}
	}

	router.NewRouter(config.Params["sid"].(string)).Run(config.Params["bind"].(string))
}
