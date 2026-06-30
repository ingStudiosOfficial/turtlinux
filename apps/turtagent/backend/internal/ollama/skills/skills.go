package skills

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

func GetAllSkills() (string, error) {
	skillsDirLocation := filepath.Join("assets", "skills")

	files, err := os.ReadDir(skillsDirLocation)
	if err != nil {
		return "", err
	}

	var builder strings.Builder

	for _, file := range files {
		fmt.Fprint(&builder, strings.ReplaceAll(file.Name(), ".md", ""), "\n")
	}

	return builder.String(), nil
}
