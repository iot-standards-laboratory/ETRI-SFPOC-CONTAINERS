package router

import (
	"devicemanagera/model"
	"devicemanagera/notifier"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)

func GetStatus(c *gin.Context) {
	defer handleError(c)

	path := c.Param("any")
	if len(path) <= 1 {
		did := c.GetHeader("did")
		if len(did) == 0 {
			c.JSON(http.StatusOK, model.GetMeasurements())
			return
		} else {
			var body []*model.MeasurementData

			relations, ok := model.GetRelations(did)
			if ok {
				for _, e := range relations {
					if strings.Compare(e.DataType, "measurement") == 0 {
						msmt, err := model.GetMeasurement(e.Identifier)
						if err != nil {
							continue
						}
						body = append(body, msmt)
					}
				}
			}

			c.JSON(http.StatusOK, body)
			return
		}

	}

	msmt, err := model.GetMeasurement(path[1:])
	if err != nil {
		panic(err)
	}

	c.JSON(http.StatusOK, msmt)
}

func PostStatus(c *gin.Context) {
	defer handleError(c)

	path := c.Param("any")

	if len(path) <= 1 {
		// create measurement data
		report := map[string]interface{}{}
		err := c.BindJSON(&report)
		if err != nil {
			panic(err)
		}
		did, ok := report["did"].(string)
		if !ok {
			panic(errors.New("bad request - you should import did to request"))
		}

		name, ok := report["name"].(string)
		if !ok {
			name = ""
		}

		status, ok := report["status"].(map[string]interface{})
		if !ok {
			status = nil
		}

		fmt.Println(report)

		mid, err := model.CreateMeasurement(did, name, status)
		if err != nil {
			panic(err)
		}

		c.String(http.StatusCreated, mid)
	} else {
		// handle control message
		mid := path[1:]

		relations, ok := model.GetRelations(mid)
		if !ok {
			panic(errors.New("invalid mid"))
		}

		devs := model.GetDevs()
		var cids []string
		for _, e := range relations {
			if strings.Compare(e.DataType, "device") == 0 {
				dev, ok := devs[e.Identifier]
				if !ok {
					// please delete relation
					// relation에만 엔티티가 있으며, 실제 디바이스는 삭제되었음
					continue
				}

				cids = append(cids, dev.CID)
			}
		}

		fmt.Println("cids: ", cids)

		report := map[string]interface{}{}
		err := c.BindJSON(&report)
		if err != nil {
			panic(err)
		}

		status, ok := report["status"].(map[string]interface{})
		if !ok {
			panic(errors.New("bad request - you should import status to request"))
		}

		err = model.UpdateMeasurement(mid, status)
		if err != nil {
			panic(err)
		}

		for _, cid := range cids {
			fmt.Println("send to", cid)
			box.Publish(
				notifier.NewPushEvent(
					"control",
					report,
					cid,
				),
			)
		}

		c.String(http.StatusOK, "OK")
	}
}

func PutStatus(c *gin.Context) {
	defer handleError(c)

	path := c.Param("any")
	if len(path) <= 1 {
		panic(errors.New("not exist mid"))
	}

	mid := path[1:]

	report := map[string]interface{}{}
	err := c.BindJSON(&report)
	if err != nil {
		panic(err)
	}

	// you can check authority here if want
	_, ok := report["did"].(string)
	if !ok {
		panic(errors.New("bad request - you should import did to request"))
	}

	status, ok := report["status"].(map[string]interface{})
	if !ok {
		b, _ := json.Marshal(report)
		panic(errors.New(fmt.Sprint("bad request -", string(b))))
	}

	err = model.UpdateMeasurement(mid, status)
	if err != nil {
		panic(err)
	}

	box.Publish(notifier.NewStatusChangedEvent("status changed", "status changed", mid))
	c.String(http.StatusOK, "OK")
}
