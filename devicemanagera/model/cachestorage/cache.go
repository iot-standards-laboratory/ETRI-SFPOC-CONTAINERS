package cachestorage

import (
	"devicemanagera/model"
	"devicemanagera/mqtthandler"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"sync"
)

var mutex sync.Mutex

var ctrls []*model.Controller

func GetCtrls() []*model.Controller {
	return ctrls
}

func QueryCtrls(svcName string) error {
	req, err := http.NewRequest("GET", fmt.Sprintf("http://%s/api/v2/ctrls", model.ServerAddr), nil)
	if err != nil {
		return err
	}

	req.Header.Add("service_name", svcName)

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return err
	}

	dec := json.NewDecoder(resp.Body)
	m_ctrls := []map[string]interface{}{}

	err = dec.Decode(&m_ctrls)
	if err != nil {
		return err
	}

	mutex.Lock()
	defer mutex.Unlock()

	ctrls = make([]*model.Controller, 0, len(m_ctrls))
	for _, e := range m_ctrls {
		name, ok := e["name"].(string)
		if !ok {
			return errors.New("invalid name error")
		}

		key, ok := e["key"].(string)
		if !ok {
			return errors.New("invalid key error")
		}
		ctrls = append(ctrls, &model.Controller{
			Name:        name,
			ReportChan:  key,
			ControlChan: key + "c",
		})
	}

	mqtthandler.Publish(model.SvcId, []byte("changed"))
	fmt.Println(ctrls)
	return nil
}
