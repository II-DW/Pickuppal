// MARK: - HomeTabView.swift (애니메이션 적용)

import SwiftUI

struct HomeTabView: View {
    @EnvironmentObject var viewModel: AppViewModel
    let user: User
    
    // [신규] 애니메이션 상태 관리
    @State private var startAnimation: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 포인트 정보 카드 (기존 코드 유지)
                HStack(spacing: 0) {
                    VStack(alignment: .leading) {
                        Text("사용 가능 포인트")
                            .font(.caption).foregroundColor(.gray)
                        Text("\(user.cashPoints.formatted()) P")
                            .font(.title2.bold()).foregroundColor(.emerald_500)
                        
                        Button(action: { viewModel.isPointShopOpen = true }) {
                            Text("🛍️ 포인트 상점")
                                .font(.caption.bold()).padding(.horizontal, 10).padding(.vertical, 6)
                                .background(Color.emerald_100).foregroundColor(.emerald_500).cornerRadius(12)
                        }.padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider().frame(height: 40).padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        Text("누적 획득 포인트")
                            .font(.caption).foregroundColor(.gray)
                        Text("\(user.exp.formatted()) P")
                            .font(.title2.bold()).foregroundColor(.black)
                        
                        Button(action: { viewModel.activeTab = .ranking }) {
                            Text("현재 랭킹 확인하기 >").font(.caption).foregroundColor(.gray)
                        }.padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding().background(Color(.systemBackground)).cornerRadius(16).shadow(color: .black.opacity(0.05), radius: 2)
                
                // [수정] 통계 카드들 (애니메이션 적용)
                VStack(spacing: 16) {
                    StatsCard(
                        title: "소모 열량",
                        value: user.stats.totalCaloriesBurned,
                        unit: "kcal",
                        iconName: "flame.fill",
                        color: .red,
                        format: "%.0f",
                        action: { viewModel.handleOpenStatsDetail(type: .caloriesBurned) },
                        animationTrigger: startAnimation
                    )
                    
                    StatsCard(
                        title: "절약 금액",
                        value: Double(user.stats.totalMoneySaved),
                        unit: "원",
                        iconName: "dollarsign.circle.fill",
                        color: .blue,
                        format: "%.0f", // 소수점 없음
                        action: { viewModel.handleOpenStatsDetail(type: .moneySaved) },
                        animationTrigger: startAnimation
                    )
                    
                    StatsCard(
                        title: "탄소 절감량",
                        value: user.stats.totalCarbonReduced,
                        unit: "kg",
                        iconName: "leaf.fill",
                        color: .green,
                        format: "%.2f", // 소수점 2자리
                        animationTrigger: startAnimation
                    )
                }
                .animation(.easeOut(duration: 1.5), value: startAnimation) // 1.5초 동안 애니메이션
                
                // 환영 메시지
                VStack(alignment: .leading, spacing: 8) {
                    Text("👋 환영합니다, \(user.name)님!")
                        .font(.title3.bold())
                    Text("오늘도 건강한 픽업 활동으로 지구를 지켜주셔서 감사합니다.")
                        .font(.subheadline).foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding().background(Color(.systemBackground)).cornerRadius(16).shadow(color: .black.opacity(0.05), radius: 2)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.systemGray5), lineWidth: 1))
                
                Spacer()
            }
            .padding().padding(.bottom, 80)
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            // 화면이 나타날 때 애니메이션 시작
            // 약간의 딜레이를 주어 화면 전환 후 자연스럽게 시작되도록 함
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                startAnimation = true
            }
        }
        .onDisappear {
            // 다른 탭으로 가면 초기화 (다시 돌아올 때 또 애니메이션 보려면)
            startAnimation = false
        }
    }
}
