// MARK: - AppViewModel.swift (다회용기 매개변수 추가)

import SwiftUI

// 픽업 세션 모델
struct PickupSession {
    let restaurant: Restaurant
    let menu: MenuItem
    let distance: Double
    let useReusableContainer: Bool // [신규] 다회용기 사용 여부 저장
}

@MainActor
class AppViewModel: ObservableObject {
    @Published var user: User?
    @Published var activities: [Activity] = []
    @Published var rankings: Rankings?
    @Published var isLoading: Bool = true
    
    enum Tab: String, CaseIterable, Identifiable {
        case delivery = "배달"
        case activity = "활동"
        case home = "홈"
        case avatar = "아바타"
        case ranking = "랭킹"
        var id: String { self.rawValue }
    }
    @Published var activeTab: Tab = .home
    @Published var error: Error? = nil
    
    // Modals
    @Published var isShareModalOpen: Bool = false
    @Published var isLogPickupModalOpen: Bool = false
    @Published var isMyPageModalOpen: Bool = false
    @Published var isAvatarModalOpen: Bool = false
    @Published var isPointShopOpen: Bool = false
    @Published var statDetailType: StatDetailType? = nil

    @Published var currentPickupSession: PickupSession? = nil

    let apiManager = APIManager()
    
    // MARK: - Data Methods
    
    func fetchData() async {
        isLoading = true
        do {
            async let userData = apiManager.fetchUserData()
            async let activitiesData = apiManager.fetchActivities()
            async let rankingsData = apiManager.fetchRankings()
            let (u, a, r) = try await (userData, activitiesData, rankingsData)
            self.user = u; self.activities = a; self.rankings = r; self.error = nil
        } catch { self.error = error; print("Error: \(error)") }
        isLoading = false
    }
    
    func refreshUserData() async {
        do { self.user = try await apiManager.fetchUserData() } catch { print("Error: \(error)") }
    }

    // [수정] 픽업 시작 (다회용기 여부 포함)
    func startPickup(restaurant: Restaurant, menu: MenuItem, useReusableContainer: Bool) {
        let distance = Double.random(in: 0.5...2.5)
        self.currentPickupSession = PickupSession(
            restaurant: restaurant,
            menu: menu,
            distance: distance,
            useReusableContainer: useReusableContainer // [신규]
        )
    }
    
    // [수정] 픽업 완료 처리
    func completePickup() async -> Activity? {
        guard let session = currentPickupSession else { return nil }
        
        isLoading = true
        defer {
            isLoading = false
            currentPickupSession = nil
        }
        
        let pickupData = NewPickupData(
            restaurantName: session.restaurant.name,
            distance: session.distance,
            orderValue: session.menu.price,
            useReusableContainer: session.useReusableContainer // [신규] 저장된 값 사용
        )
        
        do {
            let activity = try await apiManager.logActivity(data: pickupData, isPickup: true)
            await fetchData()
            return activity
        } catch {
            self.error = error
            return nil
        }
    }
    
    // [수정] 배달 주문 처리 (다회용기 매개변수 추가했지만 배달은 보통 false 처리)
    func processDeliveryOrder(restaurant: Restaurant, menu: MenuItem, useReusableContainer: Bool = false) async -> Activity? {
        isLoading = true
        defer { isLoading = false }
        
        let data = NewPickupData(
            restaurantName: restaurant.name,
            distance: 0,
            orderValue: menu.price,
            useReusableContainer: useReusableContainer
        )
        
        do {
            let activity = try await apiManager.logActivity(data: data, isPickup: false)
            await fetchData()
            return activity
        } catch {
            self.error = error
            return nil
        }
    }

    // ... (나머지 기존 함수 유지) ...
    func handleLogPickupSubmit(data: NewPickupData) async {
        guard user != nil else { return }
        isLogPickupModalOpen = false; isLoading = true
        do { _ = try await apiManager.logPickup(data: data); await fetchData() }
        catch { self.error = error; isLoading = false }
    }
    
    func handleAllocateStats(attack: Int, defense: Int) async {
        guard user != nil else { return }
        isLoading = true; isAvatarModalOpen = false
        do { _ = try await apiManager.allocateStatPoints(attack: attack, defense: defense); await fetchData() }
        catch { self.error = error; isLoading = false }
    }
    
    func handleOpenStatsDetail(type: StatDetailType) { statDetailType = type }
}
