tool
extends VBoxContainer

var bomb
var rng = RandomNumberGenerator.new()
var bomb_size
var bomb_sprite_index = 0
var bomb_interval = 5
var explosion = preload("res://addons/defuse/explosion/Explosion.tscn")
var data = {
	'score': 0,
	'fails': 0,
	'audio': true
}
var audio = {
	'success': preload('res://addons/defuse/audio/511484__mlaudio__success-bell.wav'),
	'fuse': preload('res://addons/defuse/audio/140715__j1987__fuse2.wav'),
	'explosion': preload('res://addons/defuse/audio/402004__eardeer__explosion-low-fuse-1.wav')
}


func _ready():
	bomb = $CanvasLayer/Button
	bomb.connect('pressed', self, '_on_bomb_pressed')
	bomb.icon = preload("res://addons/defuse/bomb-0.png")
	bomb_sprite_index = 0
	# I started using the button node for the bomb so I can't do fancy animations
	# a simple timer and changing the sprite will have to do for now.
	$CanvasLayer/Button/Timer.start(1)
	$CanvasLayer/Button/Timer.connect('timeout', self, '_on_bomb_timer_timeout')
	bomb.visible = false
	bomb_size = Vector2(55,55) * get_editor_scale()
	bomb.rect_size = bomb_size
	
	$AudioCheckBox.connect('toggled', self, '_on_audio_checkbox_toggled')
	$AudioCheckBox.pressed = data.audio
	load_data()
	update_score()
	$Timer.connect('timeout', self, '_on_timer_timeout')
	$Timer.start(2)


# Bomb code
func _on_timer_timeout():
	spawn_bomb()


func spawn_bomb():
	bomb.icon = load("res://addons/defuse/bomb-0.png")
	bomb_sprite_index = 0
	bomb.visible = true
	bomb_interval = rng.randf_range(5,60)
	new_bomb_position()


func defuse_bomb():
	bomb.visible = false
	$Timer.start(bomb_interval)


func _on_bomb_pressed():
	play_audio(audio.success)
	data.score += 1
	save_data()
	update_score()
	defuse_bomb()


func new_bomb_position():
	var windows_size = OS.get_window_size()
	bomb.rect_global_position = Vector2(
		rng.randf_range(0, windows_size.x - bomb_size.x),
		rng.randf_range(0, windows_size.y - bomb_size.y)
	)


func update_score():
	$HBoxContainer/Label2.text = str(data.score)
	$HBoxContainer2/Label2.text = str(data.fails)


func _on_bomb_timer_timeout():
	if bomb.visible:
		bomb_sprite_index += 1
		if bomb_sprite_index == 1:
			play_audio(audio.fuse)

		if bomb_sprite_index == 6:
			explode()
		else:
			bomb.icon = load("res://addons/defuse/bomb-" + str(bomb_sprite_index) + ".png")


func explode():
	play_audio(audio.explosion, 0.61)
	data.fails += 1
	save_data()
	update_score()
	bomb.visible = false
	$Timer.start(bomb_interval)
	var e = explosion.instance()
	e.global_position = bomb.rect_global_position + (bomb_size / 2)
	$CanvasLayer.add_child(e)
	

# Audio
func _on_audio_checkbox_toggled(button_pressed):
	data.audio = button_pressed
	save_data()


func play_audio(a, time = 0):
	if data.audio:
		$AudioStreamPlayer.stream = a
		$AudioStreamPlayer.play(time)


# Loading and saving
func load_data():
	var save_file = File.new()
	if not save_file.file_exists('user://savefile.save'):
		return
	save_file.open('user://savefile.save', File.READ)
	var file_data = parse_json(save_file.get_as_text())
	data = str2var(file_data)
	save_file.close()


func save_data():
	var save_file = File.new()
	save_file.open('user://savefile.save', File.WRITE)
	save_file.store_line(to_json(var2str(data)))
	save_file.close()


# extra stuff
func get_editor_scale() -> float:
	# There hasn't been a proper way of reliably getting the editor scale
	# so this function aims at fixing that by identifying what the scale is and
	# returning a value to use as a multiplier for manual UI tweaks
	
	# It might not work properly if they are using a custom theme
	
	# The way of getting the scale could change, but this is the most reliable
	# solution I could find that works in many different computer/monitors.
	var _scale = get_constant("inspector_margin", "Editor")
	_scale = _scale * 0.125
	
	# Adding this just in case the theme variable wasn't enough or the editor
	# screen size is smaller than 1
	if _scale < 1:
		_scale = 1
	
	return _scale
