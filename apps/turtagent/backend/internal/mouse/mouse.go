package mouse

import (
	"fmt"
	"log"
	"strings"
	"time"

	evdev "github.com/gvalkov/golang-evdev"
)

type ShakeInput struct {
	MinMovements   int
	WindowDuration time.Duration
	MinDelta       int32
}

type relEvent struct {
	Code  uint16
	Value int32
}

func DetectMouse() {
	devices, err := evdev.ListInputDevices()
	if err != nil {
		log.Fatalf("failed to list input devices: %v\n", err)
	}

	mouseDevices := []*evdev.InputDevice{}

	for _, dev := range devices {
		lowerName := strings.ToLower(dev.Name)
		if (strings.Contains(lowerName, "mouse") || strings.Contains(lowerName, "touch")) &&
			!strings.Contains(lowerName, "consumer control") &&
			!strings.Contains(lowerName, "system control") {
			mouseDevices = append(mouseDevices, dev)
		}
	}

	if len(mouseDevices) <= 0 {
		log.Fatalf("could not find any suitable devices: %v\n", devices)
	}

	fmt.Printf("Current devices: %v\n", mouseDevices)

	eventChan := make(chan relEvent)

	for _, mouseDevice := range mouseDevices {
		go func(d *evdev.InputDevice) {
			for {
				event, err := d.ReadOne()
				if err != nil {
					fmt.Printf("Error while reading device: %v\n", err)
					return
				}

				if event.Type == evdev.EV_REL {
					eventChan <- relEvent{Code: event.Code, Value: event.Value}
				}
			}
		}(mouseDevice)
	}

	config := ShakeInput{
		MinMovements:   5,
		WindowDuration: 500 * time.Millisecond,
		MinDelta:       5,
	}

	var directionChanges []time.Time
	var lastXDir, lastYDir int

	fmt.Printf("Event channel: %v\n", eventChan)

	for event := range eventChan {
		fmt.Printf("Event: %v\n", event)

		now := time.Now()
		directionChanged := false

		var validChanges []time.Time
		for _, t := range directionChanges {
			if now.Sub(t) <= config.WindowDuration {
				validChanges = append(validChanges, t)
			}
		}
		directionChanges = validChanges

		switch event.Code {
		case evdev.REL_X: // change on x
			fmt.Println("Change on X detected.")
			dx := event.Value
			if abs(dx) > config.MinDelta { // check if exceeds min delta
				currentXDir := 1
				if dx < 0 {
					currentXDir = -1
				}

				if lastXDir != 0 && currentXDir != lastXDir {
					directionChanged = true
				}

				lastXDir = currentXDir
			}

		case evdev.REL_Y: // change on y
			fmt.Println("Change on Y detected.")
			dy := event.Value
			if abs(dy) > config.MinDelta { // check if exceeds min delta
				currentYDir := 1
				if dy < 0 {
					currentYDir = -1
				}

				if lastYDir != 0 && currentYDir != lastYDir {
					directionChanged = true
				}

				lastYDir = currentYDir
			}
		}

		if directionChanged {
			directionChanges = append(directionChanges, now)

			if len(directionChanges) >= config.MinMovements { // check if alr exceeded min movements
				fmt.Println("Mouse shake detected.")

				directionChanges = nil
				lastXDir = 0
				lastYDir = 0
			}
		}
	}
}

func abs(n int32) int32 {
	if n < 0 {
		return -n
	}
	return n
}
