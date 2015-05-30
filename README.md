# Boundary Docker Plugin

Collects metrics from a docker daemon using the stats api.

### Prerequisites

#### Supported OS

|     OS    | Linux | Windows | SmartOS | OS X |
|:----------|:-----:|:-------:|:-------:|:----:|
| Supported |   v   |    v    |    v    |  v   |

#### Boundary Meter Versions V4.0 or Greater 

- To install new meter go to Settings->Installation or [see instructons](https://help.boundary.com/hc/en-us/sections/200634331-Installation).
- To upgrade the meter to the latest version - [see instructons](https://help.boundary.com/hc/en-us/articles/201573102-Upgrading-the-Boundary-Meter).

### Plugin Setup

Docker must run in deamon mode binded to a host and port. You can do this running Docker with the following command line:

```
$ sudo docker -H 127.0.0.0.1:2375 -d
```

Or edit the **/etc/default/docker_** and add **DOCKER_OPTS="-H 127.0.0.1:2375"** then restart the service

```
$ sudo service docker restart
``` 

### Plugin Configuration Fields

|Field Name|Description                                                |
|:---------|:----------------------------------------------------------|
|Port      |The Docker Daemon port.                                        |
|Host      |The Docker Daemon hostname.                                    |
|Poll Interval | How often (in milliseconds) to poll the Couchbase node for metrics. |
|Source | The source to display in the legend for the data. |

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

### Dashboards

- Docker Summary

### References

https://docs.docker.com/reference/api/docker_remote_api/
