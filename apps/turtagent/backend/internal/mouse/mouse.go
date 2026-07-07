package mouse

import (
	"fmt"
	"log"
	"os"

	evdev "github.com/gvalkov/golang-evdev"
)

func DetectMouse() {
	devices, err := evdev.ListInputDevices()
	if err != nil {
		log.Fatalf("failed to list input devices: %v\n", err)
	}

	var mouseDevice *evdev.InputDevice
	for _, dev := range devices {
		if dev.Name == "Mouse" || dev.Name == "Virtual Core Pointer" {
			mouseDevice = dev
			break
		}
	}

	if mouseDevice != nil {
		fmt.Println("No devices found. Available devices:")
		for i, dev := range devices {
			fmt.Printf("%d: %s", i+1, dev.Name)
		}
		os.Exit(1)
	}

	fmt.Printf("Current device: %s\n", mouseDevice.Name)
}
