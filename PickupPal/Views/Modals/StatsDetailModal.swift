// MARK: - StatsDetailModal.swift (components/StatsDetailModal.tsx 변환)

import SwiftUI

// Utility mapping (TSX의 STAT_DETAILS 객체 역할)
struct StatDetailInfo {
    let title: String
    let unit: String
}

private func getStatDetails(for type: StatDetailType) -> StatDetailInfo {
    switch type {
    case .caloriesBurned:
        return StatDetailInfo(title: "일별 소모 칼로리", unit: "kcal")
    case .moneySaved:
        return StatDetailInfo(title: "일별 절약 금액", unit: "원")
    }
}

struct StatsDetailModal: View {
    let activities: [Activity]
    let statType: StatDetailType
    
    // SwiftUI에서 모달을 닫는 기본 방식
    @Environment(\.dismiss) var dismiss

    // MARK: - Computed Properties

    private var details: StatDetailInfo {
        getStatDetails(for: statType)
    }
    
    // TSX에서 activities.filter(a => a[statType] > 0) 로직 구현
    private var relevantActivities: [Activity] {
        activities.filter { activity in
            switch statType {
            case .caloriesBurned:
                return activity.caloriesBurned > 0
            case .moneySaved:
                return activity.moneySaved > 0
            }
        }
    }
    
    // TSX의 formatDate 함수 대체
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateStyle = .long
        return formatter
    }()
    
    // statValue 추출 헬퍼
    private func statValue(for activity: Activity) -> Double {
        switch statType {
        case .caloriesBurned:
            // 칼로리는 정수 부분만 필요하므로 Double로 처리 후 포맷팅
            return activity.caloriesBurned
        case .moneySaved:
            // 금액은 정수
            return Double(activity.moneySaved)
        }
    }
    
    // MARK: - UI Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if relevantActivities.isEmpty {
                    Text("표시할 활동 기록이 없습니다.")
                        .foregroundColor(Color(.systemGray))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(relevantActivities, id: \.id) { activity in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(activity.restaurantName)
                                        .font(.headline)
                                        .foregroundColor(Color(.label))
                                    
                                    // 날짜 포맷팅
                                    Text(activity.date, formatter: Self.dateFormatter)
                                        .font(.subheadline)
                                        .foregroundColor(Color(.systemGray))
                                }
                                
                                Spacer()
                                
                                // 값 포맷팅 (소수점 처리)
                                Text("\(statValue(for: activity).formatted(.number.precision(.fractionLength(statType == .caloriesBurned ? 0 : 0)))) \(details.unit)")
                                    .font(.title3.bold())
                                    .foregroundColor(.emerald_500)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle(details.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                    .foregroundColor(.emerald_500)
                }
            }
        }
    }
}
