package router

import (
	"net/http"
	"sgsvcb/model"

	"github.com/gin-gonic/gin"
)

func PostDevs(c *gin.Context) {
	defer handleError(c)
	var obj model.Device
	c.BindJSON(&obj)

	model.AddDev(&obj)

	c.Status(http.StatusOK)
}

// device send controller msg to service

// for debug
func GetDevs(c *gin.Context) {
	defer handleError(c)

	devs := make([]*model.Device, 0, 10)
	for _, v := range model.GetDevs() {
		devs = append(devs, v)
	}
	c.JSON(http.StatusOK, devs)
}
