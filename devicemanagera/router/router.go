package router

import (
	"devicemanagera/notifier"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)

type RequestBox struct {
	notifier.INotiManager
}

var box *RequestBox

func init() {
	box = &RequestBox{notifier.NewNotiManager()}
}

var lengthOfPushPrefix int

func NewRouter(sid string) *gin.Engine {
	prefix := "/svc/" + sid
	apiEngine := gin.New()

	apiv1 := apiEngine.Group(prefix + "/api/v1")
	{
		apiv1.PUT("/status", PutStatusReport)
		apiv1.GET("/status", GetStatus)
		apiv1.POST("/status", PostStatus)
		apiv1.POST("/dev", PostDevs)
	}

	assetEngine := gin.New()
	assetEngine.Static(prefix, "./front/build/web")
	// assetEngine.Static(prefix, "./static")

	lengthOfPushPrefix = len(prefix + "/push/v1/")
	pushEngine := gin.New()
	pushEngine.GET("/*any", func(c *gin.Context) {
		GetPublish(c)
	})

	r := gin.New()

	r.Any("/*any", func(c *gin.Context) {
		path := c.Param("any")
		if strings.HasPrefix(path, prefix+"/api/v1") {
			apiEngine.HandleContext(c)
		} else if strings.HasPrefix(path, prefix+"/push/v1") {
			pushEngine.HandleContext(c)
		} else if strings.HasPrefix(path, prefix) {
			assetEngine.HandleContext(c)
		} else {
			c.Status(http.StatusBadRequest)
		}
	})
	return r
}
