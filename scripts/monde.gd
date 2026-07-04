extends Node2D
## ============================================================
## MONDE — génération du sol, murs invisibles et caméra
## ------------------------------------------------------------
## - Remplit le TileMapLayer "Sol" avec 20x20 tuiles d'herbe
##   (2 variantes choisies aléatoirement pour un sol vivant).
## - Crée 4 murs invisibles autour de la carte pour empêcher
##   le personnage de sortir du monde.
## - Configure les limites de la caméra pour qu'elle ne montre
##   jamais l'extérieur de la carte.
## ============================================================

## >>> POUR CHANGER LA TAILLE DU MONDE : modifiez ces constantes. <<<
const TAILLE_TUILE: int = 64      # taille d'une tuile en pixels
const LARGEUR_MONDE: int = 20     # nombre de tuiles en largeur
const HAUTEUR_MONDE: int = 20     # nombre de tuiles en hauteur

## Épaisseur des murs invisibles (en pixels).
const EPAISSEUR_MUR: float = 64.0

@onready var sol: TileMapLayer = $Sol
@onready var joueur: CharacterBody2D = $Monde/Joueur


func _ready() -> void:
	_remplir_sol()
	_creer_murs_invisibles()
	_configurer_camera()


## Remplit toute la carte avec des tuiles d'herbe.
## Le TileSet (défini dans main.tscn) contient 2 tuiles côte à côte
## dans assets/herbe.svg : on pioche au hasard entre les deux.
func _remplir_sol() -> void:
	for x in LARGEUR_MONDE:
		for y in HAUTEUR_MONDE:
			# Variante aléatoire : colonne 0 ou 1 de l'atlas.
			var variante := Vector2i(randi() % 2, 0)
			sol.set_cell(Vector2i(x, y), 0, variante)


## Crée un StaticBody2D avec 4 rectangles de collision placés
## juste à l'extérieur des bords de la carte : des murs invisibles.
func _creer_murs_invisibles() -> void:
	var largeur_px := float(LARGEUR_MONDE * TAILLE_TUILE)
	var hauteur_px := float(HAUTEUR_MONDE * TAILLE_TUILE)

	var murs := StaticBody2D.new()
	murs.name = "MursInvisibles"
	add_child(murs)

	# Chaque entrée : [position du centre du mur, taille du mur].
	var definitions := [
		# Mur du haut
		[Vector2(largeur_px / 2.0, -EPAISSEUR_MUR / 2.0), Vector2(largeur_px, EPAISSEUR_MUR)],
		# Mur du bas
		[Vector2(largeur_px / 2.0, hauteur_px + EPAISSEUR_MUR / 2.0), Vector2(largeur_px, EPAISSEUR_MUR)],
		# Mur de gauche
		[Vector2(-EPAISSEUR_MUR / 2.0, hauteur_px / 2.0), Vector2(EPAISSEUR_MUR, hauteur_px)],
		# Mur de droite
		[Vector2(largeur_px + EPAISSEUR_MUR / 2.0, hauteur_px / 2.0), Vector2(EPAISSEUR_MUR, hauteur_px)],
	]

	for definition in definitions:
		var collision := CollisionShape2D.new()
		var forme := RectangleShape2D.new()
		forme.size = definition[1]
		collision.shape = forme
		collision.position = definition[0]
		murs.add_child(collision)


## Limite la caméra aux bords du monde. Le lissage (smoothing) est
## activé directement sur la Camera2D dans scenes/joueur.tscn.
## Si le monde est plus petit que l'écran, les limites bloquent
## simplement la caméra : elle devient fixe automatiquement.
func _configurer_camera() -> void:
	var camera: Camera2D = joueur.get_node("Camera2D")
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = LARGEUR_MONDE * TAILLE_TUILE
	camera.limit_bottom = HAUTEUR_MONDE * TAILLE_TUILE
	# On force la caméra à démarrer directement sur le joueur
	# (sans glissement au lancement du jeu).
	camera.reset_smoothing()
