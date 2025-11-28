// MARK: - DataTypes.swift

import Foundation

// Helper for Date conversion from ISO string
extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

// MARK: - Core Models (Character, User, Activity)

struct Skill: Codable {
    let name: String
    let description: String
}

struct Character: Codable {
    let id: String
    let name: String
    let modelUrl: String
    let thumbnailUrl: String
    var statPoints: Int
    var attack: Int
    var defense: Int
    let skills: [Skill]
}

struct UserStats: Codable {
    var totalPickups: Int
    var totalCaloriesBurned: Double
    var totalMoneySaved: Int
    var totalCarbonReduced: Double
}

// [수정] User 모델에 '사용 가능한 포인트(cashPoints)'와 '쿠폰함' 추가
struct User: Codable, Identifiable {
    let id: String
    var name: String
    var level: Int
    var exp: Int
    var expToNextLevel: Int
    var cashPoints: Int // 랭킹 점수(exp)와 별개로 실제 사용 가능한 포인트
    var coupons: [Coupon] // 보유 쿠폰 목록
    var stats: UserStats
    var character: Character
}


struct Activity: Codable, Identifiable {
    let id: String
    let restaurantName: String
    let date: Date // Date 타입으로 변환
    let caloriesBurned: Double
    let moneySaved: Int
    let carbonReduced: Double
    let pointsEarned: Int
    let useReusableContainer: Bool
}

// MARK: - Ranking & Utility Types

// [수정] 랭킹 아이템에 '레벨' 추가
struct RankItem: Codable, Identifiable {
    var id: String { userId }
    let rank: Int
    let userId: String
    let name: String
    let level: Int // 랭킹 화면 표시용 레벨
    let score: Int
}

struct Rankings: Codable {
    var local: [RankItem]
    var friends: [RankItem]
    var weekly: [RankItem]
}

struct NewPickupData: Codable {
    let restaurantName: String
    let distance: Double
    let orderValue: Int
    let useReusableContainer: Bool
}

enum StatDetailType: Identifiable {
    case caloriesBurned
    case moneySaved
    
    var id: String {
        switch self {
        case .caloriesBurned: return "caloriesBurned"
        case .moneySaved: return "moneySaved"
        }
    }
}

// MARK: - DataTypes.swift (하단에 추가)

// API Response Type for adding a friend
struct AddFriendResult: Codable {
    let success: Bool
    let message: String
}

// API Error 정의 (APIManager에서 사용)
enum APIError: Error {
    case invalidInput
    case notEnoughStatPoints
    case generalError(String)
}

struct MenuItem: Codable, Identifiable {
    let id: String
    let name: String
    let price: Int
    let imageUrl: String
}

struct Restaurant: Codable, Identifiable {
    let id: String
    let name: String
    let category: String
    let rating: Double
    let deliveryTime: String
    let minOrder: Int
    let imageUrl: String
    let menu: [MenuItem]
}


// [신규] 쿠폰 모델
struct Coupon: Codable, Identifiable {
    var id: String { name }
    let name: String
    let discountRate: Double // 예: 0.1 (10% 할인)
    let description: String
}

// MARK: - DataTypes.swift (맨 아래에 추가)

// User 정보와 Character 정보를 합친 UI용 데이터 모델
struct CharacterDisplayData {
    let id: String
    let name: String
    let modelUrl: String
    let thumbnailUrl: String
    let statPoints: Int
    let attack: Int
    let defense: Int
    let skills: [Skill]
    let level: Int
    let exp: Int
    let expToNextLevel: Int
    
    // User 객체로부터 CharacterDisplayData를 생성하는 이니셜라이저
    init(user: User) {
        self.id = user.character.id
        self.name = user.character.name
        self.modelUrl = user.character.modelUrl
        self.thumbnailUrl = user.character.thumbnailUrl
        self.statPoints = user.character.statPoints
        self.attack = user.character.attack
        self.defense = user.character.defense
        self.skills = user.character.skills
        self.level = user.level
        self.exp = user.exp
        self.expToNextLevel = user.expToNextLevel
    }
}

extension Double {
    /// 소수점 n번째 자리에서 반올림하는 함수
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
