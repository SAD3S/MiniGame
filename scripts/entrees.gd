extends Node
## ============================================================
## ENTREES (autoload / singleton)
## ------------------------------------------------------------
## Centralise TOUTES les entrées du jeu au même endroit :
##   - le clavier (flèches + ZQSD/WASD), pour tester sur PC ;
##   - le joystick virtuel tactile, pour Android.
## Le joueur ne connaît que ce singleton : il appelle simplement
## Entrees.obtenir_direction() sans savoir d'où vient l'entrée.
## Ce script est enregistré comme autoload "Entrees" dans
## project.godot (section [autoload]).
## ============================================================

## Référence vers le joystick virtuel. Le joystick s'enregistre
## lui-même ici dans son _ready() (voir scripts/joystick_virtuel.gd).
var joystick: Node = null


## Renvoie la direction demandée par le joueur, sous forme d'un
## Vector2 de longueur maximale 1 (les 8 directions sont possibles).
func obtenir_direction() -> Vector2:
	# 1) Entrée clavier : Input.get_vector gère déjà les diagonales
	#    et normalise le résultat (longueur <= 1).
	var direction := Input.get_vector(
		"deplacer_gauche", "deplacer_droite",
		"deplacer_haut", "deplacer_bas"
	)

	# 2) Entrée tactile : on ajoute la direction du joystick virtuel
	#    (Vector2.ZERO quand le doigt est relâché).
	if joystick != null:
		direction += joystick.direction

	# On limite la longueur à 1 pour que la vitesse reste constante,
	# même en diagonale ou si clavier + joystick sont utilisés ensemble.
	return direction.limit_length(1.0)
