# Source Request Simulator

Source Request Simulator is an alternative tool to jmeter and k6 cli for stress testing api requests

## Features
- Supports GET and POST requests
- Handles JSON payloads
- Simple to use and extend

## Installation
To install the script, run the following commands:

```bash
curl -O https://raw.githubusercontent.com/deelesisuanu/source-request-simulator/main/install.sh
chmod +x install.sh
./install.sh
```

## Options:

```bash
Usage: ./simulator.sh [options]
```

```bash
 -u, --url <url>             API endpoint (default: https://example.com/api)
 -m, --method <method>       HTTP method (GET, POST, PUT, DELETE, PATCH; default: GET)
 -H, --header <header>       Add custom header (can be used multiple times)
 -p, --payload <payload>     Payload for POST/PUT requests
 -n, --num-requests <number> Total number of requests (default: 10)
 -d, --duration <duration>   Duration for requests (e.g., 10s, 1m, 1h; default: 10s)
 -c, --concurrent <number>   Number of concurrent requests (default: 5)
 -f, --config <file>         Configuration file (JSON format)
 -l, --log-file <file>       Log file (default: requests_log.txt)
 -r, --retry <number>        Retry attempts for failed requests (default: 3)
 -rd, --retry-delay <seconds> Delay between retries (default: 2)
 -dr, --dry-run              Simulate requests without sending them
 -lf, --log-format <format>  Log format: text or json (default: text)
 -h, --help                  Display this help message
```

### Basic GET Requests

#### Send 5 GET requests to the API https://api.example.com/data.
```bash
./simulator.sh -u "https://api.example.com/data" -n 5 -m GET
```

#### Expected log entry (text format):
```bash
Request #1: Status 200, Time 150ms
Request #2: Status 200, Time 160ms
...
```

### POST Request with Payload
```bash
./simulator.sh -u "https://api.example.com/submit" -m POST -p '{"name":"John", "age":30}' -H "Content-Type: application/json"
```

#### Expected log entry (text format):
```bash
Request #1: Status 201, Time 200ms
```

### Using Configuration File
Create a config.json file:

```bash
{
  "url": "https://api.example.com/config",
  "method": "POST",
  "payload": "{\"key\":\"value\"}",
  "headers": ["Content-Type: application/json", "Authorization: Bearer abc123"],
  "num_requests": 3,
  "log_file": "config_log.txt"
}
```

Run the script
```bash
./simulator.sh -f config.json
```

### Concurrent Requests
Send 50 requests concurrently over 30 seconds:

```bash
./simulator.sh -u "https://api.example.com/stress" -n 50 -d 30s -c 10
```

### Retry Logic for Unstable Endpoints
Retry failed requests up to 5 times with a 3-second delay:

```bash
./simulator.sh -u "https://api.example.com/retry" -r 5 -rd 3
```

### Dry Run Mode
Preview the requests without sending them:

```bash
./simulator.sh -u "https://api.example.com/test" -n 2 -dr
```

#### Output:
```bash
  Dry run: Would send GET request to https://api.example.com/test with headers: [] and payload:
```

