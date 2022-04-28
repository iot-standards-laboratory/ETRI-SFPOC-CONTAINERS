package router

import (
	"devicemanagera/model"
	"devicemanagera/notifier"
	"errors"
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
)

func PostDevs(c *gin.Context) {
	var obj model.Device
	fmt.Println("Wow")
	c.BindJSON(&obj)

	model.AddDev(&obj)

	c.Status(http.StatusOK)
}

// device send controller msg to service
func PutStatusReport(c *gin.Context) {
	defer handleError(c)
	report := map[string]interface{}{}
	err := c.BindJSON(&report)
	if err != nil {
		panic(err)
	}
	did, ok := report["did"].(string)
	if !ok {
		panic(errors.New("bad request - you should import did to request"))
	}

	cid, ok := report["cid"].(string)
	if !ok {
		panic(errors.New("bad request - you should import cid to request"))
	}

	status, ok := report["status"].(map[string]interface{})
	if !ok {
		panic(errors.New("bad request - you should import state to request"))
	}

	err = model.UpdateMeasurement(cid, did, status)
	if err != nil {
		panic(err)
	}

	box.Publish(notifier.NewStatusChangedEvent("status changed", "status changed", notifier.SubtokenStatusChanged))
	c.String(http.StatusOK, "OK")
}

func GetStatus(c *gin.Context) {
	defer handleError(c)

	did := c.GetHeader("did")
	if len(did) == 0 {
		panic(errors.New("bad request - you should import did to header"))
	}

	msmt, err := model.GetMeasurement(did)
	if err != nil {
		panic(err)
	}

	c.JSON(http.StatusOK, msmt)
}

// func GetState(c *gin.Context) {
// 	defer handleError(c)

// 	var dev map[string]interface{} = nil
// 	for _, v := range model.Cache {
// 		dev = v
// 		break
// 	}

// 	if dev == nil {
// 		panic(errors.New("device is not found"))
// 	}
// 	// write response
// 	c.JSON(http.StatusOK, dev["state"])
// }

// func PostCtrl(c *gin.Context) {
// 	defer handleError(c)

// 	var state map[string]interface{}
// 	c.BindJSON(&state)

// 	var dev map[string]interface{}
// 	for _, v := range model.Cache {
// 		dev = v
// 		break
// 	}

// 	var ok bool
// 	payload := map[string]interface{}{}
// 	payload["did"], ok = dev["did"]
// 	if !ok {
// 		panic(errors.New("bad request - you should import did to request"))
// 	}

// 	payload["dname"], ok = dev["dname"]
// 	if !ok {
// 		panic(errors.New("bad request - you should import did to request"))
// 	}

// 	payload["state"] = state

// 	fmt.Println(payload)

// 	b, err := json.Marshal(payload)
// 	if err != nil {
// 		panic(err)
// 	}
// 	// send put message to edge
// 	req, err := http.NewRequest("POST", "http://"+config.Params["serverAddr"].(string)+"/push/v1/", bytes.NewReader(b))
// 	if err != nil {
// 		panic(err)
// 	}

// 	req.Header.Add("subtoken", dev["cid"].(string))

// 	resp, err := http.DefaultClient.Do(req)
// 	if err != nil {
// 		panic(err)
// 	}

// 	body, err := ioutil.ReadAll(resp.Body)
// 	if err != nil {
// 		panic(err)
// 	}
// 	// write response
// 	c.String(resp.StatusCode, string(body))
// }

// 	// send push
// 	req, err := http.NewRequest("PUT", "http://"+config.ServerAddr+"/push/v1/"+, bytes.NewReader(b))
// 	if err != nil {
// 		return
// 	}

// }

// func PostCtrl(w http.ResponseWriter, r *http.Request) {
// 	vars := mux.Vars(r)

// 	_status := map[string]interface{}{}
// 	decoder := json.NewDecoder(r.Body)
// 	err := decoder.Decode(&_status)
// 	if err != nil {
// 		w.WriteHeader(http.StatusBadRequest)
// 		w.Write([]byte(err.Error()))
// 		return
// 	}

// 	did, ok := vars["id"]
// 	if !ok {
// 		w.WriteHeader(http.StatusBadRequest)
// 		w.Write([]byte(err.Error()))
// 		return
// 	}

// 	state[did] = _status
// 	log.Println(_status)

// 	w.WriteHeader(http.StatusOK)
// }
