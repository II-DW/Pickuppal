// MARK: - RecentActivityView.swift (components/RecentActivity.tsx 변환)

import SwiftUI

struct RecentActivityView: View {
    let activities: [Activity]
    
    // Tab 및 Pagination 상태
    @State private var activeTab: ActivityCategory = .all
    @State private var currentPage: Int = 1
    
    private let ACTIVITIES_PER_PAGE = 5
    
    enum ActivityCategory: String, CaseIterable, Identifiable {
        case all = "전체"
        case reusable = "다회용기 사용"
        case highCarbon = "탄소 절감 으뜸"
        var id: String { self.rawValue }
    }
    
    // MARK: - Computed Properties (Filtering & Pagination)
    
    private var filteredActivities: [Activity] {
        activities.filter { activity in
            switch activeTab {
            case .reusable:
                return activity.useReusableContainer
            case .highCarbon:
                // 0.35kg 이상 절감 시 "으뜸"으로 정의 (TSX 파일 로직 참고)
                return activity.carbonReduced >= 0.35
            case .all:
                return true
            }
        }
    }
    
    private var totalPages: Int {
        Int(ceil(Double(filteredActivities.count) / Double(ACTIVITIES_PER_PAGE)))
    }
    
    private var currentActivities: [Activity] {
        let startIndex = (currentPage - 1) * ACTIVITIES_PER_PAGE
        let endIndex = min(startIndex + ACTIVITIES_PER_PAGE, filteredActivities.count)
        guard startIndex < endIndex else { return [] }
        
        return Array(filteredActivities[startIndex..<endIndex])
    }
    
    // MARK: - UI Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("최근 활동")
                .font(.title2.bold())
                .foregroundColor(Color(.label))
            
            // 탭 바
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    ForEach(ActivityCategory.allCases) { tab in
                        Button(action: {
                            activeTab = tab
                            currentPage = 1 // 탭 변경 시 페이지 리셋
                        }) {
                            Text(tab.rawValue)
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(activeTab == tab ? .emerald_500 : Color(.systemGray))
                                .padding(.vertical, 12)
                                .overlay(
                                    Rectangle()
                                        .frame(height: 2)
                                        .foregroundColor(activeTab == tab ? .emerald_500 : .clear),
                                    alignment: .bottom
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color(.separator).opacity(0.5))
            }
            
            // 활동 목록
            if currentActivities.isEmpty {
                Text("해당하는 활동이 없습니다.")
                    .foregroundColor(Color(.systemGray))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
            } else {
                VStack(spacing: 12) {
                    ForEach(currentActivities) { activity in
                        ActivityRow(activity: activity)
                    }
                }
            }
            
            // 페이지네이션
            if totalPages > 1 {
                PaginationView(currentPage: $currentPage, totalPages: totalPages)
            }

        }
        .padding(.vertical)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Sub-Components

struct ActivityRow: View {
    let activity: Activity
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    var body: some View {
        HStack {
            // Activity Icon
            Image(systemName: "box.fill")
                .foregroundColor(.green)
                .padding(8)
                .background(Color.green.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(activity.restaurantName)
                    .font(.headline)
                    .foregroundColor(Color(.label))
                Text(timeAgo(from: activity.date))
                    .font(.subheadline)
                    .foregroundColor(Color(.systemGray))
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                if activity.useReusableContainer {
                    // Reusable Container Icon ♻️
                    Image(systemName: "leaf.circle.fill")
                        .foregroundColor(.emerald_500)
                        .font(.title2)
                }
                
                VStack(alignment: .trailing) {
                    Text("+\(activity.pointsEarned) P")
                        .font(.headline.bold())
                        .foregroundColor(.green)
                    Text("-\(activity.carbonReduced.formatted(.number.precision(.fractionLength(2))))kg CO₂")
                        .font(.subheadline)
                        .foregroundColor(Color(.systemGray))
                }
            }
        }
        .padding(.horizontal)
    }
}

struct PaginationView: View {
    @Binding var currentPage: Int
    let totalPages: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...totalPages, id: \.self) { page in
                Button("\(page)") {
                    currentPage = page
                }
                .font(.subheadline.weight(.semibold))
                .frame(width: 36, height: 36)
                .background(page == currentPage ? Color.emerald_500 : Color(.systemBackground))
                .foregroundColor(page == currentPage ? .white : Color(.label))
                .clipShape(Circle())
                .overlay(Circle().stroke(Color(.systemGray3), lineWidth: 1))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 10)
        .border(width: 1, edges: [.top], color: Color(.separator))
    }
}
// MARK: - EdgeBorder (특정 면에만 테두리를 그리기 위한 유틸리티)

struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for edge in edges {
            var x: CGFloat {
                switch edge {
                case .top, .bottom: return rect.minX
                case .leading: return rect.minX
                case .trailing: return rect.maxX - width
                }
            }

            var y: CGFloat {
                switch edge {
                case .top, .bottom: return edge == .top ? rect.minY : rect.maxY - width
                case .leading, .trailing: return rect.minY
                }
            }

            var w: CGFloat {
                switch edge {
                case .top, .bottom: return rect.width
                case .leading, .trailing: return width
                }
            }

            var h: CGFloat {
                switch edge {
                case .top, .bottom: return width
                case .leading, .trailing: return rect.height
                }
            }
            path.addPath(Path(CGRect(x: x, y: y, width: w, height: h)))
        }
        return path
    }
}

extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}
