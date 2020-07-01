extends CanvasLayer

# Create a free account in: https://www.000webhost.com
# or use your own PHP server
var endpoint_api = "https://godotdownloadimage.000webhostapp.com/"
var use_threads = false

signal request_completed(_return, _code, _route)

func request(_endPoint, _postData, _postMethod, _actionName):
	var http = HTTPRequest.new()
	http.use_threads = use_threads
	http.connect("request_completed", self, "_on_HTTPRequest_request_completed", [_actionName, http])
	add_child(http)
	
	var headers = [
		"Content-Type: application/json",
		"Accept: application/json"
		]
	
	http.request(str(endpoint_api, _endPoint), headers, false, HTTPClient[str("METHOD_", _postMethod)], to_json(_postData))



func _on_HTTPRequest_request_completed(result, response_code, _headers, body, _route, _httpObject):
	var bodyUtf = body.get_string_from_utf8()
	var json = JSON.parse(bodyUtf)
	var res = json.result
	
	emit_signal("request_completed", res, response_code, _route)
	
	if weakref(_httpObject).get_ref():
		_httpObject.queue_free()
