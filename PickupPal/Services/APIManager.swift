// MARK: - APIManager.swift (포인트 적립 및 활동 등록 개선)

import Foundation

@MainActor
class APIManager: ObservableObject {
    
    // --- MOCK DATABASE ---
    
    private static var mockCharacter: Character = Character(
        id: "char_1", name: "피키",
        modelUrl: "https://modelviewer.dev/shared-assets/models/RobotExpressive.glb",
        thumbnailUrl: "https://i.pravatar.cc/150?u=char_1",
        statPoints: 15, attack: 25, defense: 18,
        skills: [
            Skill(name: "절약의 일격", description: "절약 금액에 비례하여 추가 포인트를 획득합니다."),
            Skill(name: "탄소 방패", description: "탄소 절감량이 높을수록 방어력이 증가합니다.")
        ]
    )

    // [누적 포인트 12000, 사용 가능 포인트 5000]
    static var mockUser: User = User(
        id: "user_1", name: "김픽업", level: 25, exp: 12000, expToNextLevel: 15000,
        cashPoints: 5000, coupons: [],
        stats: UserStats(totalPickups: 128, totalCaloriesBurned: 5450, totalMoneySaved: 342000, totalCarbonReduced: 45.5),
        character: APIManager.mockCharacter
    )

    private static let allOtherUsers: [User] = [
        User(id: "user_2", name: "박배달", level: 20, exp: 9500, expToNextLevel: 10000, cashPoints: 0, coupons: [], stats: UserStats(totalPickups: 10, totalCaloriesBurned: 500, totalMoneySaved: 10000, totalCarbonReduced: 2.0), character: APIManager.mockCharacter),
        User(id: "user_3", name: "이포장", level: 18, exp: 8200, expToNextLevel: 9000, cashPoints: 0, coupons: [], stats: UserStats(totalPickups: 15, totalCaloriesBurned: 800, totalMoneySaved: 15000, totalCarbonReduced: 3.5), character: APIManager.mockCharacter),
        User(id: "user_4", name: "최워킹", level: 15, exp: 7000, expToNextLevel: 8000, cashPoints: 0, coupons: [], stats: UserStats(totalPickups: 5, totalCaloriesBurned: 300, totalMoneySaved: 5000, totalCarbonReduced: 1.0), character: APIManager.mockCharacter),
        User(id: "user_5", name: "강달려", level: 22, exp: 11000, expToNextLevel: 12000, cashPoints: 0, coupons: [], stats: UserStats(totalPickups: 20, totalCaloriesBurned: 1000, totalMoneySaved: 30000, totalCarbonReduced: 5.0), character: APIManager.mockCharacter),
        User(id: "user_6", name: "조절약", level: 10, exp: 4500, expToNextLevel: 5000, cashPoints: 0, coupons: [], stats: UserStats(totalPickups: 8, totalCaloriesBurned: 400, totalMoneySaved: 8000, totalCarbonReduced: 1.5), character: APIManager.mockCharacter)
    ]
    
    static var mockFriends: [User] = Array(allOtherUsers.prefix(1))

    static var mockActivities: [Activity] = [
        Activity(id: "act_1", restaurantName: "피자헛", date: Date().addingTimeInterval(-3600), caloriesBurned: 60, moneySaved: 3000, carbonReduced: 0.35, pointsEarned: 55, useReusableContainer: true),
        Activity(id: "act_2", restaurantName: "BHC 치킨", date: Date().addingTimeInterval(-86400 * 2), caloriesBurned: 45, moneySaved: 3000, carbonReduced: 0.2, pointsEarned: 40, useReusableContainer: false),
    ]

    private func simulateDelay() async {
        try? await Task.sleep(nanoseconds: 500_000_000)
    }

    // MARK: - Public API Methods

    func fetchUserData() async throws -> User {
        await simulateDelay()
        return APIManager.mockUser
    }

    func fetchActivities() async throws -> [Activity] {
        await simulateDelay()
        return APIManager.mockActivities
    }

    func fetchRankings() async throws -> Rankings {
        await simulateDelay()
        
        var allUsers = APIManager.allOtherUsers
        allUsers.append(APIManager.mockUser)
        let sortedUsers = allUsers.sorted { $0.exp > $1.exp }
        
        let rankItems = sortedUsers.enumerated().map { (index, user) in
            RankItem(rank: index + 1, userId: user.id, name: user.name, level: user.level, score: user.exp)
        }
        
        return Rankings(
            local: rankItems,
            friends: rankItems.filter { item in APIManager.mockFriends.contains(where: { $0.id == item.userId }) || item.userId == APIManager.mockUser.id },
            weekly: rankItems.shuffled()
        )
    }
    
    // [수정] 배달/픽업 구분하여 활동 기록 및 포인트 적립
    func logActivity(data: NewPickupData, isPickup: Bool) async throws -> Activity {
        await simulateDelay()
        
        var caloriesBurned: Double = 0
        var moneySaved: Int = 0
        var carbonReduced: Double = 0.0
        var basePoints: Int = 0
        
        if isPickup {
            // 픽업일 때: 거리 비례 칼로리, 탄소 절감, 배달비 절약
            caloriesBurned = round(data.distance * 30.0)
            moneySaved = 3000
            carbonReduced = (data.distance * 0.15).rounded(toPlaces: 2)
            if data.useReusableContainer { carbonReduced += 0.05 }
            
            // 포인트 공식: (칼로리*0.5) + (절약금액/100) + (탄소*20)
            basePoints = Int(round(caloriesBurned * 0.5 + Double(moneySaved) / 100.0 + carbonReduced * 20.0))
        } else {
            // 배달일 때: 주문 금액의 0.5%만 포인트 적립 (환경/건강 점수 없음)
            basePoints = Int(Double(data.orderValue) * 0.005)
        }
        
        // 캐릭터 공격력 보너스 (예: 공격력 1당 1% 추가)
        let bonusRate = Double(APIManager.mockUser.character.attack) * 0.01
        let totalPoints = Int(Double(basePoints) * (1.0 + bonusRate))

        let newActivity = Activity(
            id: UUID().uuidString,
            restaurantName: data.restaurantName,
            date: Date(),
            caloriesBurned: caloriesBurned,
            moneySaved: moneySaved,
            carbonReduced: carbonReduced,
            pointsEarned: totalPoints,
            useReusableContainer: data.useReusableContainer
        )

        // 유저 스탯 업데이트
        if isPickup {
            APIManager.mockUser.stats.totalPickups += 1
            APIManager.mockUser.stats.totalCaloriesBurned += caloriesBurned
            APIManager.mockUser.stats.totalMoneySaved += moneySaved
            APIManager.mockUser.stats.totalCarbonReduced += carbonReduced
        }
        
        // [핵심] 포인트 및 경험치 적립
        APIManager.mockUser.exp += totalPoints        // 랭킹용 누적 포인트
        APIManager.mockUser.cashPoints += totalPoints // [수정] 사용 가능 포인트도 증가!
        
        // 레벨업 체크
        if APIManager.mockUser.exp >= APIManager.mockUser.expToNextLevel {
            APIManager.mockUser.level += 1
            APIManager.mockUser.expToNextLevel = Int(Double(APIManager.mockUser.expToNextLevel) * 1.2)
            APIManager.mockUser.character.statPoints += 3
        }
        
        APIManager.mockActivities.insert(newActivity, at: 0)
        return newActivity
    }
    
    // 기존 호환성을 위해 남겨둠 (내부적으로 logActivity 호출)
    func logPickup(data: NewPickupData) async throws -> Activity {
        return try await logActivity(data: data, isPickup: true)
    }
    
    func updateUsername(newName: String) async throws -> User {
        await simulateDelay()
        guard !newName.trimmingCharacters(in: .whitespaces).isEmpty else { throw APIError.invalidInput }
        APIManager.mockUser.name = newName
        return APIManager.mockUser
    }
    
    func addFriend(nickname: String) async throws -> AddFriendResult {
        await simulateDelay()
        if let friend = APIManager.allOtherUsers.first(where: { $0.name == nickname }) {
             if !APIManager.mockFriends.contains(where: { $0.id == friend.id }) {
                 APIManager.mockFriends.append(friend)
                 return AddFriendResult(success: true, message: "\(nickname)님을 친구로 추가했습니다.")
             }
             return AddFriendResult(success: false, message: "이미 친구입니다.")
        }
        return AddFriendResult(success: false, message: "사용자를 찾을 수 없습니다.")
    }
    
    func allocateStatPoints(attack: Int, defense: Int) async throws -> Character {
        await simulateDelay()
        let cost = attack + defense
        if APIManager.mockUser.character.statPoints >= cost {
            APIManager.mockUser.character.attack += attack
            APIManager.mockUser.character.defense += defense
            APIManager.mockUser.character.statPoints -= cost
            return APIManager.mockUser.character
        } else {
            throw APIError.notEnoughStatPoints
        }
    }
    
    func usePoints(amount: Int) -> Bool {
        if APIManager.mockUser.cashPoints >= amount {
            APIManager.mockUser.cashPoints -= amount
            return true
        }
        return false
    }
    
    func drawCoupon(cost: Int) -> Coupon? {
        guard usePoints(amount: cost) else { return nil }
        return Coupon(name: "랜덤 쿠폰", discountRate: 0.1, description: "축하합니다!")
    }
    
    func rewardSteps(steps: Int) async throws -> Int {
        await simulateDelay()
        let points = min(steps / 100, 100)
        APIManager.mockUser.cashPoints += points
        return points
    }
}
