// MARK: - CountingText.swift (신규)

import SwiftUI


// [신규] 숫자가 0부터 목표값까지 부드럽게 올라가는 텍스트 뷰
struct CountingText: View, Animatable {
    var value: Double
    var format: String
    var unit: String
    var color: Color
    
    // 애니메이션 가능한 데이터로 설정 (SwiftUI가 이 값을 변경하며 애니메이션 처리)
    var animatableData: Double {
        get { value }
        set { value = newValue }
    }
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            // 숫자를 포맷에 맞춰 표시 (흔들림 방지를 위해 고정폭 숫자 적용)
            Text(String(format: format, value))
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
                .monospacedDigit()
            
            // 단위 표시
            Text(unit)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.gray)
        }
    }
}
