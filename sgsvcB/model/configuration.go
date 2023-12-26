package model

import "gorm.io/gorm"

type Device struct {
	gorm.Model
	DID   string `gorm:"uniqueIndex;column:did" json:"did"` // Device ID
	DName string `gorm:"column:dname" json:"dname"`         // Device Name
	Type  string `gorm:"column:type" json:"type"`           // Device Type
	CID   string `gorm:"column:cid" json:"cid"`             // Controller ID
	SID   string `gorm:"column:sid" json:"sid"`             // Service ID
	SName string `gorm:"column:sname" json:"sname"`         // Service Name
	// Opts []string
}

type Controller struct {
	gorm.Model
	CID   string `gorm:"uniqueIndex;column:cid" json:"cid"` // Controller ID
	CName string `gorm:"column:ename" json:"cname"`         // Device ID
	Key   string `gorm:"column:key" json:"key"`             // Service ID
}

type Service struct {
	gorm.Model
	SName     string `gorm:"column:sname" json:"sname"`
	SID       string `gorm:"column:sid" json:"sid"`
	NumOfDevs int    `gorm:"column:ndevs" json:"ndevs"`
	Addr      string `gorm:"column:addr"`
}
