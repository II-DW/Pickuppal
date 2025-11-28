// MARK: - ContentView.swift

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = AppViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            // 1. Main Content
            if viewModel.isLoading && viewModel.user == nil {
                LoadingSpinnerView()
            } else if let user = viewModel.user, let rankings = viewModel.rankings {
                
                // [수정] TabView 전체에 environmentObject 적용
                TabView(selection: $viewModel.activeTab) {
                    
                    // [1] 배달 탭
                    DeliveryView()
                        .tag(AppViewModel.Tab.delivery)
                    
                    // [2] 활동 탭
                    ScrollView {
                        RecentActivityView(activities: viewModel.activities)
                            .padding()
                            .padding(.bottom, 100)
                    }
                    .background(Color(.systemGroupedBackground))
                    .tag(AppViewModel.Tab.activity)
                    
                    // [3] 홈 탭
                    HomeTabView(user: user)
                        .tag(AppViewModel.Tab.home)
                    
                    // [4] 아바타 탭
                    CharacterView(
                        character: user.character,
                        level: user.level,
                        exp: user.exp,
                        expToNextLevel: user.expToNextLevel,
                        onManage: { viewModel.isAvatarModalOpen = true }
                    )
                    .tag(AppViewModel.Tab.avatar)
                    
                    // [5] 랭킹 탭
                    ScrollView {
                        RankingListView(rankings: rankings, currentUserId: user.id)
                            .padding()
                            .padding(.bottom, 100)
                    }
                    .background(Color(.systemGroupedBackground))
                    .tag(AppViewModel.Tab.ranking)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea(.keyboard)
                // ✅ [핵심 수정] 모든 하위 뷰(DeliveryView 등)에서 viewModel을 쓸 수 있도록 주입
                .environmentObject(viewModel)
                
            } else {
                Text("데이터 로딩 실패")
            }
            
            // 2. Custom Tab Bar
            if viewModel.user != nil {
                TabBarView(activeTab: $viewModel.activeTab)
            }
            
            // 3. Floating Button
            if viewModel.activeTab == .home || viewModel.activeTab == .activity {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            viewModel.isLogPickupModalOpen = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 32, weight: .medium))
                                .frame(width: 64, height: 64)
                                .foregroundColor(.white)
                                .background(Color.emerald_500)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .padding(.trailing, 24)
                        .padding(.bottom, 80)
                    }
                }
            }
        }
        .safeAreaInset(edge: .top) {
             if let user = viewModel.user {
                 HeaderView(
                     user: user,
                     onShare: { viewModel.isShareModalOpen = true },
                     onOpenMyPage: { viewModel.isMyPageModalOpen = true }
                 )
             }
        }
        .task {
            await viewModel.fetchData()
        }
        // --- 모달 연결 ---
        .sheet(isPresented: $viewModel.isLogPickupModalOpen) {
             LogPickupModal(onClose: { viewModel.isLogPickupModalOpen = false },
                            onSubmit: viewModel.handleLogPickupSubmit)
        }
        .sheet(isPresented: $viewModel.isMyPageModalOpen) {
             MyPageModal(user: viewModel.user!, onUpdate: viewModel.fetchData)
                .environmentObject(viewModel) // 모달에도 주입
        }
        .sheet(isPresented: $viewModel.isAvatarModalOpen) {
            if let user = viewModel.user {
                let displayData = CharacterDisplayData(user: user)
                AvatarModal(
                    isOpen: $viewModel.isAvatarModalOpen,
                    character: displayData,
                    onSubmit: viewModel.handleAllocateStats
                )
            }
        }
        .sheet(isPresented: $viewModel.isPointShopOpen) {
            PointShopView()
                .environmentObject(viewModel) // 상점 모달에도 주입
        }
        .sheet(item: $viewModel.statDetailType) { type in
            StatsDetailModal(activities: viewModel.activities, statType: type)
        }
    }
}
