// MARK: - TabBarView.swift (업데이트)

import SwiftUI

struct TabBarView: View {
    @Binding var activeTab: AppViewModel.Tab

    var body: some View {
        HStack(spacing: 0) {
            // 1. 배달 (Lightning icon similar to React)
            tabButton(for: .delivery, label: "배달", iconName: "bolt.fill")
            
            // 2. 활동 (List icon)
            tabButton(for: .activity, label: "활동", iconName: "list.bullet")
            
            // 3. 홈 (Home icon)
            tabButton(for: .home, label: "홈", iconName: "house.fill")
            
            // 4. 아바타 (Person icon)
            tabButton(for: .avatar, label: "아바타", iconName: "person.crop.circle.fill")
            
            // 5. 랭킹 (Chart icon)
            tabButton(for: .ranking, label: "랭킹", iconName: "chart.bar.fill")
        }
        .padding(.horizontal, 10)
        .frame(height: 65)
        .background(Color(.systemBackground))
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: -1)
        .overlay(
            Rectangle().frame(height: 1).foregroundColor(Color(.systemGray6)),
            alignment: .top
        )
    }

    private func tabButton(for tab: AppViewModel.Tab, label: String, iconName: String) -> some View {
        let isActive = activeTab == tab
        
        return Button {
            activeTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: iconName)
                    .font(.system(size: 24))
                Text(label)
                    .font(.caption2)
                    .fontWeight(isActive ? .bold : .regular)
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(isActive ? .emerald_500 : Color(.systemGray))
        }
    }
}
