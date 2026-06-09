package ollama

import (
	"context"
	"fmt"
	"log"

	"github.com/ollama/ollama/api"
)

type OllamaRequest struct {
	Ctx    context.Context
	Client api.Client
	Model  string
}

func InitializeOllama() *OllamaRequest {
	client, err := api.ClientFromEnvironment()
	if err != nil {
		log.Fatalf("Failed to create client from environment: %v\n", err)
	}

	ctx := context.Background()

	model := "gemma4:e2b"

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
		client.Pull(ctx, &api.PullRequest{
			Model: model,
		}, func(resp api.ProgressResponse) error {
			if resp.Total > 0 {
				percent := (float64(resp.Completed)) / (float64(resp.Total * 100))
				fmt.Printf("Status: %s (%.2f%% completed)\n", resp.Status, percent)
			} else {
				fmt.Printf("Status: %s\n", resp.Status)
			}

			return nil
		})
	}

	return &OllamaRequest{
		Ctx:    ctx,
		Client: *client,
		Model:  model,
	}
}

func (r *OllamaRequest) GenerateFromText(message string) {
	req := &api.GenerateRequest{
		Model:  r.Model,
		Prompt: message,
	}

	respFunc := func(resp api.GenerateResponse) error {
		if resp.Thinking != "" {
			fmt.Print(resp.Thinking)
		}

		if resp.Response != "" {
			fmt.Print(resp.Response)
		}

		return nil
	}

	err := r.Client.Generate(r.Ctx, req, respFunc)
	if err != nil {
		log.Fatalf("Error during generation: %sv\n", err)
	}
}
