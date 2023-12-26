package model

import (
	"errors"
	"log"
	"strings"
	"sync"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type MeasurementData struct {
	gorm.Model
	ID     string    `json:"id"`
	Name   string    `json:"name"`
	Tags   []string  `json:"tags"`
	Status []*Status `json:"status"`
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
		setStatus(msmt, status)
	}

	log.Println("update:", measurements[mid])

	return nil
}

func setStatus(msmtdata *MeasurementData, status map[string]interface{}) {
	if status == nil || msmtdata == nil {
		return
	}

	// 기존에 있는 key의 값 변경
	for _, e := range msmtdata.Status {
		value, ok := status[e.Key]
		if ok {
			e.Value = value
		}
	}

	// 새로운 Key의 값 추가
	// for k, v := range status {
	// 	var unit string
	// 	if strings.Compare(k, "temperature") == 0 {
	// 		unit = "도씨"
	// 	} else if strings.Compare(k, "humidity") == 0 {
	// 		unit = "습도"
	// 	}
	// 	msmtdata.Status = append(msmtdata.Status, &Status{
	// 		Key:   k,
	// 		Value: v,
	// 		Unit:  unit,
	// 	})
	// }
}

func CreateMeasurement(did string, name string, status map[string]interface{}) (string, error) {
	measurementMutex.Lock()
	defer measurementMutex.Unlock()

	_, ok := devs[did]
	if !ok {
		return "", errors.New("wrong did is transmitted")
	}

	// should be modified
	rel, ok := relations[did]
	if ok && len(rel) > 0 {
		return measurements[rel[0].Identifier].ID, nil
	}

	_uuid, err := uuid.NewUUID()
	if err != nil {
		return "", err
	}
	mid := _uuid.String()

	msmtdata := MeasurementData{
		ID:     mid,
		Tags:   []string{did},
		Name:   name,
		Status: getEmptyStatus("DEVICE-A"),
	}

	setStatus(&msmtdata, status)

	measurements[mid] = &msmtdata

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

func getEmptyStatus(dtype string) []*Status {

	var status []*Status
	if strings.Compare(dtype, "DEVICE-A") == 0 {
		status = make([]*Status, 5)
		status[0] = &Status{
			Key:         "Temp",
			Value:       0,
			Description: "온도",
			Unit:        "℃",
			Type:        "xs:number",
		}

		status[1] = &Status{
			Key:         "Humidity",
			Value:       0,
			Description: "습도",
			Unit:        "%",
			Type:        "xs:number",
		}

		status[2] = &Status{
			Key:         "SoliHumi",
			Value:       0,
			Description: "토양 습도",
			Unit:        "%",
			Type:        "xs:number",
		}

		status[3] = &Status{
			Key:         "fan",
			Value:       false,
			Description: "선풍기?",
			Unit:        "",
			Type:        "xs:boolean",
		}

		status[4] = &Status{
			Key:         "lamp",
			Value:       false,
			Description: "램프",
			Unit:        "",
			Type:        "xs:boolean",
		}

	}

	return status
}
