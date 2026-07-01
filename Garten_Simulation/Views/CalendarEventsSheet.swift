import SwiftUI
import EventKit

struct CalendarEventsSheet: View {
    @StateObject private var calendarManager = CalendarManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var onEventTap: ((CalendarEventPayload) -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            // Drag handle and title
            VStack(spacing: 8) {
                Capsule()
                    .fill(Color.secondary.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)
                
                HStack {
                    Text(String(localized: "calendar.sheet.title", defaultValue: "Kommende Termine"))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            
            if !calendarManager.isAuthorized {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    
                    Text(String(localized: "calendar.auth.message", defaultValue: "Grovy benötigt Zugriff auf deinen Kalender, um Termine anzuzeigen."))
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                    
                    Button {
                        Task {
                            await calendarManager.requestAccess()
                        }
                    } label: {
                        Text(String(localized: "calendar.auth.button", defaultValue: "Zugriff erlauben"))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.blauPrimary)
                            .cornerRadius(12)
                    }
                }
                .padding(24)
                Spacer()
            } else if calendarManager.todaysEvents.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.minus")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text(String(localized: "calendar.no_events", defaultValue: "Keine weiteren Termine heute."))
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 40)
                Spacer()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(calendarManager.todaysEvents, id: \.eventIdentifier) { event in
                            let payload = CalendarEventPayload(
                                title: event.title,
                                startDate: event.startDate,
                                endDate: event.endDate,
                                location: event.location
                            )
                            
                            Button {
                                onEventTap?(payload)
                                dismiss()
                            } label: {
                                EventCardView(event: event)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .draggable(payload)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .presentationDetents([.fraction(0.3)])
        .presentationBackgroundInteraction(.enabled)
        .presentationCornerRadius(32)
        .presentationDragIndicator(.hidden)
        .onAppear {
            if calendarManager.isAuthorized {
                calendarManager.fetchTodaysEvents()
            }
        }
    }
}

struct EventCardView: View {
    let event: EKEvent
    
    var timeString: String {
        let formatter = DateFormatter()
        
        if Calendar.current.isDateInToday(event.startDate) {
            formatter.timeStyle = .short
            formatter.dateStyle = .none
        } else if Calendar.current.isDateInTomorrow(event.startDate) {
            formatter.timeStyle = .short
            formatter.dateStyle = .none
            return "Morgen, \(formatter.string(from: event.startDate))"
        } else {
            formatter.timeStyle = .short
            formatter.dateStyle = .short
            formatter.doesRelativeDateFormatting = true
        }
        
        return "\(formatter.string(from: event.startDate)) - \(DateFormatter.localizedString(from: event.endDate, dateStyle: .none, timeStyle: .short))"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Circle()
                    .fill(Color(cgColor: event.calendar.cgColor))
                    .frame(width: 8, height: 8)
                Text(timeString)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            
            Text(event.title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .lineLimit(2)
                .foregroundStyle(.primary)
            
            if let location = event.location, !location.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 10))
                    Text(location)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .lineLimit(1)
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(width: 220, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}
