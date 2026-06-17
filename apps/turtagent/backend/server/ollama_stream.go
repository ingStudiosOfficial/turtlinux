package server

import (
	"context"
	"fmt"
	"turtagent/backend/internal/ollama"
	pb "turtagent/backend/protobuf"
)

type Server struct {
	pb.UnimplementedTurtAgentStreamServiceServer
	Ollama *ollama.OllamaRequest
}

func (s *Server) GenerateResponse(req *pb.PromptRequest, stream pb.TurtAgentStreamService_GenerateResponseServer) error {
	ctx := stream.Context()

	err := s.Ollama.GenerateFromText(req.Prompt, func(chunk string, isThinking bool) error {
		select {
		case <-ctx.Done():
			fmt.Println("Client stopped the stream.")
			return context.Canceled
		default:
		}

		return stream.Send(&pb.PromptResponse{
			TextChunk:  chunk,
			IsThinking: isThinking,
			IsFinal:    false,
		})
	})

	if err != nil {
		return err
	}

	return stream.Send(&pb.PromptResponse{
		IsFinal: true,
	})
}
