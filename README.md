TrueSight Pulse Docker Meter Plugin
===================================

Collects metrics from the Docker daemon using the remote api.

### Prerequisites

|     OS    | Linux | Windows | SmartOS | OS X |
|:----------|:-----:|:-------:|:-------:|:----:|
| Supported |   v   |    v    |    v    |  v   |

This plugin is compatible with Docker 1.7.1 or later.

#### TrueSight Pulse Meter versions v4.2 or later 

- To install new meter go to Settings->Installation or [see instructions](https://help.boundary.com/hc/en-us/sections/200634331-Installation).
- To upgrade the meter to the latest version - [see instructions](https://help.boundary.com/hc/en-us/articles/201573102-Upgrading-the-Boundary-Meter).

### Plugin Setup

Docker must run in deamon mode binded to a host and port. You can do this running Docker with the following command line:

```
$ sudo docker -H 127.0.0.1:2375 -d
```

Or edit the __/etc/default/docker__ and add __DOCKER_OPTS="-H 127.0.0.1:2375"__ then restart the service

```
$ sudo service docker restart
``` 

### Plugin Configuration Fields

|Field Name   |Description                                                      |
|:------------|:----------------------------------------------------------------|
|Host         |The Docker Daemon hostname                                       |
|Port         |The Docker Daemon port                                           |
|Containers   |Filter containers by name. If empty, it will show all containers |
|Poll Interval|How often (in milliseconds) to poll for metrics                  |
|Source       |The source to display in the legend for the data.                |

### Metrics Collected

|Metric Name                    |Description                                         |
|:------------------------------|:---------------------------------------------------|
|DOCKER\_TOTAL\_CPU\_USAGE      |Total cpu usage, total and per running containers   |
|DOCKER\_MEMORY\_USAGE\_BYTES   |Total memory usage, total and per running containers|
|DOCKET\_MEMORY\_USAGE\_PERCENT |Memory usage percentage.                            |
|DOCKER\_NETWORK\_TX\_BYTES     |Total network transmit bytes                        |
|DOCKER\_NETWORK\_RX\_BYTES     |Total network received bytes                        |
|DOCKER\_NETWORK\_TX\_PACKETS   |Total network transmit packets                      |
|DOCKER\_NETWORK\_RX\_PACKETS   |Total network received packets                      |
|DOCKER\_NETWORK\_TX\_ERRORS    |Total network transmit errors                       |
|DOCKER\_NETWORK\_RX\_ERRORS    |Total network received errors                       |
|DOCKER\_BLOCK\_IO\_READ_BYTES  |Total number of Block IO reads bytes                |
|DOCKER\_BLOCK\_IO\_WRITE_BYTES |Total number of Block IO writes bytes               |

### Dashboards

- Docker Summary

### References

https://docs.docker.com/reference/api/docker_remote_api/

