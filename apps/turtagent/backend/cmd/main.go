package main

import (
	"fmt"
	"log"
	"net"
	"turtagent/backend/internal/ollama"
	"turtagent/backend/server"

	pb "turtagent/backend/protobuf"

	"google.golang.org/grpc"
)

func main() {
	ollamaRegistry := ollama.InitializeOllama()

	port := ":50707"
	listener, err := net.Listen("tcp", port)
	if err != nil {
		log.Fatalf("Failed to bind to port %s\n", err)
	}

	grpcServer := grpc.NewServer()

	turtAgentServer := &server.Server{
		Ollama: ollamaRegistry,
	}

	pb.RegisterTurtAgentStreamServiceServer(grpcServer, turtAgentServer)

	fmt.Printf("TurtAgent backend server listening on: %s\n", port)
	if err := grpcServer.Serve(listener); err != nil {
		log.Fatalf("Failed to start gRPC engine: %v\n", err)
	}
}
