extends CharacterBody2D
## ============================================================
## JOUEUR — déplacement top-down 8 directions + animation simple
## ------------------------------------------------------------
## - Lit la direction via le singleton "Entrees" (clavier + tactile).
## - Se déplace à VITESSE CONSTANTE avec move_and_slide(), ce qui
##   gère automatiquement les collisions (obstacles, murs invisibles).
## - Anime le sprite : il "regarde" dans la direction du mouvement
##   (flip horizontal + légère inclinaison) et rebondit doucement.
## ============================================================

## >>> POUR CHANGER LA VITESSE : modifiez cette valeur (pixels/seconde),
## soit ici, soit directement dans l'Inspecteur de Godot. <<<
@export var vitesse: float = 220.0

## Amplitude de l'inclinaison du sprite pendant la marche (en radians).
@export var inclinaison_max: float = 0.10

@onready var sprite: Sprite2D = $Sprite2D

# Horloge interne utilisée pour l'animation de "rebond".
var _temps_animation: float = 0.0


func _physics_process(delta: float) -> void:
	# --- 1. LECTURE DES ENTREES (clavier PC ou joystick tactile) ---
	var direction := Entrees.obtenir_direction()

	# --- 2. MOUVEMENT : vitesse constante, arrêt net au relâchement ---
	velocity = direction * vitesse
	move_and_slide()  # gère les collisions avec les obstacles et les murs

	# --- 3. ANIMATION ---
	_animer(direction, delta)


## Petite animation "procédurale" : pas besoin de spritesheet.
## Le sprite se retourne selon la direction, s'incline légèrement
## et rebondit pendant la marche, puis revient au repos en douceur.
func _animer(direction: Vector2, delta: float) -> void:
	var en_mouvement := direction.length() > 0.01

	# Le personnage regarde à gauche ou à droite selon le mouvement.
	if absf(direction.x) > 0.01:
		sprite.flip_h = direction.x < 0.0

	if en_mouvement:
		_temps_animation += delta * 12.0
		# Rebond : le sprite s'étire/se tasse légèrement en rythme.
		var rebond := sin(_temps_animation) * 0.06
		sprite.scale = Vector2(1.0 - rebond, 1.0 + rebond)
		# Légère inclinaison dans le sens de la marche.
		sprite.rotation = direction.x * inclinaison_max
	else:
		# Retour progressif à la pose de repos (interpolation douce).
		_temps_animation = 0.0
		sprite.scale = sprite.scale.lerp(Vector2.ONE, 12.0 * delta)
		sprite.rotation = lerpf(sprite.rotation, 0.0, 12.0 * delta)
