# Générateur de motifs pour matrice de LED (version SwiftUI)

Ce dépôt contient une petite application SwiftUI pour macOS qui permet de **dessiner interactivement un motif sur une matrice de 8 × 13 LED**, puis de **générer automatiquement les 4 mots de 32 bits** correspondant à l’état des LED.  
Ces 4 mots hexadécimaux sont pensés pour être utilisés dans la fonction `matrixWrite()` côté microcontrôleur (Arduino, STM32, etc.).

---

## 🎯 Objectif de l’application

- Représenter une **matrice de LED 8 lignes × 13 colonnes** sous forme de grille cliquable.
- Chaque case de la grille représente une LED :
  - **Gris** = LED éteinte (`false`)
  - **Bleu** = LED allumée (`true`)
- À partir de l’état de cette matrice, calculer **4 entiers non signés de 32 bits (`UInt32`)**.
- Afficher ces 4 mots au format **hexadécimal** (`0x????????`), prêts à être copiés/collés dans du code C/C++.

L’idée est de pouvoir concevoir visuellement des motifs (cœurs, lettres, icônes…) puis de récupérer directement leur représentation binaire pour un programme embarqué.  
Un clic sur une case grise la met en bleu,  
Un clic sur une case bleue la met en gris.
-> Les cases bleues sont prises en compte comme des LEDs allumées.

---

## 🧱 Principe de codage des LED

La matrice est de taille **8 × 13**, soit au total **104 LED** :

- 8 lignes indexées de `0` à `7`
- 13 colonnes indexées de `0` à `12`

On numérote chaque LED par un **index linéaire** :

```text
index = row * 13 + col
```

- `row` = numéro de ligne (0 à 7)
- `col` = numéro de colonne (0 à 12)

On obtient ainsi des index de **0 à 103** (inclus).  
Ces 104 bits sont ensuite répartis dans **4 mots de 32 bits** :

- mot 0 → bits 0 à 31
- mot 1 → bits 32 à 63
- mot 2 → bits 64 à 95
- mot 3 → bits 96 à 127 (les bits 104 à 127 ne sont pas utilisés)

Pour une LED à l’index `index` :

- `mot = index / 32` (division entière)
- `bit = index % 32` (reste de la division)

Si la LED est allumée (`true`), on positionne le bit correspondant dans le mot :

```swift
mots[mot] |= (UInt32(1) << bit)
```

---

## 🧮 Format de sortie

Les 4 mots sont stockés dans un tableau de `UInt32` puis convertis en chaînes hexadécimales :

```swift
let hexWords = mots.map { String(format: "0x%08X", $0) }
```

L’interface affiche ensuite quelque chose du type :

```text
0x12345678,
0x9ABCDEF0,
0x0000FFFF,
0x00000000
```

Les valeurs peuvent être **copiées directement** et utilisées dans un code C/C++ pour piloter la matrice de LED.

---

## 🖱 Utilisation de l’application

1. **Lancer l’application** (projet SwiftUI pour macOS).
2. Une grille 8 × 13 apparaît :
   - Cliquer sur une case → elle devient **bleue** (LED allumée).
   - Cliquer à nouveau → elle redevient **grise** (LED éteinte).
3. Dessiner votre motif LED en cliquant sur les cases souhaitées.
4. Cliquer sur le bouton :  
   **« Afficher les LEDs bleues format maxWrite() »**
5. Les 4 mots hexadécimaux apparaissent sous le bouton.
6. Sélectionner le texte et le **copier/coller** dans votre projet (par exemple comme paramètres d’une fonction `matrixWrite()` dans un programme Arduino).

Le champ texte utilise une police de type monospace pour faciliter la lecture et l’alignement des valeurs.

---

## 🖼 Capture d’écran




---

## 🧪 Idées d’utilisation

- Générer les motifs pour une **animation** sur matrice de LED (plusieurs écrans successifs).
- Concevoir rapidement des **icônes** ou **lettres** pour une bannière lumineuse.
- Préparer des tableaux constants pour du code embarqué sans avoir à manipuler les bits à la main.

---

## ⚙️ Environnement

- **Langage** : Swift
- **Framework** : SwiftUI
- **Plateforme cible** : macOS (application de bureau)
- **Dépendances** : aucune bibliothèque externe

Ce projet est volontairement **minimaliste** : un seul fichier `ContentView.swift` suffit pour tester et comprendre le principe.
