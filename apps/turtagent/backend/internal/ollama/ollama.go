package ollama

import (
	"context"
	"fmt"
	"log"
	"os/exec"
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
			log.Fatalf("Error while creating model: %v\nOutput: %s\n", err, output)
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

	for {
		req := &api.ChatRequest{
			Model:    r.Model,
			Think:    &api.ThinkValue{Value: "medium"},
			Messages: r.History,
			Tools: []api.Tool{
				tools.WindowsTool,
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
			return fmt.Errorf("Error during generation: %v\n", err)
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
			}
		}
	}
}
