package mouse

import (
	"fmt"
	"log"
	"os/exec"
	"strings"
	"time"

	evdev "github.com/holoplot/go-evdev"
)

type ShakeInput struct {
	MinMovements   int
	WindowDuration time.Duration
	MinDelta       int32
}

type relEvent struct {
	Code  int16
	Value int32
}

type absEvent struct {
	Code  int16
	Value int32
}

func DetectMouse() {
	devices, err := evdev.ListDevicePaths()
	if err != nil {
		log.Fatalf("failed to list input devices: %v\n", err)
	}

	mouseDevices := []evdev.InputPath{}

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

	relEventChan := make(chan relEvent)
	absEventChan := make(chan absEvent)

	for _, dev := range mouseDevices {
		d, err := evdev.Open(dev.Path)
		if err != nil {
			fmt.Printf("Error while opening device: %v\n", err)
			continue
		}

		fmt.Printf("Mouse device found: %s\n", dev.Name)

		go func(d *evdev.InputDevice) {
			for {
				event, err := d.ReadOne() // gets stuck here (for mouse)
				if err != nil {
					fmt.Printf("Error while reading device event: %v\n", err)
					continue
				}

				codeName := strings.ToLower(event.CodeName())

				if strings.Contains(codeName, "rel") {
					relEventChan <- relEvent{Code: int16(event.Code), Value: event.Value}
				} else if strings.Contains(codeName, "abs") {
					absEventChan <- absEvent{Code: int16(event.Code), Value: event.Value}
				}
			}
		}(d)
	}

	config := ShakeInput{
		MinMovements:   10,
		WindowDuration: 100 * time.Millisecond,
		MinDelta:       100,
	}

	var directionChanges []time.Time
	var pX, pY int32
	var previousRight, previousDown bool

	go func() {
		for event := range relEventChan {
			now := time.Now()
			cutoff := now.Add(-500 * time.Millisecond)

			validChanges := directionChanges[:0]

			for _, t := range directionChanges {
				if t.After(cutoff) {
					validChanges = append(validChanges, t)
				}
			}
			directionChanges = validChanges

			if len(directionChanges) <= 0 {
				directionChanges = append(directionChanges, now)
			}

			var directionChanged bool

			switch event.Code {
			case evdev.REL_X: // change on x
				dx := event.Value - pX

				if abs(dx) <= config.MinDelta {
					continue
				}

				currentRight := dx > 0
				directionChanged = currentRight != previousRight

				previousRight = currentRight

				pX = event.Value

			case evdev.REL_Y: // change on y
				dy := event.Value - pY

				if abs(dy) <= config.MinDelta {
					continue
				}

				currentDown := dy > 0
				directionChanged = currentDown != previousDown

				previousDown = currentDown

				pY = event.Value

			default:
				continue
			}

			if directionChanged {
				directionChanges = append(directionChanges, now)

				if len(directionChanges) >= config.MinMovements { // check if alr exceeded min movements
					fmt.Println("Mouse shake detected.")

					directionChanges = nil
				}
			}
		}
	}()

	go func() {
		for event := range absEventChan {
			now := time.Now()
			cutoff := now.Add(-500 * time.Millisecond)

			validChanges := directionChanges[:0]

			for _, t := range directionChanges {
				if t.After(cutoff) {
					validChanges = append(validChanges, t)
				}
			}
			directionChanges = validChanges

			if len(directionChanges) <= 0 {
				directionChanges = append(directionChanges, now)
			}

			var directionChanged bool

			switch event.Code {
			case evdev.ABS_X: // change on x
				dx := event.Value - pX

				if abs(dx) <= config.MinDelta {
					continue
				}

				currentRight := dx > 0
				directionChanged = currentRight != previousRight

				previousRight = currentRight

				pX = event.Value

			case evdev.ABS_Y: // change on y
				dy := event.Value - pY

				if abs(dy) <= config.MinDelta {
					continue
				}

				currentDown := dy > 0
				directionChanged = currentDown != previousDown

				previousDown = currentDown

				pY = event.Value

			default:
				continue
			}

			if directionChanged {
				directionChanges = append(directionChanges, now)

				if len(directionChanges) >= config.MinMovements { // check if alr exceeded min movements
					fmt.Println("Mouse shake detected.")

					launchOverlay()

					directionChanges = nil
				}
			}
		}
	}()
}

func abs(n int32) int32 {
	if n < 0 {
		return -n
	}
	return n
}

func launchOverlay() {
	appName := "turtagent_overlay"

	cmd := exec.Command(appName)

	err := cmd.Start()
	if err != nil {
		fmt.Printf("Error while starting turtagent: %v\n", err)
	}
}
