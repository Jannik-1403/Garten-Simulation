import re

with open("Garten_Simulation/Components/DragToWeedCross.swift", "r") as f:
    content = f.read()

# 1. Remove WeedPartikel struct
content = re.sub(r'// MARK: - Weed Partikel.*?// MARK: - Drag to Weed Cross', '// MARK: - Drag to Weed Cross', content, flags=re.DOTALL)

# 2. Remove state vars
content = content.replace('@State private var crossOpazitaet: Double = 1.0\n    @State private var istVerschwunden = false\n    @State private var partikel: [WeedPartikel] = []', '@State private var crossOpazitaet: Double = 1.0')

# 3. Fix guards
content = content.replace('guard !istErledigt, !istVerschwunden else { return }', 'guard !istErledigt else { return }')

# 4. Fix onEnded treffer block
new_treffer_block = """                    if treffer {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            dragOffset = .zero
                            crossKippWinkel = 0
                            crossSkalierung = 1.0
                            isDragging = false
                            treffer = false
                            letzterTreffer = false
                        }
                        onCrossApplied()
                    } else {"""
old_treffer_block_pattern = r'                    if treffer \{.*?\} else \{'
content = re.sub(old_treffer_block_pattern, new_treffer_block, content, flags=re.DOTALL)

# 5. ZStack cleanup
zstack_old = """            ZStack {
                ForEach(partikel) { p in
                    let rad = p.winkel * .pi / 180
                    let dx = cos(rad) * p.distanz
                    let dy = sin(rad) * p.distanz
                    let h = p.groesse
                    let w = h

                    Image(systemName: "drop.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(Color.red)
                        .frame(width: w, height: h)
                        .position(x: plantLocal.x + dx, y: plantLocal.y + dy)
                        .opacity(p.opazitaet)
                }

                if !istVerschwunden {
                    Image("SchlechteGewohnheitKreuz")"""
zstack_new = """            ZStack {
                Image("SchlechteGewohnheitKreuz")"""
content = content.replace(zstack_old, zstack_new)

# Remove the closing brace of if !istVerschwunden
content = content.replace("""                        .animation(
                            .easeIn(duration: 0.2),
                            value: crossOpazitaet
                        )
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)""", """                        .animation(
                            .easeIn(duration: 0.2),
                            value: crossOpazitaet
                        )
            }
            .frame(width: geo.size.width, height: geo.size.height)""")

# Fix allowsHitTesting
content = content.replace('.allowsHitTesting(!istVerschwunden)', '.allowsHitTesting(true)')

# Fix onChange
onchange_old = """.onChange(of: istErledigt) { _, erledigt in
            if erledigt {
                partikel = []
            } else {
                istVerschwunden = false
                letzterTreffer = false
            }
        }"""
onchange_new = """.onChange(of: istErledigt) { _, erledigt in
            if !erledigt {
                letzterTreffer = false
            }
        }"""
content = content.replace(onchange_old, onchange_new)

# Remove spawnPartikelTropfen
content = re.sub(r'    private func spawnPartikelTropfen\(\) \{.*?\n\}\n', '', content, flags=re.DOTALL)

with open("Garten_Simulation/Components/DragToWeedCross.swift", "w") as f:
    f.write(content)
