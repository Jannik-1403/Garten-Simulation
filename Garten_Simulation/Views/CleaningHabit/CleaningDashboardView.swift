import SwiftUI

struct CleaningDashboardView: View {
    @StateObject private var manager = CleaningManager.shared
    @State private var showingAddSheet = false
    @State private var selectedTask: CleaningTask?
    
    var body: some View {
        ZStack {
            // Background
            Color(UIColor.systemBackground)
            
            VStack(spacing: 24) {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(localized: "cleaning.dashboard.title", defaultValue: "Aufräumen"))
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            let overdueCount = manager.tasks.filter { $0.isOverdue(lastCompleted: manager.lastCompletedDate(for: $0.id)) }.count
                            if overdueCount > 0 {
                                Text(String(localized: "cleaning.dashboard.subtitle.overdue", defaultValue: "%@ Aufgaben sind fällig", table: nil).replacingOccurrences(of: "%@", with: "\(overdueCount)"))
                                    .font(.subheadline)
                                    .foregroundColor(.orange)
                            } else {
                                Text(String(localized: "cleaning.dashboard.subtitle.allDone", defaultValue: "Alles sauber!"))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Button {
                            showingAddSheet = true
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: "plus")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    // Task List
                    LazyVStack(spacing: 16) {
                        ForEach(manager.tasks) { task in
                            CleaningTaskRowView(manager: manager, task: task)
                                .onTapGesture {
                                    selectedTask = task
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 24)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .item3DContainer(farbe: Color.clear, sekundaerFarbe: Color.black.opacity(0.2)) // Optional 3D pop effect
        .sheet(isPresented: $showingAddSheet) {
            AddCleaningTaskSheet(manager: manager)
        }
        .sheet(item: $selectedTask) { task in
            CleaningAnalysisSheet(manager: manager, task: task)
        }
    }
}



#Preview {
    NavigationView {
        CleaningDashboardView()
    }
}
