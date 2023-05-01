package model

type Controller struct {
	// key
	// status
	ReportChan  string `json:"report_chan"`
	ControlChan string `json:"control_chan"`
	Name        string `json:"name"`
	// 고유정보
}
