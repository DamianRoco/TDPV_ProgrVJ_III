tool
extends ToolButton

enum ButtonName { Start, Options, Exit }

signal button_pressed(button_type)

export(ButtonName) var type = ButtonName.Start
export var appear_time = 0.5
export var hide_time = 0.5
export var button_moving = true
export var can_focus = true

onready var sprite_selected = $Selected
onready var tween = $Tween
onready var sounds = [$ButtonTurningOff, $ButtonTurningOn, $ButtonPressed]

var turned_on = false


func _ready():
	if not Engine.editor_hint:
		var size = $Normal.texture.get_size()
		sprite_selected.scale = Vector2(2, 2)
		sprite_selected.offset = size / 2


func _process(_delta):
	if Engine.editor_hint and $Normal.texture:
		var size = $Normal.texture.get_size()
		rect_size = size * 2
		rect_scale = Vector2(0.5, 0.5)
		$Normal.scale = Vector2(2, 2)
		$Normal.offset = size / 2


func start_tween(color, entered):
	if not can_focus or button_moving:
		return
	turned_on = entered
	sounds[int(entered)].playing = true
	tween.interpolate_property(sprite_selected, "modulate", null, color,
		appear_time if entered else hide_time)
	tween.start()


func _on_ToolButton_button_down():
	start_tween(Color(0.5, 0.5, 0.5, 1), true)
	if not button_moving:
		sounds[2].playing = true

func _on_ToolButton_button_up():
	start_tween(Color(1, 1, 1, 0), true)


func _on_ToolButton_pressed():
	if turned_on and not button_moving:
		emit_signal("button_pressed", type)


func _on_ToolButton_focus_entered():
	start_tween(Color(1, 1, 1, 1), true)

func _on_ToolButton_focus_exited():
	start_tween(Color(1, 1, 1, 0), false)

func _on_ToolButton_mouse_entered():
	start_tween(Color(1, 1, 1, 1), true)

func _on_ToolButton_mouse_exited():
	start_tween(Color(1, 1, 1, 0), false)
