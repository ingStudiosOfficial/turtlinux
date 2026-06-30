package tools

import (
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/ollama/ollama/api"
)

type PlasmoidArguments struct {
	Id          string
	Title       string
	Description string
	Body        string
}

type KPluginData struct {
	Name        string `json:"name"`
	Icon        string `json:"icon"`
	Description string `json:"description"`
	Id          string `json:"id"`
}

type PlasmoidMetadata struct {
	KPlugin                      KPluginData `json:"KPlugin"`
	KPackageStructure            string      `json:"KPackageStructure"`
	XKDEPluginInfoKPluginVersion string      `json:"X-KDE-PluginInfo-KPluginVersion"`
	XPlasmaAPIMinimumVersion     string      `json:"X-Plasma-API-Minimum-Version"`
}

func GetPlasmoidTool() api.Tool {
	propeties := api.NewToolPropertiesMap()

	propeties.Set("id", api.ToolProperty{
		Type:        api.PropertyType{"string"},
		Description: "The identifier of the plasmoid widget (should be one word, no spacing or hyphens)",
	})

	propeties.Set("title", api.ToolProperty{
		Type:        api.PropertyType{"string"},
		Description: "The title of the plasmoid widget",
	})

	propeties.Set("description", api.ToolProperty{
		Type:        api.PropertyType{"string"},
		Description: "A brief description of the plasmoid widget",
	})

	propeties.Set("body", api.ToolProperty{
		Type:        api.PropertyType{"string"},
		Description: "The content of the plasmoid widget",
	})

	plasmoidTool := api.Tool{
		Type: "function",
		Function: api.ToolFunction{
			Name:        "create_plasmoid_widget",
			Description: "Creates a plasmoid widget based on the data you give it",
			Parameters: api.ToolFunctionParameters{
				Type:       "object",
				Properties: propeties,
				Required:   []string{"id", "title", "description", "body"},
			},
		},
	}

	return plasmoidTool
}

func CreatePlasmoid(id string, title string, description string, body string) error {
	fullID := fmt.Sprintf("dev.ingstudios.turtlinux.turtagent.%s", id)

	metadataObj := PlasmoidMetadata{
		KPlugin: KPluginData{
			Name:        title,
			Icon:        "turtagent-plasmoid",
			Description: description,
			Id:          fullID,
		},
		KPackageStructure:            "Plasma/Applet",
		XKDEPluginInfoKPluginVersion: "6.0",
		XPlasmaAPIMinimumVersion:     "6.0",
	}

	metadataBytes, err := json.MarshalIndent(metadataObj, "", "    ")
	if err != nil {
		return fmt.Errorf("failed to marshal metadata: %v", err)
	}

	qmlEscaper := strings.NewReplacer(
		`\`, `\\`,
		`"`, `\"`,
		"\n", `\n`,
		"\r", `\r`,
		"\t", `\t`,
	)

	esTitle := qmlEscaper.Replace(title)
	esBody := qmlEscaper.Replace(body)

	plasmoidQml := fmt.Sprintf(`import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents

PlasmoidItem {
    id: root

    fullRepresentation: Item {
        Layout.preferredWidth: 200

        ColumnLayout {
            anchors.centerIn: parent

            PlasmaComponents.Label {
                text: "%s"
                font.pointSize: 12
				width: parent.width
				wrapMode: Text.WordWrap
            }

            PlasmaComponents.Label {
                text: "%s"
                font.pointSize: 8
				width: parent.width
				wrapMode: Text.WordWrap
            }
        }
    }
}`, esTitle, esBody)

	homeDir, err := os.UserHomeDir()
	if err != nil {
		return fmt.Errorf("failed to get home directory: %v", err)
	}

	baseDir := fmt.Sprintf("%s/.local/share/plasma/plasmoids/%s", homeDir, fullID)
	uiDir := baseDir + "/contents/ui"

	_ = os.RemoveAll(baseDir)

	if err := os.MkdirAll(uiDir, 0755); err != nil {
		return fmt.Errorf("failed to create directory: %v", err)
	}

	if err := os.WriteFile(uiDir+"/main.qml", []byte(plasmoidQml), 0644); err != nil {
		return fmt.Errorf("failed to write QML: %v", err)
	}

	if err := os.WriteFile(baseDir+"/metadata.json", metadataBytes, 0644); err != nil {
		return fmt.Errorf("failed to write metadata: %v", err)
	}

	iconSrc := "assets/icons/turtagent-plasmoid.svg"
	hicolorIconsDir := homeDir + "/.local/share/icons/hicolor"
	iconDist := hicolorIconsDir + "/scalable/apps/turtagent-plasmoid.svg"

	if !fileExists(iconDist) {
		srcFile, err := os.Open(iconSrc)
		if err != nil {
			fmt.Printf("Error while opening icon: %v\n", err)
			return err
		}
		defer srcFile.Close()

		distDir := filepath.Dir(iconDist)
		if err := os.MkdirAll(distDir, 0755); err != nil {
			fmt.Printf("Error while creating directory: %v\n", err)
			return err
		}

		distFile, err := os.Create(iconDist)
		if err != nil {
			fmt.Printf("Error while creating icon file: %v\n", err)
			return err
		}
		defer distFile.Close()

		if _, err := io.Copy(distFile, srcFile); err != nil {
			fmt.Printf("Error while copying icon file: %v\n", err)
			return err
		}

		if err := distFile.Sync(); err != nil {
			fmt.Printf("Failed to sync dist file: %v\n", err)
			return err
		}

		cmd := exec.Command("gtk-update-icon-cache", "-f", "-t", hicolorIconsDir)
		if output, err := cmd.CombinedOutput(); err != nil {
			fmt.Printf("Error while updating icon cache: %s\n", output)
			return err
		}
	}

	return nil
}

func fileExists(filename string) bool {
	_, err := os.Stat(filename)
	if err == nil {
		return true
	}
	if errors.Is(err, os.ErrNotExist) {
		return false
	}

	return false
}
