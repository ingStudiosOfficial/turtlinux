package tools

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/ollama/ollama/api"
)

type ListDirArgs struct {
	Directory string `json:"Directory"`
}

func GetListDirTool() api.Tool {
	properties := api.NewToolPropertiesMap()

	properties.Set("directory", api.ToolProperty{
		Type:        api.PropertyType{"string"},
		Description: "The directory you want to list",
	})

	listDirTool := api.Tool{
		Type: "function",
		Function: api.ToolFunction{
			Name:        "list_directory",
			Description: "Lists the contents in a given directory",
			Parameters: api.ToolFunctionParameters{
				Type:       "object",
				Properties: properties,
				Required:   []string{"directory"},
			},
		},
	}

	return listDirTool
}

func ListDirectory(dir string) (string, error) {
	homeDir, err := os.UserHomeDir()
	if err != nil {
		fmt.Printf("Error while getting home dir :%v\n", err)
		return "", err
	}

	fullFilepath := filepath.Join(homeDir, dir)

	entries, err := os.ReadDir(fullFilepath)
	if err != nil {
		fmt.Printf("An error occurred while reading directory: %v\n", err)
		return "", err
	}

	var builder strings.Builder

	for _, entry := range entries {
		fmt.Fprint(&builder, "- ", entry.Name(), " (Is directory: ", entry.IsDir(), ")\n")
	}

	entriesString := builder.String()

	fmt.Printf("Entries string: %s\n", entriesString)

	return entriesString, nil
}
