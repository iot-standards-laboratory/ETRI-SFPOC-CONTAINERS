package router

import (
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)

// var lengthOfPushPrefix int

func NewRouter(svcId string) *gin.Engine {
	prefix := "/svc/" + svcId
	apiEngine := gin.New()
	api := apiEngine.Group(prefix + "/api/")
	{
		api.GET("/printHello", func(ctx *gin.Context) {
			ctx.String(http.StatusOK, "Hello!!")
		})
	}

	assetEngine := gin.New()
	assetEngine.Static(prefix, "./front/build/web")
	// assetEngine.Static(prefix, "./static")

	r := gin.New()

	r.Any("/*any", func(c *gin.Context) {
		path := c.Param("any")
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
