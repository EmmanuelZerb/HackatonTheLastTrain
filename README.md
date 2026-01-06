# The Last Strain

Projet de jeu réalisé dans le cadre d'un hackathon.

## Description

The Last Strain est un jeu d'action/aventure 3D développé avec Godot Engine 4.4. Le jeu propose une expérience immersive avec un système de combat, des ennemis à affronter et une ambiance sonore riche grâce à l'intégration FMOD.

## Caractéristiques

- Jeu 3D avec contrôles FPS
- Système de combat avec tir
- Intégration audio FMOD pour une expérience sonore immersive
- Support optionnel d'Arduino pour des contrôles physiques
- Graphismes 3D détaillés avec environnements et objets interactifs
- Système d'ennemis avec IA
- Menus de victoire et de défaite

## Prérequis

- **Godot Engine 4.4** ou supérieur
- **.NET SDK** (pour le support C#)
- **FMOD Studio** (optionnel, pour l'édition audio)
- **Arduino** (optionnel, pour les contrôles physiques)

## Installation

1. Clonez le dépôt :
   ```bash
   git clone https://github.com/EmmanuelZerb/HackatonTheLastTrain.git
   cd HackatonTheLastTrain-1
   ```

2. Ouvrez le projet avec Godot Engine 4.4+

3. Assurez-vous que les banques FMOD sont présentes dans `FMOD_Bank/Desktop/`

4. Lancez le jeu depuis l'éditeur ou exportez-le

## Contrôles

### Clavier/Souris
- **Z / Flèche Haut** : Avancer
- **S / Flèche Bas** : Reculer
- **Q / Flèche Gauche** : Déplacement gauche
- **D / Flèche Droite** : Déplacement droite
- **Espace** : Sauter
- **Shift** : Courir
- **Clic gauche** : Tirer
- **Molette** : Sélection d'arme/objet
- **E** : Interaction/Animation
- **Échap** : Toggle Arduino

## Structure du Projet

```
├── Graphismes/          # Assets visuels et modèles 3D
├── Sons & musiques/     # Assets audio
├── FMOD_Bank/           # Banques audio FMOD
├── Personnages/         # Personnages joueur et ennemis
├── Scènes/              # Scènes du jeu
├── Nodes/               # Nodes réutilisables
├── Arduino_Manager/     # Gestion de l'intégration Arduino
├── addons/              # Plugins (FMOD, etc.)
└── LastStrain.tscn      # Scène principale du jeu
```

## Technologies Utilisées

- **Godot Engine 4.4** - Moteur de jeu
- **GDScript & C#** - Langages de programmation
- **FMOD** - Middleware audio
- **Arduino** - Contrôles physiques optionnels

## Développement

Ce projet a été développé lors d'un hackathon. Les dossiers marqués "Ne pas toucher" contiennent des éléments de base du framework de jeu.

## Auteurs

Projet réalisé dans le cadre d'un hackathon.

## Licence

Voir le fichier LICENSE pour plus de détails.
