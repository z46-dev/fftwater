package main

import (
	"github.com/z46-dev/fftwater/internal/app"
	"github.com/z46-dev/golog"
)

func main() {
	var (
		err error
		log *golog.Logger = golog.New().Prefix("[Main]", golog.BoldBlue).Timestamp()
	)

	log.Info("Starting FFTWater...")
	if err = app.Run(log.SpawnChild().Prefix("[app]", golog.BoldGreen)); err != nil {
		log.Fatalf("app.Run() failed: %v", err)
	}
}
