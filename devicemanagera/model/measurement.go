package model

import "gorm.io/gorm"

type MeasurementData struct {
	gorm.Model
	ID     string                 `json:"id"`
	Tags   []string               `json:"tags"`
	Status map[string]interface{} `json:"status"`
}
