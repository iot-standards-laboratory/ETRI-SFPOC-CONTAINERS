package router

import (
	"devicemanagera/notifier"
	"fmt"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/gofrs/uuid"
	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin:     func(r *http.Request) bool { return true },
}

func GetPublish(c *gin.Context) {
	_complete := make(chan int)
	_uuid, _ := uuid.NewV4()

	path := c.Param("any")
	fmt.Println(path)

	var subtoken string
	if len(path) <= lengthOfPushPrefix {
		subtoken = notifier.SubtokenStatusChanged
	} else if path[lengthOfPushPrefix-1] != '/' {
		return
	} else {
		subtoken = path[lengthOfPushPrefix:]
	}

	conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		c.Writer.WriteHeader(http.StatusBadRequest)
		c.Writer.Write([]byte(err.Error()))
		return
	}

	subscriber := notifier.NewWebsocketSubscriber(
		_uuid.String(),
		subtoken,
		notifier.SubtypeCont,
		_complete,
		conn,
	)

	box.AddSubscriber(subscriber)
	defer box.RemoveSubscriber(subscriber)

	closeCh := make(chan bool)
	go func() {
		defer func() {
			if r := recover(); r != nil {
				closeCh <- true
			}
		}()
		for {
			// Read Messages
			_, _, err := conn.ReadMessage()

			if c, k := err.(*websocket.CloseError); k {
				if c.Code == 1000 {
					// Never entering since c.Code == 1005
					log.Println(err)
					panic(err)
				}
			}
		}
	}()

	select {
	case <-closeCh:
		box.RemoveSubscriber(subscriber)
		return
	case <-_complete:
		return
	}
}
