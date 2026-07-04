# MiniGame — jeu mobile 2D top-down (Godot 4)

Petit jeu Android 2D vu de dessus : un personnage se déplace librement dans un
monde carré de 20×20 tuiles d'herbe, avec des arbres et des rochers en
obstacles, un joystick virtuel tactile et une caméra fluide.
Orientation **portrait verrouillée**, résolution adaptative, 60 FPS,
rendu "Mobile". Fonctionne aussi sur PC (flèches / ZQSD / souris).

## Arborescence du projet

```
MiniGame/
├── project.godot              # Configuration : résolution, portrait, stretch, touches, autoload
├── export_presets.cfg         # Preset d'export Android (APK)
├── icon.svg                   # Icône du jeu
├── assets/
│   ├── herbe.svg              # Atlas de 2 tuiles d'herbe 64x64 (le sol)
│   ├── joueur.svg             # Sprite du personnage (placeholder)
│   ├── arbre.svg              # Sprite d'arbre (obstacle)
│   └── rocher.svg             # Sprite de rocher (obstacle)
├── scenes/
│   ├── main.tscn              # Scène principale : sol (TileMap), obstacles, joueur, UI
│   ├── joueur.tscn            # CharacterBody2D + Sprite + Collision + Camera2D (smoothing)
│   ├── arbre.tscn             # StaticBody2D (collision au tronc)
│   ├── rocher.tscn            # StaticBody2D (collision rectangulaire)
│   └── joystick.tscn          # Control ancré en bas à gauche
└── scripts/
    ├── entrees.gd             # Singleton : fusionne clavier + joystick tactile
    ├── joueur.gd              # Mouvement 8 directions + animation
    ├── joystick_virtuel.gd    # Joystick tactile dessiné en code
    └── monde.gd               # Remplit le sol, murs invisibles, limites caméra
```

## Où modifier quoi ?

| Ce que vous voulez changer | Où |
|---|---|
| **Vitesse du personnage** | `scripts/joueur.gd` → `@export var vitesse: float = 220.0` (ou dans l'Inspecteur en sélectionnant le nœud `Joueur`) |
| **Taille du monde** | `scripts/monde.gd` → `LARGEUR_MONDE`, `HAUTEUR_MONDE`, `TAILLE_TUILE` |
| **Sprite du personnage** | Remplacez `assets/joueur.svg`, ou changez la texture du nœud `Sprite2D` dans `scenes/joueur.tscn` |
| **Texture du sol** | Remplacez `assets/herbe.svg` (2 tuiles de 64×64 côte à côte) |
| **Position/nombre d'obstacles** | Dans `scenes/main.tscn`, sous `Monde/Obstacles` (dupliquez un arbre/rocher dans l'éditeur) |
| **Taille/sensibilité du joystick** | Sélectionnez `UI/JoystickVirtuel` dans `main.tscn` : `rayon_base`, `rayon_bouton`, `zone_morte` |
| **Fluidité de la caméra** | `scenes/joueur.tscn` → nœud `Camera2D` → `position_smoothing_speed` |

## 1. Ouvrir et lancer le projet dans Godot

1. Téléchargez **Godot 4.3 ou plus récent** (version standard, pas .NET) :
   <https://godotengine.org/download>
2. Lancez Godot → **Importer** → sélectionnez le fichier `project.godot`
   de ce dépôt → **Importer & Modifier**.
3. Au premier chargement, Godot importe automatiquement les SVG
   (un dossier caché `.godot/` est créé — il est ignoré par git).
4. Appuyez sur **F5** (ou le bouton ▶ en haut à droite) pour lancer le jeu.
   - Sur PC : déplacez le personnage avec les **flèches** ou **ZQSD/WASD**,
     ou cliquez-glissez sur le joystick en bas à gauche (la souris simule
     le tactile).

## 2. Exporter en APK Android — pas à pas

### a) Prérequis (une seule fois)

1. **Java JDK 17** : installez-le (par ex. [Adoptium Temurin 17](https://adoptium.net/)).
2. **Android SDK** : le plus simple est d'installer
   [Android Studio](https://developer.android.com/studio), puis dans
   *SDK Manager* cochez : **Android SDK Platform-Tools**,
   **Android SDK Build-Tools 34**, **Android SDK Platform 34**,
   **Android SDK Command-line Tools**.
3. Dans Godot : **Éditeur → Paramètres de l'éditeur → Export → Android**, renseignez :
   - `Java SDK Path` → dossier du JDK 17 ;
   - `Android SDK Path` → dossier du SDK (ex. `C:/Users/vous/AppData/Local/Android/Sdk`
     sous Windows, `~/Android/Sdk` sous Linux, `~/Library/Android/sdk` sous macOS).
4. **Clé de débogage (debug keystore)** : Godot la détecte souvent tout seul.
   Sinon, créez-la avec la commande :
   ```bash
   keytool -keyalg RSA -genkeypair -alias androiddebugkey \
     -keypass android -keystore debug.keystore -storepass android \
     -dname "CN=Android Debug,O=Android,C=US" -validity 9999
   ```
   puis renseignez `Debug Keystore` (= le fichier), `Debug Keystore User`
   (= `androiddebugkey`) et `Debug Keystore Pass` (= `android`) dans les
   mêmes paramètres de l'éditeur.

### b) Modèles d'export (une seule fois par version de Godot)

1. Menu **Éditeur → Gérer les modèles d'exportation…**
2. Cliquez **Télécharger et installer** (les "export templates" correspondent
   exactement à votre version de Godot).

### c) Générer l'APK

1. Menu **Projet → Exporter…** : le preset **Android** est déjà configuré
   (fichier `export_presets.cfg` fourni : portrait, arm64, mode immersif).
2. (Optionnel) Changez `Unique Name` (ex. `com.votrenom.minigame`).
3. Cliquez **Exporter le projet…** → choisissez `build/MiniGame.apk`
   → laissez **Export With Debug** coché pour un APK de test.
4. Installez sur votre téléphone :
   - branchez le téléphone en USB avec le **débogage USB** activé, puis :
     ```bash
     adb install build/MiniGame.apk
     ```
   - ou copiez l'APK sur le téléphone et ouvrez-le (autorisez
     "sources inconnues").

> Astuce : avec le téléphone branché, le bouton **Android** (petit logo en
> haut à droite de l'éditeur, "one-click deploy") compile, installe et lance
> le jeu directement sur l'appareil.

### d) Version release (pour publier)

Pour le Play Store : créez une clé *release* avec `keytool`, renseignez-la
dans l'onglet d'export (section *Keystore*), décochez *Export With Debug*,
et exportez en **AAB** (option `Gradle Build / Export Format`).

## Comment ça marche (architecture)

- **`Entrees` (autoload)** : point d'entrée unique des contrôles. Le joueur
  appelle `Entrees.obtenir_direction()` ; le singleton additionne le clavier
  (`Input.get_vector`) et le joystick tactile, puis limite la longueur à 1
  → vitesse constante dans les 8 directions, arrêt net au relâchement.
- **`joystick_virtuel.gd`** : suit un seul doigt (multi-touch géré par index),
  dessine base + bouton en `_draw()`, expose `direction`.
- **`joueur.gd`** : `velocity = direction * vitesse` + `move_and_slide()`
  (les collisions sont gérées par le moteur physique). Animation procédurale :
  flip horizontal, inclinaison et rebond léger pendant la marche.
- **`monde.gd`** : remplit le `TileMapLayer` (20×20, 2 variantes d'herbe
  aléatoires), crée 4 murs invisibles autour de la carte et borne la caméra
  aux limites du monde. La `Camera2D` (enfant du joueur) a le *position
  smoothing* activé : suivi fluide, et elle se fige d'elle-même sur les axes
  où le monde ne dépasse pas l'écran.
