# Explication détaillée du code SwiftUI (ligne par ligne)

Ce document explique **pas à pas** le fonctionnement du fichier `ContentView.swift` utilisé pour générer les 4 mots hexadécimaux à partir de la matrice de LED 8 × 13.

Le code complet est rappelé ici pour référence :

```swift
import SwiftUI

struct ContentView: View {
    let rows = 8
    let cols = 13
    
    @State private var ledStates: [[Bool]] = Array(repeating: Array(repeating: false, count: 13), count: 8) // tableau boolean à deux dimensions
    @State private var result: String = ""
    
    // Fonction pour convertir la matrice de leds en 4 mots hexadécimaux
    func ledsBleuesHex() -> [String] {
        var mots: [UInt32] = [0, 0, 0, 0]

        for rowIndex in 0..<rows {
            for colIndex in 0..<cols {
                let index = rowIndex * cols + colIndex
                let mot = index / 32
                let bit = index % 32
                if ledStates[rowIndex][colIndex] {
                    mots[mot] |= (UInt32(1) << bit)
                }
            }
        }

        return mots.map { String(format: "0x%08X", $0) }
    }

    
    var body: some View {
        VStack {
            GeometryReader { geo in
                let cellSize = min(geo.size.width / CGFloat(cols),
                                   geo.size.height / CGFloat(rows))

                ZStack {
                    ForEach(0..<rows, id: \.self) { row in
                        ForEach(0..<cols, id: \.self) { col in
                            Rectangle()
                                .fill(ledStates[row][col] ? .blue : .gray.opacity(0.3))
                                .frame(width: cellSize, height: cellSize)
                                .border(.gray)
                                .position(
                                    x: cellSize * (CGFloat(col) + 0.5),
                                    y: cellSize * (CGFloat(row) + 0.5)
                                )
                                .onTapGesture { ledStates[row][col].toggle() }
                        }
                    }
                }
            }
            .aspectRatio(CGFloat(cols)/CGFloat(rows), contentMode: .fit)
            .padding(16)
        
            Button("Afficher les LEDs bleues format maxWrite()") {
                let hexWords = ledsBleuesHex()
                result = hexWords
                    .enumerated()
                    .map { (i, word) in i < hexWords.count - 1 ? "\(word)," : word }
                    .joined(separator: "\n")
            }
            
            // Affichage du résultat hexadécimal sous le bouton
            Text(result) // => Chaîne simple à type checker
                .font(.system (.title, design: .monospaced))
                .textSelection(.enabled)
                .padding()
        }
    }
}
```

---

## 1. Import et définition de la vue

```swift
import SwiftUI
```

On importe le framework **SwiftUI**, nécessaire pour déclarer des vues, des layouts (`VStack`, `ZStack`, etc.) et gérer l’interface graphique de manière déclarative.

```swift
struct ContentView: View {
```

On déclare une structure `ContentView` qui adopte le protocole `View`.  
C’est la vue principale de l’application : celle qui sera affichée dans la fenêtre.

---

## 2. Constantes de dimensions de la matrice

```swift
    let rows = 8
    let cols = 13
```

- `rows` : nombre de **lignes** de la matrice de LED (8).
- `cols` : nombre de **colonnes** (13).

Ces constantes sont utilisées à plusieurs endroits :  
- pour dessiner la grille,
- pour parcourir le tableau `ledStates`,
- pour calculer la taille des cellules dans la fenêtre.

---

## 3. État de l’application : la matrice et le résultat texte

```swift
    @State private var ledStates: [[Bool]] = Array(repeating: Array(repeating: false, count: 13), count: 8)
```

- `@State` indique que cette propriété appartient à l’**état local** de la vue.
- `ledStates` est un tableau **à deux dimensions** de `Bool` :
  - tableau de 8 lignes,
  - chaque ligne contient 13 valeurs booléennes.
- Chaque case vaut :
  - `false` : LED éteinte,
  - `true` : LED allumée.

La ligne d’initialisation :

```swift
Array(repeating: Array(repeating: false, count: 13), count: 8)
```

- crée un tableau de 8 éléments,
- chaque élément est un tableau de 13 `false`,
- au total : une matrice 8 × 13 initialisée à `false`.

```swift
    @State private var result: String = ""
```

- `result` stocke le **texte affiché sous le bouton**.
- Contiendra les 4 mots hexadécimaux formatés ligne par ligne.
- Initialement vide.

---

## 4. Conversion de la matrice en 4 mots hexadécimaux

```swift
    // Fonction pour convertir la matrice de leds en 4 mots hexadécimaux
    func ledsBleuesHex() -> [String] {
        var mots: [UInt32] = [0, 0, 0, 0]
```

- La fonction `ledsBleuesHex()` ne prend pas de paramètre : elle lit directement `ledStates`.
- `mots` est un tableau de 4 entiers non signés de 32 bits (`UInt32`), initialisés à 0.
- Chaque entier représentera 32 LED (bits).

```swift
        for rowIndex in 0..<rows {
            for colIndex in 0..<cols {
```

- Double boucle pour parcourir toutes les cases de la matrice :
  - `rowIndex` : ligne courant (0 à 7),
  - `colIndex` : colonne courante (0 à 12).

```swift
                let index = rowIndex * cols + colIndex
```

- Conversion des coordonnées (ligne, colonne) en **index linéaire** dans `[0, 103]` :
  - formule : `index = row * nombreColonnes + col`.

```swift
                let mot = index / 32
                let bit = index % 32
```

- `mot` : numéro du mot dans `mots` (0 à 3).
  - On répartit 32 bits par mot → division entière par 32.
- `bit` : position du bit dans ce mot (0 à 31).
  - Reste de la division par 32.

```swift
                if ledStates[rowIndex][colIndex] {
                    mots[mot] |= (UInt32(1) << bit)
                }
```

- On teste l’état de la LED dans la matrice :
  - `true` → LED allumée,
  - `false` → LED éteinte.
- Si la LED est allumée :
  - on construit un masque avec `1` décalé de `bit` positions vers la gauche,
  - on fait un OR binaire (`|=`) pour positionner ce bit dans le mot correspondant.

```swift
        return mots.map { String(format: "0x%08X", $0) }
    }
```

- `mots.map { ... }` transforme chaque `UInt32` en chaîne de caractères.
- `String(format: "0x%08X", $0)` :
  - affiche le nombre en base 16,
  - sur 8 chiffres (complétés par des zéros si besoin),
  - avec le préfixe `0x`.

La fonction retourne donc un tableau de 4 chaînes du type :

```text
["0x12345678", "0x9ABCDEF0", "0x0000FFFF", "0x00000000"]
```

---

## 5. Construction de l’interface graphique (`body`)

```swift
    var body: some View {
        VStack {
```

- `body` décrit l’interface de la vue.
- `VStack` empile verticalement :
  1. la zone de dessin de la grille,
  2. le bouton de génération,
  3. le texte d’affichage du résultat.

---

### 5.1. Zone de dessin réactive (GeometryReader + ZStack)

```swift
            GeometryReader { geo in
                let cellSize = min(geo.size.width / CGFloat(cols),
                                   geo.size.height / CGFloat(rows))
```

- `GeometryReader` fournit la taille disponible (`geo.size`).
- On calcule `cellSize` pour que :
  - la largeur des colonnes tienne dans `geo.size.width`,
  - la hauteur des lignes tienne dans `geo.size.height`,
  - on prenne le minimum des deux pour **garder des cellules carrées**.

```swift
                ZStack {
```

- `ZStack` permet de superposer tous les rectangles, chacun positionné à la main.

```swift
                    ForEach(0..<rows, id: \.self) { row in
                        ForEach(0..<cols, id: \.self) { col in
```

- Double `ForEach` pour dessiner la grille.
- Chaque couple `(row, col)` correspond à une cellule.

```swift
                            Rectangle()
                                .fill(ledStates[row][col] ? .blue : .gray.opacity(0.3))
```

- `Rectangle()` dessine une case.
- `.fill(...)` choisit la couleur de remplissage :
  - si la LED est allumée (`true`) → `.blue`,
  - sinon → gris clair (`.gray.opacity(0.3)`).

```swift
                                .frame(width: cellSize, height: cellSize)
```

- On fixe la taille de chaque case à `cellSize × cellSize`.

```swift
                                .border(.gray)
```

- Ajoute un contour gris autour de chaque case pour bien délimiter la grille.

```swift
                                .position(
                                    x: cellSize * (CGFloat(col) + 0.5),
                                    y: cellSize * (CGFloat(row) + 0.5)
                                )
```

- Positionne chaque case dans la zone du `ZStack` :
  - l’axe X dépend de la colonne,
  - l’axe Y dépend de la ligne,
  - `+ 0.5` permet de centrer la case dans sa “cellule” virtuelle.

```swift
                                .onTapGesture { ledStates[row][col].toggle() }
```

- Ajoute un gestionnaire de tap (clic).
- À chaque clic, on inverse (`toggle()`) l’état de la LED :
  - `false → true`,
  - `true → false`.

---

### 5.2. Aspect et marges de la zone de grille

```swift
            }
            .aspectRatio(CGFloat(cols)/CGFloat(rows), contentMode: .fit)
            .padding(16)
```

- `.aspectRatio(...)` fixe un ratio largeur/hauteur égal à `colonnes / lignes`.
- `contentMode: .fit` indique que la vue doit rester entière dans l’espace disponible.
- `.padding(16)` ajoute une marge autour de la grille pour l’aérer visuellement.

---

## 6. Bouton de génération des mots hexadécimaux

```swift
            Button("Afficher les LEDs bleues format maxWrite()") {
                let hexWords = ledsBleuesHex()
                result = hexWords
                    .enumerated()
                    .map { (i, word) in i < hexWords.count - 1 ? "\(word)," : word }
                    .joined(separator: "\n")
            }
```

- Le bouton affiche le texte : **« Afficher les LEDs bleues format maxWrite() »**.
- Quand l’utilisateur clique :
  1. On appelle `ledsBleuesHex()` pour obtenir les 4 mots hexadécimaux.
  2. `enumerated()` permet d’avoir à la fois l’index `i` et la valeur `word`.
  3. On ajoute une virgule `,` après chaque mot **sauf le dernier**.
  4. `joined(separator: "\n")` assemble les lignes avec un saut de ligne entre chaque mot.

Exemple de `result` final :

```text
0x12345678,
0x9ABCDEF0,
0x0000FFFF,
0x00000000
```

---

## 7. Affichage du résultat hexadécimal

```swift
            // Affichage du résultat hexadécimal sous le bouton
            Text(result) // => Chaîne simple à type checker
                .font(.system (.title, design: .monospaced))
                .textSelection(.enabled)
                .padding()
```

- `Text(result)` affiche le texte généré.
- `.font(.system(.title, design: .monospaced))` :
  - utilise une police système,
  - de taille “title”,
  - **monospace** (tous les caractères ont la même largeur), ce qui facilite la lecture des hexadécimaux.
- `.textSelection(.enabled)` permet de **sélectionner et copier** le texte avec la souris.
- `.padding()` ajoute une marge autour de la zone de texte.

---

## 8. Fermeture de la vue

```swift
        }
    }
}
```

- Fermeture de `VStack`, de la propriété `body`, puis de la structure `ContentView`.
- Le code est auto-suffisant : il définit entièrement la vue principale.

---

## Résumé

Ce fichier `ContentView.swift` :
- affiche une **grille interactive 8 × 13**,
- stocke l’état des LED dans un tableau `[[Bool]]`,
- convertit cet état en **4 mots `UInt32`**,
- affiche ces mots sous forme **hexadécimale** dans une zone facilement copiable.

Il constitue un **outil graphique simple** pour préparer des motifs destinés à une fonction de type `matrixWrite()` dans un programme C/C++ embarqué.

