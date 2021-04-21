package datagen

import (
	"math/rand"
	"time"

	"github.com/dchest/uniuri"
	"github.com/loadimpact/k6/js/modules"
)

func init() {
	modules.Register("k6/x/datagen", new(Datagen))
}

type Datagen struct{}

var bufferData = make(chan map[string]interface{}, 10000)

func (Datagen) GetData() map[string]interface{} {
	return <-bufferData
}

func (Datagen) GenerateData() {
	go func() {
		for {
			data := generateData()
			bufferData <- data
		}
	}()
}

func generateData() map[string]interface{} {
	rand.Seed(time.Now().UnixNano())
	data := map[string]interface{}{
		"car_id": uniuri.NewLen(5),
		"model":  uniuri.NewLen(5),
	}

	return data
}
