local typedefs = require "kong.db.schema.typedefs"

local is_present = function(v)
  return type(v) == "string" and #v > 0
end

local function validate_fields(config)
  if is_present(config.header) or config.path_index > 0 or is_present(config.query_arg) or is_present(config.body_param) then
    return true
  end
  return nil, "one of these fields must be present: header, path_index, query_arg, body_param"
end

return {
  name = "set-target-host",
  fields = {
    {consumer = typedefs.no_consumer},
    {protocols = typedefs.protocols_http},
    {
      config = {
        type = "record",
        fields = {
          {header = {type = "string"}},
          {path_index = {type = "number", default = 0}},
          {query_arg = {type = "string"}},
          {body_param = {type = "string"}},
          {upstream_host = {required = true, type = "string"}},
          {upstream_port = {type = "number", default = 443}},
          {string_to_replace_from_host = {required = true, type = "string"}}
        },
        custom_validator = validate_fields,
      }
    }
  }
}
