# Set Upstream Host - Kong plugin
## Getting Started
This plugin can be used when request from the API clients has to be routed to different upstream nodes based on the node number for which data is requested. This plugins extracts the parameter from incoming request either from header, query, path or request body and forms the upstream host dynamically. This plugin supports forming upstream host from below parameters -
* From request header
* From query params
* From path params
* From json or form-urlencoded request body
## Steps to use this plugin
#### Create a service
```
curl -i -X POST \
 --url http://localhost:8001/services/ \
 --data 'name=node-details' \
 --data 'url=https://nodenumber.org'
```
#### Create a route
```
curl -i -X POST \
 --url http://localhost:8001/services/node-details/routes \
 --data 'paths[]=/anything' \
 --data 'strip_path=false'
```
#### 1) Add plugin to service - When node number is passed in request header
```
curl -i -X POST \
 --url http://localhost:8001/services/node-details/plugins/ \
 --data 'name=set-target-host' \
 --data "config.upstream_host=nodenumber.org" \
 --data "config.string_to_replace_from_host=nodenumber" \
 --data "config.header=node" 
```
### Test API
```
curl -i 'http://localhost:8000/anything' --header 'node: httpbin'
```
Here plugin will read node header value and it will replace nodenumber string from hostname with this value. Final upstream hostname formed in this example will be httpbin.org
### 2) When node number is passed in query parameter
#### Update plugin -
```
curl -X PUT http://localhost:8001/services/node-details/plugins/{plugin_id} \
 --data 'name=set-target-host' \
 --data "config.upstream_host=nodenumber.org" \
 --data "config.string_to_replace_from_host=nodenumber" \
 --data "config.query_arg=node" 
```
### Test API
```
curl -i 'http://localhost:8000/anything?node=httpbin'
```
### 3) When node number is passed in request body
#### Update plugin -
```
curl -i -X PUT http://localhost:8001/services/node-details/plugins/{plugin_id} \
 --data 'name=set-target-host' \
 --data "config.upstream_host=nodenumber.org" \
 --data "config.string_to_replace_from_host=nodenumber" \
 --data "config.body_param=node" 
```
### Test API - When Content-Type is application/json
```
curl -i 'http://localhost:8000/anything' \
--header 'Content-Type: application/json' \
--data-raw '{
    "node": "httpbin"
}'
```
### Test API - When Content-Type is application/x-www-form-urlencoded
```
curl -i 'http://localhost:8000/anything' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'node=httpbin'
```
### 4) When node number is passed in path parameter
#### Update plugin -
```
curl -i -X PUT http://localhost:8001/services/node-details/plugins/{plugin_id} \
 --data 'name=set-target-host' \
 --data "config.upstream_host=nodenumber.org" \
 --data "config.string_to_replace_from_host=nodenumber" \
 --data "config.path_index=2" 
```
### Test API
```
curl -i 'http://localhost:8000/anything/httpbin'
```
## Contributers
Name | Email Id
--- | --- | 
Anup Kumar Rai | raianup.2407@gmail.com
Saravanan Periyasamy | saravanancse03@gmail.com  
