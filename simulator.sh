#!/bin/bash

# Author: Deelesi Suanu
# Description: Source Request Simulator is an alternative tool to jmeter and k6 cli for stress testing api requests
# Usage: Please refer to README on this repository.

# Default configurations
url="https://example.com/api" # Default API endpoint
method="GET" # Default HTTP method
headers=() # Default headers array
payload="" # Default payload for POST requests
log_file="requests_log.txt" # Default log file
num_requests=10 # Default number of requests
duration="10s" # Default duration
concurrent_requests=5 # Default concurrency level
config_file="" # Default config file (none)
retry_count=3 # Default retry count
retry_delay=2 # Default retry delay in seconds
dry_run=false # Default dry run mode
log_format="text" # Default log format (text/json)

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -u|--url)
      url="$2"
      shift 2
      ;;
    -m|--method)
      method="$2"
      shift 2
      ;;
    -H|--header)
      headers+=("$2")
      shift 2
      ;;
    -p|--payload)
      payload="$2"
      shift 2
      ;;
    -n|--num-requests)
      num_requests="$2"
      shift 2
      ;;
    -d|--duration)
      duration="$2"
      shift 2
      ;;
    -c|--concurrent)
      # shellcheck disable=SC2034
      concurrent_requests="$2"
      shift 2
      ;;
    -f|--config)
      config_file="$2"
      shift 2
      ;;
    -l|--log-file)
      log_file="$2"
      shift 2
      ;;
    -r|--retry)
      # shellcheck disable=SC2034
      retry_count="$2"
      shift 2
      ;;
    -rd|--retry-delay)
      # shellcheck disable=SC2034
      retry_delay="$2"
      shift 2
      ;;
    -dr|--dry-run)
      dry_run=true
      shift
      ;;
    -lf|--log-format)
      log_format="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [options]"
      # shellcheck disable=SC2028
      echo "\nOptions:"
      echo " -u, --url <url>             API endpoint (default: https://example.com/api)"
      echo " -m, --method <method>       HTTP method (GET, POST, PUT, DELETE, PATCH; default: GET)"
      echo " -H, --header <header>       Add custom header (can be used multiple times)"
      echo " -p, --payload <payload>     Payload for POST/PUT requests"
      echo " -n, --num-requests <number> Total number of requests (default: 10)"
      echo " -d, --duration <duration>   Duration for requests (e.g., 10s, 1m, 1h; default: 10s)"
      echo " -c, --concurrent <number>   Number of concurrent requests (default: 5)"
      echo " -f, --config <file>         Configuration file (JSON format)"
      echo " -l, --log-file <file>       Log file (default: requests_log.txt)"
      echo " -r, --retry <number>        Retry attempts for failed requests (default: 3)"
      echo " -rd, --retry-delay <seconds> Delay between retries (default: 2)"
      echo " -dr, --dry-run              Simulate requests without sending them"
      echo " -lf, --log-format <format>  Log format: text or json (default: text)"
      echo " -h, --help                  Display this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Load configuration from file if specified
if [[ -n "$config_file" ]]; then
  if [[ -f "$config_file" ]]; then
    config=$(<"$config_file")
    url=$(echo "$config" | jq -r '.url // empty')
    method=$(echo "$config" | jq -r '.method // "GET"')
    payload=$(echo "$config" | jq -r '.payload // ""')
    headers=($(echo "$config" | jq -r '.headers[] // empty'))
    num_requests=$(echo "$config" | jq -r '.num_requests // 10')
    log_file=$(echo "$config" | jq -r '.log_file // "requests_log.txt"')
  else
    echo "Configuration file not found: $config_file"
    exit 1
  fi
fi

# Function to send a single request
send_request() {
  local url="$1"
  local method="$2"
  local headers=("${@:3}")
  local payload="$4"

  # Build curl command
  curl_cmd=("curl -s -o /dev/null -w \"%{http_code} %{time_total}\" -X $method")
  for header in "${headers[@]}"; do
    curl_cmd+=("-H \"$header\"")
  done
  if [[ -n "$payload" ]]; then
    curl_cmd+=("-d \"$payload\"")
  fi
  curl_cmd+=("$url")

  if [[ "$dry_run" == true ]]; then
    # shellcheck disable=SC2145
    echo "Dry run: ${curl_cmd[@]}"
  else
    # shellcheck disable=SC2294
    eval "${curl_cmd[@]}"
  fi
}

# Function to log request results
log_request() {
  local request_id="$1"
  local status="$2"
  local time="$3"

  if [[ "$log_format" == "json" ]]; then
    echo "{\"request_id\":$request_id,\"status\":$status,\"time\":$time}" >> "$log_file"
  else
    echo "Request #$request_id: Status $status, Time ${time}ms" >> "$log_file"
  fi
}

# Send requests
for ((i=1; i<=num_requests; i++)); do
  result=$(send_request "$url" "$method" "${headers[@]}" "$payload")
  status=$(echo "$result" | awk '{print $1}')
  time=$(echo "$result" | awk '{print $2}')
  log_request "$i" "$status" "$time"
  sleep $((duration / num_requests))
done
