package ollama

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"os/exec"
	"strconv"
	"strings"
	"turtagent/backend/internal/ollama/skills"
	"turtagent/backend/internal/ollama/tools"

	"github.com/ollama/ollama/api"
)

type OllamaRequest struct {
	Ctx     context.Context
	Client  *api.Client
	Model   string
	History []api.Message
}

func InitializeOllama() *OllamaRequest {
	client, err := api.ClientFromEnvironment()
	if err != nil {
		log.Fatalf("Failed to create client from environment: %v\n", err)
	}

	ctx := context.Background()

	model := "tutel:latest"

	modelsResp, err := client.List(ctx)
	if err != nil {
		log.Fatalf("Error listing models: %s\n", err)
	}

	hasModel := false
	for _, listedModel := range modelsResp.Models {
		if listedModel.Name == model {
			hasModel = true
			break
		}
	}

	if hasModel == false {
		cmd := exec.Command("sh", "-c", "cd ../model && chmod +x ./buildmodel.sh && ./buildmodel.sh")

		output, err := cmd.CombinedOutput()
		if err != nil {
			log.Fatalf("error while creating model: %v\nOutput: %s\n", err, output)
		}
	}

	conversationHistory := []api.Message{}

	return &OllamaRequest{
		Ctx:     ctx,
		Client:  client,
		Model:   model,
		History: conversationHistory,
	}
}

func (r *OllamaRequest) GenerateFromText(message string, sendChunk func(string, bool) error) error {
	r.History = append(r.History, api.Message{
		Role:    "user",
		Content: message,
	})

	skills, err := skills.GetAllSkills()
	if err != nil {
		log.Fatalf("error while getting skills: %v\n", err)
	}

	fmt.Printf("Skills: %s\n", skills)

	r.History = append(r.History, api.Message{
		Role:    "system",
		Content: "Available skills (use get_skill if required):\n" + skills,
	})

	toolsCalled := []string{}

	for {
		req := &api.ChatRequest{
			Model:    r.Model,
			Think:    &api.ThinkValue{Value: "medium"},
			Messages: r.History,
			Tools: []api.Tool{
				tools.GetWindowsTool(),
				tools.GetPlasmoidTool(),
				tools.GetCreateFileTool(),
				tools.GetListDirTool(),
				tools.GetGetSkillTool(),
			},
		}

		var toolCalls []api.ToolCall

		finalResp := ""

		respFunc := func(resp api.ChatResponse) error {
			if resp.Message.Thinking != "" {
				fmt.Print(resp.Message.Thinking)
				if err := sendChunk(resp.Message.Thinking, true); err != nil {
					return err
				}
			}

			if resp.Message.Content != "" {
				fmt.Print(resp.Message.Content)
				finalResp += resp.Message.Content
				if err := sendChunk(resp.Message.Content, false); err != nil {
					return err
				}
			}

			if len(resp.Message.ToolCalls) > 0 {
				toolCalls = append(toolCalls, resp.Message.ToolCalls...)
			}

			return nil
		}

		err := r.Client.Chat(r.Ctx, req, respFunc)
		if err != nil {
			return fmt.Errorf("error during generation: %v\n", err)
		}

		if len(toolCalls) == 0 {
			r.History = append(r.History, api.Message{
				Role:    "assistant",
				Content: finalResp,
			})
			return nil
		}

		r.History = append(r.History, api.Message{
			Role:      "assistant",
			Content:   finalResp,
			ToolCalls: toolCalls,
		})

		for _, toolCall := range toolCalls {
			switch toolCall.Function.Name {
			case "get_windows":
				windows := tools.GetWindows()
				r.History = append(r.History, api.Message{
					Role:    "tool",
					Content: windows,
				})

			case "create_plasmoid_widget":
				jsonBytes, err := json.Marshal(toolCall.Function.Arguments)
				if err != nil {
					r.History = append(r.History, api.Message{
						Role:    "tool",
						Content: "An error occurred while creating plasmoid widget.",
					})
					break
				}

				var plasmoidArgs tools.PlasmoidArguments
				if err := json.Unmarshal(jsonBytes, &plasmoidArgs); err != nil {
					r.History = append(r.History, api.Message{
						Role:    "tool",
						Content: "An error occurred while creating plasmoid widget.",
					})
					break
				}

				if err := tools.CreatePlasmoid(plasmoidArgs.Id, plasmoidArgs.Title, plasmoidArgs.Description, plasmoidArgs.Body); err != nil {
					fmt.Printf("An error occurred while creating plasmoid: %v\n", err)
					r.History = append(r.History, api.Message{
						Role:    "tool",
						Content: fmt.Sprintf("An error occurred while creating plasmoid widget: %v", err),
					})
					break
				}

				r.History = append(r.History, api.Message{
					Role:    "tool",
					Content: "Successfully created plasmoid widget. Tell the user that the widget is ready to be added to their desktop.",
				})

			case "create_file":
				jsonBytes, err := json.Marshal(toolCall.Function.Arguments)
				if err != nil {
					r.History = append(r.History, api.Message{
						Role:    "tool",
						Content: "An error occurred while creating file.",
					})
					break
				}

				var fileArgs tools.CreateFileArgs
				if err := json.Unmarshal(jsonBytes, &fileArgs); err != nil {
					r.History = append(r.History, api.Message{
						Role:    "tool",
						Content: "An error occurred while creating file.",
					})
					break
				}

				if err := tools.CreateFile(fileArgs.Name, fileArgs.Dir, fileArgs.Content); err != nil {
					r.History = append(r.History, api.Message{
						Role:    "tool",
						Content: fmt.Sprintf("An error occurred while creating file: %v", err),
					})
					break
				}

				r.History = append(r.History, api.Message{
					Role:    "tool",
					Content: "Successfully created file.",
				})

			case "list_directory":
				jsonBytes, err := json.Marshal(toolCall.Function.Arguments)
				if err != nil {
					r.History = append(r.History, api.Message{
						Role:    "tool",
						Content: "An error occurred while listing directory.",
					})
					break
				}

				var dirArgs tools.ListDirArgs
				if err := json.Unmarshal(jsonBytes, &dirArgs); err != nil {
					r.History = append(r.History, api.Message{
						Role:    "tool",
						Content: "An error occurred while listing directory.",
					})
					break
				}

				contents, err := tools.ListDirectory(dirArgs.Directory)
				if err != nil {
					r.History = append(r.History, api.Message{
						Role:    "tool",
						Content: fmt.Sprintf("An error occurred while listing directory: %v", err),
					})
					break
				}

				fmt.Println("Directory contents: " + contents)

				r.History = append(r.History, api.Message{
					Role:    "tool",
					Content: contents,
				})

			case "get_skill":
				jsonBytes, err := json.Marshal(toolCall.Function.Arguments)
				if err != nil {
					r.History = append(r.History, api.Message{
						Role:    "tool",
						Content: "An error occurred while getting skill.",
					})
					break
				}

				var getSkillArgs tools.GetSkillArgs
				if err := json.Unmarshal(jsonBytes, &getSkillArgs); err != nil {
					r.History = append(r.History, api.Message{
						Role:    "tool",
						Content: "An error occurred while getting skill.",
					})
					break
				}

				skill, err := tools.GetSkill(getSkillArgs.Name)
				if err != nil {
					r.History = append(r.History, api.Message{
						Role:    "tool",
						Content: "An error occurred while getting skill.",
					})
					break
				}

				r.History = append(r.History, api.Message{
					Role:    "tool",
					Content: skill,
				})
			}

			toolsCalled = append(toolsCalled, toolCall.Function.Name)

			var builder strings.Builder

			for i, tool := range toolsCalled {
				fmt.Fprintf(&builder, "%s. %s", strconv.Itoa(i+1), tool)
			}

			r.History = append(r.History, api.Message{
				Role:    "system",
				Content: "With the result provided when you ran '" + toolCall.Function.Name + "', fulfil the user's original task of: '" + message + "'",
			})

			r.History = append(r.History, api.Message{
				Role:    "system",
				Content: "Tools you have ALREADY called (do not call these again if not needed): " + builder.String(),
			})

			fmt.Println(r.History)
		}
	}
}
