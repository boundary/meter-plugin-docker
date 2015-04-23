local timer    = require('timer')
local http     = require('http')
local boundary = require('boundary')
local json     = require('json')
local async    = require('async')
local io       = require('io')
local os       = require('os')


local __pgk        = "Boundary Docker Plugin"
local __ver        = "Version 1.0"
local __tags       = "plugin,lua,docker"
local _previous    = {}
local pollInterval = 1000
local host         = "localhost"
local port         = 2375
local source

if (boundary.param ~= nil) then
  pollInterval       = boundary.param['pollInterval'] or pollInterval
  host               = boundary.param['host'] or host
  port               = boundary.param['port'] or port
  source             = (type(boundary.param.source) == 'string' and boundary.param.source:gsub('%s+', '') ~= '' and boundary.param.source) or os.hostname
end

function berror(err)
  if err then print(string.format("_bevent:%s:%s:%s|t:error|tags:%s", __pgk, __ver, tostring(err), __tags)) return err end
end

local doreq = function(host, port, path, cb)
    local output = ""
    local req = http.request({host = host, port = port, path = path}, function (res)
      res:on("error", function(err)
        cb("Error while receiving a response: " .. tostring(err), nil)
      end)
      res:on("data", function (chunk)
        output = output .. chunk
      end)
      res:on("end", function ()
        res:destroy()
        cb(nil, output)
      end)
    end)
    req:on("error", function(err)
      cb("Error while sending a request: " .. tostring(err), nil)
    end)
    req:done()
end

function round(val, decimal)
  if (decimal) then
    return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
  else
    return math.floor(val+0.5)
  end
end

function toGB(val)
  return string.format("%.3f", type(val) == 'number' and round(val/1024^3, 3) or 0)
end

function mean(t)
  local sum = 0
  local count= 0
  for k, v in pairs(t) do
    if type(v) == 'number' then
      sum = sum + v
      count = count + 1
    end
  end
  return (sum / count)
end

function maxmin(t)
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


print("_bevent:"..__pkg..":"..__ver..":Up|t:info|tags:"..__tags)

timer.setInterval(pollInterval, function ()
  -- get all running containers
  doreq(host, port,  "/containers/json", function(err, body)
    if berror(err) then return end
    local containers = json:decode(body)
    local c = {}
    local n = {}
    for _, container in ipairs(containers) do
      table.insert(c, container.Id)
      table.insert(n, string.sub(container.Names[1], 2, -1))
    end
    local stats = {}
    local count = 0
    -- retrieve stats for container
    async.forEach(c, function(x, callback)
      count = count + 1
      local req = http.request({host = host, port = port, path = "/containers/".. x.. "/stats"}, function (res)
        res:on("error", function(err)
          return berror("Error while receiving a response: " .. tostring(err))
        end)
        res:on("data", function (chunk)
          local d = json:decode(chunk)
          -- streaming response, kill on first sight
          stats[n[count]] = d
          res:destroy()
          callback()
          return
        end)
        res:on("end", function ()
          res:destroy()
          return
        end)
      end)
      req:done()
    end, function()

      local _mem = {}
      local total_memory_usage = 0
      local total_cpu_usage = 0
      local mean_memory_usage = 0
      local total_rx_bytes = 0
      local total_tx_bytes = 0

      for k, v in pairs(stats) do
        if (type(v.cpu_stats) ~= nil and type(v.cpu_stats.cpu_usage) ~= nil) do
          print(string.format('DOCKER_TOTAL_CPU_USAGE %.3f %s', v.cpu_stats.cpu_usage.total_usage/10^12, k))
          if (type(v.cpu_stats.cpu_usage.percpu_usage) == 'table') do
            for i=1, table.getn(v.cpu_stats.cpu_usage.percpu_usage) do
              print(string.format('DOCKER_TOTAL_CPU_USAGE %.3f %s-C%d', v.cpu_stats.cpu_usage.percpu_usage[i]/10^12, k, i))
            end
          end
          print(string.format('DOCKER_TOTAL_MEMORY_USAGE %s %s', toGB(v.memory_stats.usage), k))
          print(string.format('DOCKER_NETWORK_RX %s %s', toGB(v.network.rx_bytes), k))
          print(string.format('DOCKER_NETWORK_TX %s %s', toGB(v.network.tx_bytes), k))
          table.insert(_mem, v.memory_stats.usage)
          total_memory_usage = total_memory_usage + v.memory_stats.usage
          total_cpu_usage    = total_cpu_usage + v.cpu_stats.cpu_usage.total_usage
          total_rx_bytes     = total_rx_bytes + v.network.rx_bytes
          total_tx_bytes     = total_tx_bytes + v.network.tx_bytes
        else
          return berror("Data mismatch" .. json:encode_pretty(v))
        end
      end

      local max, min = maxmin(_mem)
      print(string.format('DOCKER_TOTAL_CPU_USAGE %.3f %s', total_cpu_usage/10^12, source))
      print(string.format('DOCKER_TOTAL_MEMORY_USAGE %s %s', toGB(total_memory_usage), source))
      print(string.format('DOCKER_MEAN_MEMORY_USAGE %s %s', toGB(mean(_mem)), source))
      print(string.format('DOCKER_MAX_MEMORY_USAGE %s %s', toGB(max), source))
      print(string.format('DOCKER_MIN_MEMORY_USAGE %s %s', toGB(min), source))
      print(string.format('DOCKER_NETWORK_RX %s %s', toGB(total_rx_bytes), source))
      print(string.format('DOCKER_NETWORK_TX %s %s', toGB(total_tx_bytes), source))


    end)
  end)

end)










