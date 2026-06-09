package main

import (
	"bufio"
	"fmt"
	"os"
	"turtagent/backend/internal/ollama"
)

func main() {
	scanner := bufio.NewScanner(os.Stdin)
	fmt.Print("Enter prompt: ")

	if scanner.Scan() {
		input := scanner.Text()
		ollamaRequest := ollama.InitializeOllama()
		ollamaRequest.GenerateFromText(input)
	}
}
