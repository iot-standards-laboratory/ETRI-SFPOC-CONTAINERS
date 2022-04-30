package model

import (
	"errors"
	"log"
	"sync"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type MeasurementData struct {
	gorm.Model
	ID     string                 `json:"id"`
	Name   string                 `json:"name"`
	Tags   []string               `json:"tags"`
	Status map[string]interface{} `json:"status"`
}

type Status struct {
	Key         string
	Description string
	Type        string
	Unit        string
	Value       interface{}
}

// measurements[mid] = mesurement data
var measurements = map[string]*MeasurementData{}
var measurementMutex sync.Mutex

func UpdateMeasurement(mid string, status map[string]interface{}) error {
	measurementMutex.Lock()
	defer measurementMutex.Unlock()

	msmt, ok := measurements[mid]
	if !ok {
		return errors.New("not exist mid")
	} else {
		msmt.Status = status
	}

	log.Println("update:", measurements[mid])

	return nil
}

func CreateMeasurement(did string, status map[string]interface{}) (string, error) {
	measurementMutex.Lock()
	defer measurementMutex.Unlock()

	_, ok := devs[did]
	if !ok {
		return "", errors.New("wrong did is transmitted")
	}

	_uuid, err := uuid.NewUUID()
	if err != nil {
		return "", err
	}
	mid := _uuid.String()
	measurements[mid] = &MeasurementData{
		ID:     mid,
		Tags:   []string{did},
		Status: status,
	}

	AddRelation(mid, "device", did)
	AddRelation(did, "measurement", mid)

	return mid, nil
}

func GetMeasurement(mid string) (*MeasurementData, error) {
	msmt, ok := measurements[mid]
	if !ok {
		return nil, errors.New("not exist measurement")
	}

	return msmt, nil
}

// for debug
func GetMeasurements() map[string]*MeasurementData {
	return measurements
}

func RemoveMeasurement(mid string) {
	measurementMutex.Lock()
	defer measurementMutex.Unlock()
	delete(measurements, mid)
}
