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
