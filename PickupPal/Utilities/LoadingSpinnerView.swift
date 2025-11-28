// MARK: - LoadingSpinnerView.swift

import SwiftUI

struct LoadingSpinnerView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .emerald_400))
                .scaleEffect(2.0)
                .frame(width: 64, height: 64)
            
            Text("데이터를 불러오는 중...")
                .font(.headline)
                .foregroundColor(Color(.systemGray))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// Custom Color (Tailwind `emerald-500` 등 대체)
extension Color {
    static let emerald_500 = Color(red: 16/255, green: 185/255, blue: 129/255) // #10b981
    static let emerald_400 = Color(red: 52/255, green: 211/255, blue: 163/255) // #34d399
    
    // Tailwind CSS의 emerald-100 색상 (#ccfae7)
    static let emerald_100 = Color(red: 204/255, green: 250/255, blue: 231/255)
    
    // Tailwind CSS의 yellow-400 (CharacterView, MyPageModal에서 사용)
    static let yellow_400 = Color(red: 250/255, green: 204/255, blue: 21/255)
    
    // Tailwind CSS의 yellow-900 (CharacterView, MyPageModal에서 사용)
    static let yellow_900 = Color(red: 120/255, green: 53/255, blue: 15/255)
}
