package router

import (
	"devicemanagera/notifier"
	"net/http"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
)

type RequestBox struct {
	notifier.INotiManager
}

var box *RequestBox

func init() {
	box = &RequestBox{notifier.NewNotiManager()}
	go fire()
}

func fire() {
	for i := 0; i < 20; i++ {
		box.Publish(notifier.NewStatusChangedEvent("Hello world", "Hello world", notifier.SubtokenStatusChanged))
		time.Sleep(time.Second * 2)
	}
}

func NewRouter(sid string) *gin.Engine {
	prefix := "/svc/" + sid
	apiEngine := gin.New()
	apiEngine.PUT("/*any", PutStatusReport)
	apiEngine.GET("/*any", GetStatus)
	apiEngine.POST("/*any", PostDevs)
	// apiEngine.POST("/*any", PostCtrl)
	// apiEngine.GET("/*any", GetState)
	// // apiEngine.PUT("/*any", PostStatusChangedHandle)
	// // apiEngine.PUT("/*any", GetStatusHandle)
	assetEngine := gin.New()
	assetEngine.Static(prefix, "./front/build/web")
	// assetEngine.Static(prefix, "./static")

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
