package model

import (
	"strings"
	"sync"
)

type Relation struct {
	DataType   string
	Identifier string
}

var relations = map[string][]*Relation{}
var relationsMutex sync.Mutex

func AddRelation(key, dtype, identifier string) error {
	relationsMutex.Lock()
	defer relationsMutex.Unlock()

	list, ok := relations[key]
	if !ok {
		list := make([]*Relation, 0, 10)
		list = append(list, &Relation{
			DataType:   dtype,
			Identifier: identifier,
		})
		relations[key] = list
		return nil
	}

	for _, e := range list {
		if strings.Compare(identifier, e.Identifier) == 0 {
			return nil
		}
	}

	relations[key] = append(list, &Relation{
		DataType:   dtype,
		Identifier: identifier,
	})

	return nil
}

func GetRelations(key string) ([]*Relation, bool) {
	list, ok := relations[key]
	return list, ok
}
