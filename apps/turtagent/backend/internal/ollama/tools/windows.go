package tools

import (
	"fmt"
	"os/exec"

	"github.com/ollama/ollama/api"
)

func GetWindowsTool() api.Tool {
	windowsTool := api.Tool{
		Type: "function",
		Function: api.ToolFunction{
			Name:        "get_windows",
			Description: "Gets the current windows opened in the desktop environment",
		},
	}

	return windowsTool
}

func GetWindows() string {
	cmd := exec.Command("bash", "-c", `kdotool search --name -- ".*" | xargs -I {} kdotool getwindowname {}`)

	output, err := cmd.CombinedOutput()
	fmt.Printf("kdotool output: %s\n", string(output))
	if err != nil {
		fmt.Printf("Error while executing kdotool: %v\n", err)
		return "An unexpected error occurred while getting windows."
	}

	return string(output)
}
