package cachestorage

import "sync"

var mutex sync.Mutex

func AddCtrl() {
	mutex.Lock()
	defer mutex.Unlock()
}
