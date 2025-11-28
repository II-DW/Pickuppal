// MARK: - PickupPalApp.swift

import SwiftUI

@main
struct PickupPalApp: App {
    // 앱 전체에서 공유할 ViewModel을 StateObject로 생성
    @StateObject var viewModel = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            // 메인 콘텐츠 뷰에 ViewModel 주입
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
