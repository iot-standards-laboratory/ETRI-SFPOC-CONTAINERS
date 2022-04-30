package router

import (
	"devicemanagera/model"
	"net/http"

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

	c.JSON(http.StatusOK, model.GetDevs())
}
