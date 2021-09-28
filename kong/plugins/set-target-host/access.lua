local _M = {}
local APPLICATION_JSON = "application/json"
local APPLICATION_FORM_URLENCODED = "application/x-www-form-urlencoded"

local find = string.find
local lower = string.lower

-- Utility function --
local function is_json_body(content_type)
  return content_type and find(lower(content_type), "application/json", nil, true)
end

local function is_form_body(content_type)
  return content_type and find(lower(content_type), "application/x-www-form-urlencoded", nil, true)
end

local function string_split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    table.insert(t, str)
  end
  return t
end

local function return_error(message)
  local errorResponse = {}
  errorResponse["message"] = message
  kong.response.set_header("Content-Type", APPLICATION_JSON)
  kong.response.exit(400, errorResponse)
end

-- Plugin implementation --
function _M.execute(conf)
  local upstream_host = conf.upstream_host
  local header = conf.header
  local query_arg = conf.query_arg
  local path_index = conf.path_index
  local body_param = conf.body_param
  local upstream_port = conf.upstream_port
  local string_to_replace_from_host = conf.string_to_replace_from_host
  local value_to_replace

  if header then
    value_to_replace = kong.request.get_header(header)
    if not (value_to_replace) then
      return_error("Invalid or missing header")
    end
  elseif query_arg then
    value_to_replace = kong.request.get_query_arg(query_arg)
    if not (value_to_replace) then
      return_error("Invalid or missing query parameters")
    end
  elseif path_index > 0 then
    local path_array = string_split(kong.request.get_path(), "/")
    if path_array[path_index] then
      value_to_replace = path_array[path_index]
    else
      return_error("Invalid or missing path parameter")
    end
  elseif body_param then
    if is_json_body(kong.request.get_header("Content-Type")) then
      local json_body = kong.request.get_body(APPLICATION_JSON)
      value_to_replace = assert(load("return " .. body_param, nil, "t", json_body))()
      if not (value_to_replace) then
        return_error("Invalid or missing body parameter")
      end
    elseif is_form_body(kong.request.get_header("Content-Type")) then
      local form_body = kong.request.get_body(APPLICATION_FORM_URLENCODED)
      value_to_replace = form_body[body_param]
      if not (value_to_replace) then
        return_error("Invalid or missing body parameter")
      end
    else
      return_error("Content-Type not supported")
    end
  end

  local upstream_host = string.gsub(upstream_host, string_to_replace_from_host, value_to_replace)
  ngx.req.set_header("Host", upstream_host)
  kong.service.set_target(upstream_host, upstream_port)
end

return _M
