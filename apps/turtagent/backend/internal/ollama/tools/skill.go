package tools

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/ollama/ollama/api"
)

type GetSkillArgs struct {
	Name string `json:"name"`
}

func GetGetSkillTool() api.Tool {
	properties := api.NewToolPropertiesMap()

	properties.Set("name", api.ToolProperty{
		Type:        api.PropertyType{"string"},
		Description: "The name of the skill to retrieve",
	})

	getSkillTool := api.Tool{
		Type: "function",
		Function: api.ToolFunction{
			Name:        "get_skill",
			Description: "Gets a skill provided which is a set of instructions that guide you on performing tasks",
			Parameters: api.ToolFunctionParameters{
				Type:       "object",
				Properties: properties,
				Required:   []string{"name"},
			},
		},
	}

	return getSkillTool
}

func GetSkill(name string) (string, error) {
	skillLocation := filepath.Join("assets", "skills", name+".md")

	content, err := os.ReadFile(skillLocation)
	if err != nil {
		fmt.Printf("Error while reading skill: %v\n", err)
		return "", err
	}

	return string(content) + "\nUse this skill to help fulfil your original task. ", nil
}
