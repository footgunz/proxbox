# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Proxbox is a lightweight HTTP and SOCKS5 proxy server written in Go. It's designed as a command-line tool that can run both proxy types simultaneously on different ports.

## Core Architecture

- **Entry Point**: `main.go` → delegates to `cmd.Execute()`
- **CLI Framework**: Uses Cobra for command-line interface in `cmd/root.go`
- **Proxy Logic**: All proxy implementations in `internal/proxy/proxy.go`
- **Concurrent Design**: HTTP and SOCKS5 proxies run in separate goroutines
- **Logging**: Uses zap logger with structured logging and named loggers for different components

### Key Components

- `cmd/root.go`: CLI command definition with flags for HTTP port (`--http-port`, `-p`), SOCKS port (`--socks-port`, `-s`), verbose mode (`--verbose`, `-v`), and quiet mode (`--quiet`, `-q`)
- `internal/proxy/proxy.go`: Contains `StartHTTPProxy()` and `StartSocksProxy()` functions with three output modes
- HTTP proxy supports both direct HTTP requests and CONNECT method for HTTPS tunneling
- SOCKS5 proxy uses the `github.com/armon/go-socks5` library with custom connection logging

### Output Modes

- **Default mode**: Shows port information on startup, then animated cursor (|/-\) on new line for each request - provides clear startup info and visual feedback without verbose logging
- **Verbose mode** (`--verbose`): Shows detailed structured logs for debugging and monitoring
- **Quiet mode** (`--quiet`): Suppresses all normal output (stderr still available for errors)

## Build Commands

### Development Build
```bash
go build -o proxbox
```

### Production Builds (Cross-platform)
```bash
make                    # Builds all platforms
make linux-amd64       # Linux x86_64
make linux-arm64       # Linux ARM64  
make darwin-amd64      # macOS x86_64
make darwin-arm64      # macOS ARM64
```

### Docker
```bash
make docker-build      # Builds multi-platform Docker image
```

### Clean Build Artifacts
```bash
make clean             # Removes dist/ directory
```

## Running the Application

```bash
# Default mode with cursor animations (HTTP: 8889, SOCKS: 8890)
./proxbox

# Custom ports  
./proxbox --http-port 8080 --socks-port 1080

# Verbose mode with detailed logs
./proxbox --verbose

# Quiet mode with no output
./proxbox --quiet
```

## Dependencies

- `github.com/spf13/cobra`: CLI framework
- `github.com/armon/go-socks5`: SOCKS5 proxy implementation
- `go.uber.org/zap`: Structured logging
- Go 1.23.4+ required

## Testing

No test framework is currently configured in this project.

## Code Patterns

- Structured logging with named loggers (`http`, `socks`, `proxy`)
- Error handling with proper error wrapping and logging
- Goroutine-based concurrent server architecture
- Standard Go project layout with `cmd/`, `internal/`, and `main.go`