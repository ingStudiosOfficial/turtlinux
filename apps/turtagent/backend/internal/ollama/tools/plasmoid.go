package tools

import (
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
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
	Name         string   `json:"Name"`
	Icon         string   `json:"Icon"`
	Description  string   `json:"Description"`
	Id           string   `json:"Id"`
	ServiceTypes []string `json:"ServiceTypes"`
}

type PlasmoidMetadata struct {
	KPlugin           KPluginData `json:"KPlugin"`
	KPackageStructure string      `json:"KPackageStructure"`
	XPlasmaAPI        string      `json:"X-Plasma-API"`
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
			Name:         title,
			Icon:         "application-utilities",
			Description:  description,
			Id:           fullID,
			ServiceTypes: []string{"Plasma/Applet"},
		},
		KPackageStructure: "Plasma/Applet",
		XPlasmaAPI:        "declarativeappletscript",
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
        Layout.preferredHeight: 200

        ColumnLayout {
            anchors.centerIn: parent

            PlasmaComponents.Label {
                text: "%s"
                font.pointSize: 16
            }

            PlasmaComponents.Label {
                text: "%s"
                font.pointSize: 12
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

	kpackageCmd := exec.Command("bash", "-c", fmt.Sprintf(`kpackagetool6 --type Plasma/Applet --list | grep "%s"`, fullID))
	kpackageOutput, _ := kpackageCmd.CombinedOutput()
	fmt.Printf("kpackage lookup output: %s\n", string(kpackageOutput))

	reloadCmd := exec.Command("bash", "-c", `plasmoidviewer6 --reload 2>/dev/null || systemctl --user restart plasma-plasmashell 2>/dev/null || (killall plasmashell && kstart plasmashell)`)
	_ = reloadCmd.Run()

	return nil
}
