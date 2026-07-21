import SwiftUI

@MainActor
func test() {
    let view = Text("Hello")
    let renderer = ImageRenderer(content: view)
    renderer.isOpaque = true
}
