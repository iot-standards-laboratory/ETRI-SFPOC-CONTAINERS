package model

import (
	"errors"
	"log"
	"sync"

	"github.com/gofrs/uuid"
)

var devs = map[string]*Device{}
var devMutex sync.Mutex

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

var measurements = map[string]*MeasurementData{}
var measurementMutex sync.Mutex

func UpdateMeasurement(cid, did string, status map[string]interface{}) error {
	measurementMutex.Lock()
	defer measurementMutex.Unlock()
	dev, ok := devs[did]
	if !ok {
		return errors.New("wrong did is transmitted")
	}

	if dev.CID != cid {
		return errors.New("wrong cid is transmitted")
	}

	msmt, ok := measurements["did"]
	if !ok {
		_uuid, _ := uuid.NewV4()
		measurements["did"] = &MeasurementData{
			ID:     _uuid.String(),
			Tags:   []string{did},
			Status: status,
		}
	} else {
		msmt.Status = status
	}

	log.Println("update:", measurements["did"])
	return nil
}

func GetMeasurement(did string) (*MeasurementData, error) {
	msmt, ok := measurements[did]
	if !ok {
		return nil, errors.New("not exist measurement")
	}

	return msmt, nil
}

func RemoveMeasurement(did string) {
	measurementMutex.Lock()
	defer measurementMutex.Unlock()
	delete(devs, did)
}
