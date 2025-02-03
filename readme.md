# proxbox

A lightweight(ish) HTTP and SOCKS5 proxy server in Go designed to be run as a command line tool.

## Features

- HTTP proxy with CONNECT support for HTTPS
- SOCKS5 proxy
- Detailed logging
- Cross-platform support 

## Installation

### From Source

1. Clone the repository:
   ```bash
   git clone https://github.com/footgunz/proxbox.git
   ```


## Usage

```bash
proxbox --http-port 8889 --socks-port 8890
```

### Connecting via HTTP Proxy

#### curl
```bash
curl --proxy http://localhost:8889 https://example.com
```

#### Firefox
1. Settings → Network Settings
2. Configure Proxy Access to the Internet
3. Manual proxy configuration:
   - SOCKS Host: localhost
   - Port: 8890
   - SOCKS v5: Yes

## Building

### All Platforms

```bash
make
```

### Specific Platform

```bash
make linux-amd64    # Linux x86_64
make linux-arm64    # Linux ARM64
make darwin-amd64   # macOS x86_64
make darwin-arm64   # macOS ARM64
```


### Docker
Docker image is only built on-demand.

```bash
make docker-build
```

#### Sample Docker Usage

```bash
docker run -p 8889:8889 -p 8890:8890 proxbox
```

## License

MIT License - see LICENSE file for details
