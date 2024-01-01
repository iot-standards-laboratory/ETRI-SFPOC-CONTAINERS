package router

import (
	"net/http"
	"sgsvcb/model"
	"sgsvcb/model/cachestorage"
	"strings"

	"github.com/gin-gonic/gin"
)

// var lengthOfPushPrefix int

func NewRouter(svcId string) *gin.Engine {
	prefix := "/svc/" + svcId
	apiEngine := gin.New()

	api := apiEngine.Group(prefix + "/api/")
	{
		api.GET("/init", func(ctx *gin.Context) {

			params := map[string]interface{}{
				"mqtt_address": model.MQTTAddr,
				"service_id":   model.SvcId,
				"ctrls":        cachestorage.GetCtrls(),
			}
			ctx.JSON(http.StatusOK, params)
		})
	}

	assetEngine := gin.New()
	assetEngine.Static(prefix, "./www")
	// assetEngine.Static(prefix, "./static")

	r := gin.New()

	r.Any("/*any", func(c *gin.Context) {
		path := c.Param("any")
		c.Writer.Header().Set("Cache-Control", "no-cache, private, max-age=0")
		c.Writer.Header().Add("Pragma", "no-cache")
		c.Writer.Header().Add("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Add("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE")
		if strings.HasPrefix(path, prefix+"/api/") {
			apiEngine.HandleContext(c)
		} else if strings.HasPrefix(path, prefix) {
			assetEngine.HandleContext(c)
		} else {
			c.Status(http.StatusBadRequest)
		}
	})
	return r
}
