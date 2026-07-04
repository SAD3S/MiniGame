extends Control
## ============================================================
## JOYSTICK VIRTUEL (tactile) — affiché en bas à gauche
## ------------------------------------------------------------
## - Dessiné entièrement en code (_draw) : aucun asset nécessaire.
## - Suit UN doigt à la fois (multi-touch géré via l'index du doigt).
## - Expose la variable "direction" : un Vector2 de longueur 0 à 1,
##   lu par le singleton Entrees (le joystick s'y enregistre tout seul).
## - Fonctionne aussi à la souris sur PC grâce à l'option
##   "emulate_touch_from_mouse" activée dans project.godot.
## ============================================================

## Rayon de la grande zone (la base) du joystick, en pixels.
@export var rayon_base: float = 110.0
## Rayon du bouton central que le doigt déplace.
@export var rayon_bouton: float = 45.0
## Zone morte : en dessous de ce seuil (0 à 1), on ignore l'entrée
## pour éviter que le personnage ne "glisse" involontairement.
@export var zone_morte: float = 0.15

## Direction actuelle du joystick (lue par Entrees.obtenir_direction()).
var direction := Vector2.ZERO

# Index du doigt qui contrôle le joystick (-1 = aucun doigt posé).
var _doigt: int = -1
# Position du bouton central, en coordonnées locales du Control.
var _position_bouton := Vector2.ZERO


func _ready() -> void:
	# On s'enregistre auprès du gestionnaire d'entrées.
	Entrees.joystick = self
	_position_bouton = _centre()


## Centre du Control (le joystick est dessiné autour de ce point).
func _centre() -> Vector2:
	return size / 2.0


func _input(event: InputEvent) -> void:
	# --- Doigt posé ou levé ---
	if event is InputEventScreenTouch:
		if event.pressed and _doigt == -1 and _est_dans_la_zone(event.position):
			# Un doigt vient de toucher la zone du joystick : on le "capture".
			_doigt = event.index
			_mettre_a_jour(event.position)
		elif not event.pressed and event.index == _doigt:
			# Le doigt qui contrôlait le joystick est levé : arrêt net.
			_relacher()

	# --- Doigt qui glisse ---
	elif event is InputEventScreenDrag and event.index == _doigt:
		_mettre_a_jour(event.position)


## Le point touché est-il dans la zone d'activation du joystick ?
func _est_dans_la_zone(position_ecran: Vector2) -> bool:
	return get_global_rect().has_point(position_ecran)


## Calcule la direction et la position du bouton à partir du doigt.
func _mettre_a_jour(position_ecran: Vector2) -> void:
	# Vecteur entre le centre du joystick et le doigt (coordonnées locales).
	var vecteur := (position_ecran - global_position) - _centre()

	# Le bouton reste à l'intérieur de la base.
	_position_bouton = _centre() + vecteur.limit_length(rayon_base)

	# Direction normalisée entre 0 et 1, avec zone morte.
	direction = vecteur / rayon_base
	if direction.length() < zone_morte:
		direction = Vector2.ZERO
	else:
		direction = direction.limit_length(1.0)

	queue_redraw()  # redessine le joystick à sa nouvelle position


## Relâchement : le bouton revient au centre, le personnage s'arrête.
func _relacher() -> void:
	_doigt = -1
	direction = Vector2.ZERO
	_position_bouton = _centre()
	queue_redraw()


## Dessin du joystick : deux cercles semi-transparents.
func _draw() -> void:
	# La base (grand cercle fixe).
	draw_circle(_centre(), rayon_base, Color(1, 1, 1, 0.20))
	draw_arc(_centre(), rayon_base, 0.0, TAU, 48, Color(1, 1, 1, 0.45), 4.0, true)
	# Le bouton central (suit le doigt).
	draw_circle(_position_bouton, rayon_bouton, Color(1, 1, 1, 0.55))
	draw_arc(_position_bouton, rayon_bouton, 0.0, TAU, 32, Color(1, 1, 1, 0.8), 3.0, true)
