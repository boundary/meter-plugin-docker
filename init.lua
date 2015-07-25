-- Copyright 2015 Boundary, Inc.
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--    http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local framework = require('framework')
local Plugin = framework.Plugin
local WebRequestDataSource = framework.WebRequestDataSource
local json = require('_json')
local map = framework.functional.map
local clone = framework.table.clone
local hasAny = framework.table.hasAny
local notEmpty = framework.string.notEmpty
local round = framework.util.round
local ipack = framework.util.ipack
local mean = framework.util.mean

local params = framework.params

local options = {}
options.host = notEmpty(params.host, '127.0.0.1')
options.port = notEmpty(params.port, '2375')
options.path = '/containers/json'

local function maxmin(t)
  local max = -math.huge
  local min = math.huge
  for k,v in pairs( t ) do
    if type(v) == 'number' then
      max = math.max( max, v )
      min = math.min( min, v )
    end
  end
  return max, min
end

local function getName(fullName) 
  return string.sub(fullName, 2, -1)
end

local function containerTuple(c)
  return { id = c.Id, name = getName(c.Names[1]) } 
end

local function getContainers(parsed)
  return map(containerTuple, parsed)
end

local pending_requests = {}
local function createDataSource(context, container)
  local opts = clone(options)
  opts.meta = container.name
  opts.path = ('/containers/%s/stats'):format(container.name)
  local data_source = WebRequestDataSource:new(opts)
  data_source:propagate('error', context)
  pending_requests[container.name] = true

  return data_source
end

local ds = WebRequestDataSource:new(options)
ds:chain(function (context, callback, data) 
  --local parsed = json.parse(data)
  local parsed = json:decode(data)
  local data_sources = map(function (container) return createDataSource(context, container) end, getContainers(parsed))
    
  return data_sources
end)

local stats = {}
stats.memory = {}
local plugin = Plugin:new(params, ds)
function plugin:onParseValues(data, extra)
  --local parsed = json.parse(data)
  local parsed = json:decode(data)
  local metrics = {}
  local metric = function (...)
    ipack(metrics, ...) 
  end

  -- Output metrics for each container
  pending_requests[extra.info] = nil
  local source = self.source .. '.' .. extra.info
  metric('DOCKER_TOTAL_CPU_USAGE', parsed.cpu_stats.cpu_usage.total_usage/(10^12), nil, source)
  metric('DOCKER_TOTAL_MEMORY_USAGE', round(parsed.memory_stats.usage, 2), nil, source)
  metric('DOCKER_NETWORK_RX', round(parsed.network.rx_bytes, 2), nil, source)
  metric('DOCKER_NETWORK_TX', round(parsed.network.tx_bytes, 2), nil, source)
  table.insert(stats.memory, parsed.memory_stats.usage)
  local percpu_usage = parsed.cpu_stats.cpu_usage.percpu_usage
  if (type(percpu_usage) == 'table') then
    for i=1, table.getn(percpu_usage) do
      metric('DOCKER_TOTAL_CPU_USAGE', percpu_usage[i]/10^12, nil, source .. '-C' .. i)
    end
  end

  stats.total_memory_usage = (stats.total_memory_usage or 0) + parsed.memory_stats.usage
  stats.total_cpu_usage = (stats.total_cpu_usage or 0) + parsed.cpu_stats.cpu_usage.total_usage/10^12
  stats.total_rx_bytes = (stats.total_rx_bytes or 0) + parsed.network.rx_bytes
  stats.total_tx_bytes = (stats.total_tx_bytes or 0) + parsed.network.tx_bytes

  -- Output aggregated metrics from all containers
  if not hasAny(pending_requests) then
    local memory_max, memory_min = maxmin(stats.memory)
    metric('DOCKER_TOTAL_CPU_USAGE', stats.total_cpu_usage)
    metric('DOCKER_TOTAL_MEMORY_USAGE', stats.total_memory_usage)
    metric('DOCKER_MEAN_MEMORY_USAGE', mean(stats.memory))
    metric('DOCKER_MAX_MEMORY_USAGE', memory_max)
    metric('DOCKER_MIN_MEMORY_USAGE', memory_min)
    metric('DOCKER_NETWORK_RX', stats.total_rx_bytes)
    metric('DOCKER_NETWORK_TX', stats.total_tx_bytes)

    stats = {}
    stats.memory = {}
  end

  return metrics
end
plugin:run()
