Boundary Docker Plugin
-------------------------

Collects metrics from a docker daemon using the stats api.

https://docs.docker.com/reference/api/docker_remote_api/

## Prerequisites

### Supported OS

|     OS    | Linux | Windows | SmartOS | OS X |
|:----------|:-----:|:-------:|:-------:|:----:|
| Supported |   v   |    v    |    v    |  v   |

#### Boundary Meter Versions V4.0 Or Greater REQUIRED

To get the new meter:

    curl -fsS \
        -d "{\"token\":\"<your API token here>\"}" \
        -H "Content-Type: application/json" \
        "https://meter.boundary.com/setup_meter" > setup_meter.sh
    chmod +x setup_meter.sh
    ./setup_meter.sh

### Plugin Setup

--


#### Plugin Configuration Fields

|Field Name|Description                                                |
|:---------|:----------------------------------------------------------|
|Port      |The Docker Daemon port.                                        |
|Host      |The Docker Daemon hostname.                                    |

### Metrics Collected
|Metric Name          |Description                       |
|:--------------------|:---------------------------------|
| DOCKER_TOTAL_CPU_USAGE | Docker total cpu usage, all running containers
| DOCKER_TOTAL_MEMORY_USAGE | Docker total memory usage, all running containers
| DOCKER_MEAN_MEMORY_USAGE | Docker mean memory usage, all running containers
| DOCKER_MAX_MEMORY_USAGE | Docker max memory usage
| DOCKER_MIN_MEMORY_USAGE | Docker min memory usage
| DOCKER_NETWORK_RX | Docker total network rx, all running containers
| DOCKER_NETWORK_TX | Docker total network tx, all running containers
