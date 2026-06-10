import ActivityKit
import WidgetKit
import SwiftUI

struct GardenLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: GardenActivityAttributes.self) { context in
            // Lock Screen UI (Large Banner)
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.attributes.gartenName.uppercased())
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundStyle(.secondary)
                        
                        Text(context.state.nachricht)
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.black)
                    }
                    
                    Spacer()
                    
                    // Wetter-Icon entfernt auf Nutzer-Wunsch
                }
                
                // Progress Bar (Duo-Style)
                VStack(spacing: 6) {
                    HStack {
                        Label {
                            Text("\(context.state.gegossenePflanzen)/\(context.state.gesamtPflanzen)")
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.bold)
                        } icon: {
                            Image(systemName: "drop.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(.cyan)
                        }
                        
                        Spacer()
                        
                        Text("\(Int(context.state.fortschritt * 100))%")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.black)
                            .foregroundStyle(.orange)
                    }
                    
                    // The Bar itself
                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 12)
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(LinearGradient(colors: [.orange, .yellow], startPoint: .leading, endPoint: .trailing))
                                .frame(width: proxy.size.width * context.state.fortschritt, height: 12)
                                .shadow(color: .orange.opacity(0.3), radius: 2)
                        }
                    }
                    .frame(height: 12)
                }
            }
            .padding()
            .activityBackgroundTint(Color.black.opacity(0.85))
            .activitySystemActionForegroundColor(Color.white)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded View
                DynamicIslandExpandedRegion(.leading) {
                    VStack {
                        Text(context.attributes.gartenName)
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack {
                        HStack(spacing: 2) {
                            Image(systemName: "flame.fill")
                                .foregroundStyle(.orange)
                            Text("\(context.state.streakTage)")
                                .font(.system(.title3, design: .rounded))
                                .fontWeight(.black)
                        }
                        Text("STREAK")
                            .font(.system(size: 8, weight: .black))
                            .opacity(0.6)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 8) {
                        Text(context.state.nachricht)
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.bold)
                        
                        // Mini Progress
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 6)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.orange)
                                .frame(width: 200 * context.state.fortschritt, height: 6)
                        }
                        .frame(width: 200)
                    }
                    .padding(.bottom, 8)
                }
            } compactLeading: {
                Image(systemName: "leaf.fill")
                    .foregroundStyle(.green)
            } compactTrailing: {
                HStack(spacing: 2) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.cyan)
                    Text("\(context.state.gesamtPflanzen - context.state.gegossenePflanzen)")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                }
            } minimal: {
                Image(systemName: "leaf.fill")
                    .foregroundStyle(.green)
            }
            .widgetURL(URL(string: "grovy://home"))
            .keylineTint(Color.orange)
        }
    }
}
