package tools

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/ollama/ollama/api"
)

type CreateFileArgs struct {
	Name    string `json:"filename"`
	Dir     string `json:"directory"`
	Content string `json:"content"`
}

func GetCreateFileTool() api.Tool {
	properties := api.NewToolPropertiesMap()

	properties.Set("filename", api.ToolProperty{
		Type:        api.PropertyType{"string"},
		Description: "The filename for the file including the extension",
	})

	properties.Set("directory", api.ToolProperty{
		Type:        api.PropertyType{"string"},
		Description: "The directory where the file resides in",
	})

	properties.Set("content", api.ToolProperty{
		Type:        api.PropertyType{"string"},
		Description: "The text content of the file",
	})

	createFileTool := api.Tool{
		Type: "function",
		Function: api.ToolFunction{
			Name:        "create_file",
			Description: "Creates a text file on the user's system",
			Parameters: api.ToolFunctionParameters{
				Type:       "object",
				Properties: properties,
				Required:   []string{"filename", "directory", "content"},
			},
		},
	}

	return createFileTool
}

func CreateFile(filename string, dir string, content string) error {
	fmt.Printf("Filename: %s\nDirectory: %s\nContent:%s\n", filename, dir, content)

	homeDir, err := os.UserHomeDir()
	if err != nil {
		fmt.Printf("Error while getting home dir :%v\n", err)
		return err
	}

	fileLocation := filepath.Join(homeDir, dir, filename)

	if err := os.WriteFile(fileLocation, []byte(content), 0755); err != nil {
		fmt.Printf("Error while writing file: %v\n", err)
		return err
	}

	return nil
}
