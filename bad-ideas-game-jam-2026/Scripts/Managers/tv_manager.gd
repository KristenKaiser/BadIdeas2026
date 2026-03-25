extends Node
class_name TVManager

var health_tv : TV
var metrics_tv : TV
enum LightColor  {BASE, WARNING, SPOTLIGHT, FAIL}

func change_lights(light_color : LightColor):
	health_tv.change_light_color(light_color)
	metrics_tv.change_light_color(light_color)
