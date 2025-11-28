// MARK: - StatsCard.swift

import SwiftUI


// [수정] StatsCard (String 대신 Double을 받도록 변경)
struct StatsCard: View {
    let title: String
    let value: Double // [변경] String -> Double
    let unit: String
    let iconName: String
    let color: Color
    var format: String = "%.0f" // 기본 포맷 (정수)
    var action: (() -> Void)? = nil
    
    // 애니메이션 트리거 (HomeTabView에서 전달받음)
    var animationTrigger: Bool = false

    var body: some View {
        Button(action: {
            action?()
        }) {
            HStack(spacing: 16) {
                // 아이콘
                Image(systemName: iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .foregroundColor(color)
                    .clipShape(Circle())

                // 텍스트 영역
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.caption.weight(.medium))
                        .foregroundColor(Color(.systemGray))

                    // [핵심] CountingText 컴포넌트 사용
                    CountingText(
                        value: animationTrigger ? value : 0, // 트리거 true면 목표값, 아니면 0
                        format: format,
                        unit: unit,
                        color: Color(.label)
                    )
                }
                Spacer()
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle()) // 버튼 깜빡임 효과 제거
    }
}
