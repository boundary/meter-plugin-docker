# Boundary Docker Plugin

Collects metrics from the Docker daemon using the remote api.

### Prerequisites

|     OS    | Linux | Windows | SmartOS | OS X |
|:----------|:-----:|:-------:|:-------:|:----:|
| Supported |   v   |    v    |    v    |  v   |

This plugin is compatible with Docker 1.7.1 or later.

#### Boundary Meter versions v4.2 or later 

- To install new meter go to Settings->Installation or [see instructions](https://help.boundary.com/hc/en-us/sections/200634331-Installation).
- To upgrade the meter to the latest version - [see instructions](https://help.boundary.com/hc/en-us/articles/201573102-Upgrading-the-Boundary-Meter).

### Plugin Setup

Docker must run in deamon mode binded to a host and port. You can do this running Docker with the following command line:

```
$ sudo docker -H 127.0.0.0.1:2375 -d
```

Or edit the **/etc/default/docker** and add **DOCKER_OPTS="-H 127.0.0.1:2375"** then restart the service

```
$ sudo service docker restart
``` 

### Plugin Configuration Fields

|Field Name|Description                                                |
|:---------|:----------------------------------------------------------|
|Host      |The Docker Daemon hostname                                    |
|Port      |The Docker Daemon port                                        |
|Containers | Filter containers by name. If empty, it will show all containers |
|Poll Interval | How often (in milliseconds) to poll for metrics |
|Source | The source to display in the legend for the data. |

### Metrics Collected

|Metric Name          |Description                       |
|:--------------------|:---------------------------------|
| DOCKER_TOTAL_CPU_USAGE | Docker total cpu usage, total and per running containers |
| DOCKER_MEMORY_USAGE_BYTES | Docker total memory usage, total and per running containers |
| DOCKET_MEMORY_USAGE_PERCENT | Docker memory usage percentage. |
| DOCKER_NETWORK_RX_BYTES | Docker total network rx bytes |
| DOCKER_NETWORK_TX_BYTES | Docker total network tx bytes |
| DOCKER_NETWORK_TX_PACKETS | Docker total network tx packets |
| DOCKER_NETWORK_RX_PACKETS | Docker total network rx packets |
| DOCKER_NETWORK_RX_ERRORS | Docker total network rx errors |
| DOCKER_NETWORK_TX_ERRORS | Docker total network tx errors |

### Dashboards

- Docker Summary

### References

https://docs.docker.com/reference/api/docker_remote_api/

