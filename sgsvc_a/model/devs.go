package model

import (
	"errors"
	"sync"
)

var devs = map[string]*Device{}
var devMutex sync.Mutex

// for debug
func GetDevs() map[string]*Device {
	return devs
}
func AddDev(dev *Device) error {
	devMutex.Lock()
	defer devMutex.Unlock()
	if len(dev.DID) == 0 {
		return errors.New("did is empty")
	}
	devs[dev.DID] = dev

	return nil
}

func RemoveDev(did string) {
	devMutex.Lock()
	defer devMutex.Unlock()
	delete(devs, did)
}
