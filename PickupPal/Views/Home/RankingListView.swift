// MARK: - RankingListView.swift (컴파일 오류 수정)

import SwiftUI

struct RankingListView: View {
    let rankings: Rankings
    let currentUserId: String
    
    @State private var activeTab: RankingCategory = .local
    
    enum RankingCategory: String, CaseIterable, Identifiable {
        case local = "지역 랭킹"
        case friends = "친구 랭킹"
        case weekly = "주간 랭킹"
        var id: String { self.rawValue }
    }
    
    private var currentRankingList: [RankItem] {
        switch activeTab {
        case .local: return rankings.local
        case .friends: return rankings.friends
        case .weekly: return rankings.weekly
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 탭바
            HStack {
                ForEach(RankingCategory.allCases) { tab in
                    Button(action: { activeTab = tab }) {
                        Text(tab.rawValue)
                            .font(.subheadline.weight(.medium))
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(activeTab == tab ? .emerald_500 : .gray)
                            .overlay(Rectangle().frame(height: 2).foregroundColor(activeTab == tab ? .emerald_500 : .clear), alignment: .bottom)
                    }
                }
            }
            .background(Color(.systemBackground))
            
            // 리스트
            LazyVStack(spacing: 12) {
                // [수정] enumerated() 대신 indices 사용 (컴파일 속도 향상)
                ForEach(currentRankingList.indices, id: \.self) { index in
                    let item = currentRankingList[index]
                    let displayRank = index + 1
                    
                    HStack {
                        // 등수 표시
                        if displayRank <= 3 {
                            Text(displayRank == 1 ? "🥇" : (displayRank == 2 ? "🥈" : "🥉"))
                                .font(.title)
                                .frame(width: 40)
                        } else {
                            Text("\(displayRank)")
                                .font(.title3.bold())
                                .foregroundColor(.gray)
                                .frame(width: 40)
                        }
                        
                        AsyncImage(url: URL(string: "https://i.pravatar.cc/150?u=\(item.userId)")) { img in
                            img.resizable().scaledToFill()
                        } placeholder: { Color.gray.opacity(0.3) }
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                        
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(.headline)
                            
                            Text("Lv. \(item.level)")
                                .font(.caption)
                                .foregroundColor(.emerald_500)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.emerald_100)
                                .cornerRadius(4)
                        }
                        
                        Spacer()
                        
                        Text("\(item.score.formatted()) P")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .background(item.userId == currentUserId ? Color.emerald_100.opacity(0.3) : Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                }
            }
            .padding()
        }
    }
}
