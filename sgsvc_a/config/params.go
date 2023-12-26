package config

import (
	"errors"
	"net"
	"os"
	"strings"

	"github.com/magiconair/properties"
)

const Mode = "debug"

var Params = map[string]interface{}{}

var serverAddr string
var MyIP string

func LoadConfig() {
	p := properties.MustLoadFile("./config.properties", properties.UTF8)
	Params["serverAddr"] = p.GetString("serverAddr", serverAddr)
	Params["mode"] = p.GetString("mode", "standalone")
	Params["bind"] = p.GetString("bind", ":4000")
	Params["sname"] = p.GetString("sname", "devicemanagera")
	Params["sid"] = p.GetString("sid", "blank")
}

func CreateInitFile() {

	f, err := os.Create("./config.properties")
	if err != nil {
		panic(err)
	}
	defer f.Close()

	MyIP = getIP()
	idx := strings.LastIndex(MyIP, ".")
	serverAddr = MyIP[:idx+1] + "1:3000"

	var operatingMode OperatingMode
	mode := os.Getenv("mode")
	if len(mode) == 0 || strings.Compare(mode, string(STANDALONE)) == 0 {
		operatingMode = STANDALONE
	} else {
		operatingMode = MANAGEDBYEDGE
	}

	p := properties.NewProperties()
	p.SetValue("serverAddr", serverAddr)
	p.SetValue("mode", operatingMode)
	p.SetValue("bind", ":9000")
	p.SetValue("sname", "devicemanagera")
	p.SetValue("sid", "blank")
	p.Write(f, properties.UTF8)

}

func getIP() string {
	host, _ := os.Hostname()
	addrs, _ := net.LookupIP(host)

	return addrs[0].String()
}

func Set(key, value string) {

	var p *properties.Properties
	if _, err := os.Stat("./config.properties"); errors.Is(err, os.ErrNotExist) {
		p = properties.NewProperties()
	} else {
		p = properties.MustLoadFile("./config.properties", properties.UTF8)
		os.Remove("./config.properties")
	}
	f, err := os.Create("./config.properties")
	if err != nil {
		panic(err)
	}
	defer f.Close()

	p.SetValue(key, value)
	p.Write(f, properties.UTF8)
	Params[key] = value
}
