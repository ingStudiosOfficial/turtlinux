package tools

import (
	"fmt"
	"os"
	"os/exec"

	"github.com/ollama/ollama/api"
)

type PlasmoidArguments struct {
	Id          string
	Title       string
	Description string
	Body        string
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
	plasmoidMetadata := fmt.Sprintf(`
{
	"KPlugin": {
		"Name": "%s"
		"Icon": "application-utilities"
		"Description": "%s"
		"Id": "dev.ingstudios.turtlinux.turtagent.%s"
	},
	"X-Plasma-API": "declarativeappletscript",
	"X-Plasma-API-Minimum-Version": "6.0"
}
`, title, description, id)

	fmt.Printf("Plasmoid metadata:\n%s\n", plasmoidMetadata)

	plasmoidQml := fmt.Sprintf(`
import QtQuick
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
})
`, title, body)

	fmt.Printf("Plasmoid QML:\n%s\n", plasmoidQml)

	mdkirCmd := exec.Command("bash", "-c", fmt.Sprintf(`mkdir -p ~/.local/share/plasma/plasmoids/dev.ingstudios.turtlinux.turtagent.%s/contents/ui`, id))

	mkdirOutput, mkdirErr := mdkirCmd.CombinedOutput()
	fmt.Printf("mkdir output: %s\n", mkdirOutput)
	if mkdirErr != nil {
		return mkdirErr
	}

	qmlPath := fmt.Sprintf("~/.local/share/plasma/plasmoids/dev.ingstudios.turtlinux.turtagent.%s/contents/ui/main.qml", id)

	createQmlErr := os.WriteFile(qmlPath, []byte(plasmoidQml), 0644)
	if createQmlErr != nil {
		fmt.Printf("Error while creating QML file: %v\n", createQmlErr)
		return createQmlErr
	}

	metadataPath := fmt.Sprintf("~/.local/share/plasma/plasmoids/dev.ingstudios.turtlinux.turtagent.%s/metadata.json", id)

	createMetadataErr := os.WriteFile(metadataPath, []byte(plasmoidMetadata), 0644)
	if createMetadataErr != nil {
		fmt.Printf("Error while creating metadata file: %v\n", createMetadataErr)
		return createMetadataErr
	}

	kpackageCmd := exec.Command("bash", "-c", `kpackagetool6 --type Plasma/Applet --list | grep com.example.mywidget`)

	kpackageOutput, kpackageErr := kpackageCmd.CombinedOutput()
	fmt.Printf("kpackage output: %s\n", kpackageOutput)
	if kpackageErr != nil {
		return kpackageErr
	}

	kspaceviewerCmd := exec.Command("bash", "-c", `kspaceviewer --reload 2>/dev/null || killall plasmashell && kstart plasmashell`)

	kspaceviewerOutput, kspaceviewerErr := kspaceviewerCmd.CombinedOutput()
	fmt.Printf("kpackage output: %s\n", kspaceviewerOutput)
	if kspaceviewerErr != nil {
		return kspaceviewerErr
	}

	return nil
}
