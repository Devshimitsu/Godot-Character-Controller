extends Label

@export var player: CharacterBody3D

func _process(_delta):
	text = """
FPS: %d
Speed: %.2f
Velocity: %.2f
On Floor: %s
Position: %s
""" % [
	Engine.get_frames_per_second(),
	player.velocity.length(),
	Vector2(player.velocity.x, player.velocity.z).length(),
	player.is_on_floor(),
	player.global_position
]
