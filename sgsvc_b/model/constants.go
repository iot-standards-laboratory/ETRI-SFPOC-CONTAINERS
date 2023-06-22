package model

import "fmt"

var ConsulAddr = ""
var MQTTAddr = ""
var SvcId = ""
var Origin = ""
var ServerAddr = ""

func PrintParam() {
	fmt.Println("consul addr:", ConsulAddr)
	fmt.Println("mqtt addr:", MQTTAddr)
	fmt.Println("origin addr:", Origin)
	fmt.Println("svc id:", SvcId)
}
