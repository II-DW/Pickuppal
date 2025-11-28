// MARK: - DeliveryView.swift

import SwiftUI
import ConfettiSwiftUI

struct DeliveryView: View {
    // MARK: - Environment & State
    @EnvironmentObject var viewModel: AppViewModel
    
    @State private var category: String = "전체"
    @State private var selectedRestaurant: Restaurant? = nil
    @State private var selectedMenu: MenuItem? = nil
    @State private var orderComplete: OrderCompleteData? = nil
    @State private var usePointsAmount: String = ""
    @State private var useReusableContainer: Bool = false
    
    // 폭죽 애니메이션 트리거
    @State private var confettiCounter: Int = 0
    
    // MARK: - Local Types
    struct OrderCompleteData {
        let type: OrderType
        let itemName: String
        let earnedPoints: Int
        let distance: Double
    }
    
    enum OrderType {
        case delivery, pickup
    }

    let categories = ["전체", "치킨", "피자", "한식", "분식", "카페/디저트", "일식", "양식"]
    
    // MARK: - Mock Data
    let restaurants: [Restaurant] = [
        Restaurant(id: "r1", name: "황금올리브 치킨", category: "치킨", rating: 4.8, deliveryTime: "40-50분", minOrder: 15000, imageUrl: "https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=500&q=80", menu: [
            MenuItem(id: "m1", name: "황금올리브 치킨", price: 20000, imageUrl: "https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=200&q=80"),
            MenuItem(id: "m2", name: "양념 치킨", price: 21000, imageUrl: "https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=200&q=80")
        ]),
        Restaurant(id: "r2", name: "도미노 피자", category: "피자", rating: 4.7, deliveryTime: "30-40분", minOrder: 20000, imageUrl: "https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500&q=80", menu: [
             MenuItem(id: "m3", name: "포테이토 피자", price: 25000, imageUrl: "https://images.unsplash.com/photo-1513104890138-7c749659a591?w=200&q=80"),
             MenuItem(id: "m4", name: "페퍼로니 피자", price: 23000, imageUrl: "https://images.unsplash.com/photo-1513104890138-7c749659a591?w=200&q=80")
        ]),
        Restaurant(id: "r3", name: "엽기 떡볶이", category: "분식", rating: 4.9, deliveryTime: "30-45분", minOrder: 14000, imageUrl: "https://images.unsplash.com/photo-1625244515785-c900783451e9?w=500&q=80", menu: [
            MenuItem(id: "m5", name: "엽기 떡볶이", price: 14000, imageUrl: "https://images.unsplash.com/photo-1580651315530-69c8e0026377?w=500&q=80"),
            MenuItem(id: "m6", name: "모둠 튀김", price: 4000, imageUrl: "https://images.unsplash.com/photo-1580651315530-69c8e0026377?w=500&q=80")
        ]),
        Restaurant(id: "r4", name: "메가 커피", category: "카페/디저트", rating: 4.6, deliveryTime: "20-30분", minOrder: 8000, imageUrl: "https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=500&q=80", menu: [
            MenuItem(id: "m7", name: "아메리카노", price: 2000, imageUrl: "https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=200&q=80"),
            MenuItem(id: "m8", name: "카페라떼", price: 3500, imageUrl: "https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=200&q=80")
        ]),
        Restaurant(id: "r5", name: "맥도날드", category: "양식", rating: 4.5, deliveryTime: "25-35분", minOrder: 12000, imageUrl: "https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=500&q=80", menu: [
            MenuItem(id: "m9", name: "빅맥 세트", price: 7500, imageUrl: "https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=200&q=80"),
            MenuItem(id: "m10", name: "상하이 버거", price: 6500, imageUrl: "https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=200&q=80")
        ])
    ]
    
    var filteredRestaurants: [Restaurant] {
        category == "전체" ? restaurants : restaurants.filter { $0.category == category }
    }

    // MARK: - Body
    
    var body: some View {
        ZStack {
            if let order = orderComplete {
                orderCompleteView(order: order)
            } else if viewModel.currentPickupSession != nil {
                // 지도 화면 (ContentView에서 띄우므로 여기선 투명 처리하거나 비워둠)
                // 만약 여기서 띄워야 한다면 RouteMapView { ... } 사용
                RouteMapView { activity in
                    orderComplete = OrderCompleteData(
                        type: .pickup,
                        itemName: activity.restaurantName,
                        earnedPoints: activity.pointsEarned,
                        distance: activity.carbonReduced / 0.15
                    )
                    selectedMenu = nil
                    selectedRestaurant = nil
                    usePointsAmount = ""
                }
            } else if let restaurant = selectedRestaurant {
                restaurantDetailView(restaurant: restaurant)
            } else {
                mainListView
            }
            
            // 지도 화면이 아닐 때만 메뉴 모달 표시
            if let menu = selectedMenu, viewModel.currentPickupSession == nil {
                menuModal(menu: menu)
            }
        }
    }
    
    // MARK: - Sub Views (누락되었던 뷰들 포함)
    
    var mainListView: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("오늘 뭐 먹지?")
                        .font(.title2.bold())
                    Text("포장 주문으로 지구도 지키고 포인트도 받으세요!")
                        .opacity(0.9)
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(LinearGradient(colors: [.emerald_500, .teal], startPoint: .leading, endPoint: .trailing))
                .cornerRadius(16)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { cat in
                            Button(action: { category = cat }) {
                                Text(cat)
                                    .font(.subheadline.weight(.medium))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(category == cat ? Color.primary : Color(.systemBackground))
                                    .foregroundColor(category == cat ? Color(.systemBackground) : .primary)
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color(.systemGray4), lineWidth: category == cat ? 0 : 1)
                                    )
                            }
                        }
                    }
                }
                
                VStack(spacing: 16) {
                    if filteredRestaurants.isEmpty {
                        Text("해당 카테고리의 가게가 없습니다.")
                            .foregroundColor(.gray)
                            .padding(.top, 40)
                    } else {
                        ForEach(filteredRestaurants) { restaurant in
                            restaurantRow(restaurant: restaurant)
                                .onTapGesture {
                                    selectedRestaurant = restaurant
                                }
                        }
                    }
                }
            }
            .padding()
            .padding(.bottom, 80)
        }
    }
    
    func restaurantRow(restaurant: Restaurant) -> some View {
        HStack(spacing: 16) {
            AsyncImage(url: URL(string: restaurant.imageUrl)) { img in
                img.resizable().scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 96, height: 96)
            .cornerRadius(8)
            .clipped()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.headline)
                
                HStack(spacing: 4) {
                    Text("★")
                        .foregroundColor(.yellow_400)
                    Text("\(String(format: "%.1f", restaurant.rating))")
                        .fontWeight(.medium)
                    Text("• \(restaurant.category)")
                        .foregroundColor(.gray)
                }
                .font(.subheadline)
                
                HStack {
                    Text(restaurant.deliveryTime)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(.systemGray6))
                        .cornerRadius(4)
                    
                    Text("최소주문 \(restaurant.minOrder.formatted())원")
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    func restaurantDetailView(restaurant: Restaurant) -> some View {
        ScrollView {
            VStack(alignment: .leading) {
                ZStack(alignment: .bottomLeading) {
                    AsyncImage(url: URL(string: restaurant.imageUrl)) { img in
                        img.resizable().scaledToFill()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(height: 200)
                    .clipped()
                    
                    LinearGradient(colors: [.black.opacity(0.6), .clear], startPoint: .bottom, endPoint: .top)
                    
                    HStack {
                        Text("★")
                            .foregroundColor(.yellow_400)
                        Text("\(String(format: "%.1f", restaurant.rating))")
                        Text("최소주문 \(restaurant.minOrder.formatted())원")
                            .font(.caption)
                            .opacity(0.8)
                    }
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding()
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("대표 메뉴")
                        .font(.title3.bold())
                    
                    ForEach(restaurant.menu) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.headline)
                                Text("\(item.price.formatted())원")
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            AsyncImage(url: URL(string: item.imageUrl)) { img in
                                img.resizable().scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.3)
                            }
                            .frame(width: 80, height: 80)
                            .cornerRadius(8)
                        }
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedMenu = item
                            useReusableContainer = false
                        }
                        Divider()
                    }
                }
                .padding()
                .padding(.bottom, 80)
            }
        }
        .overlay(alignment: .topLeading) {
            Button(action: { selectedRestaurant = nil }) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.primary)
                    .padding()
                    .background(Circle().fill(Color(.systemBackground)))
                    .shadow(radius: 2)
            }
            .padding()
        }
    }
    
    func menuModal(menu: MenuItem) -> some View {
        let deliveryFee = 3000
        let itemPrice = menu.price
        let maxPoints = viewModel.user?.cashPoints ?? 0
        let pointsToUse = min(Int(usePointsAmount) ?? 0, maxPoints)
        let finalPriceDelivery = max(0, itemPrice + deliveryFee - pointsToUse)
        let finalPricePickup = max(0, itemPrice - pointsToUse)
        
        return ZStack(alignment: .bottom) {
            Color.black.opacity(0.6).ignoresSafeArea().onTapGesture { selectedMenu = nil }
            
            VStack(spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: URL(string: menu.imageUrl)) { img in
                        img.resizable().scaledToFill()
                    } placeholder: { Color.gray }
                    .frame(height: 200).clipped()
                    
                    Button(action: { selectedMenu = nil }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Circle().fill(Color.black.opacity(0.5)))
                    }
                    .padding()
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading) {
                        Text(menu.name).font(.title2.bold())
                        Text("\(itemPrice.formatted())원").font(.title3).foregroundColor(.gray)
                    }
                    
                    Toggle(isOn: $useReusableContainer) {
                        HStack {
                            Text("다회용기 사용하기 ♻️").font(.headline).foregroundColor(.green)
                            Spacer()
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .emerald_500))
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("포인트 사용 (보유: \(maxPoints) P)").font(.caption).foregroundColor(.gray)
                        HStack {
                            TextField("사용할 포인트 입력", text: $usePointsAmount)
                                .keyboardType(.numberPad)
                                .padding(10)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            Button("전액") { usePointsAmount = "\(maxPoints)" }
                                .font(.caption.bold())
                                .padding(8)
                                .background(Color.emerald_100)
                                .foregroundColor(.emerald_500)
                                .cornerRadius(8)
                        }
                        if pointsToUse > 0 {
                            Text("-\(pointsToUse.formatted())원 할인 적용됨").font(.caption).foregroundColor(.red)
                        }
                    }
                    Divider()
                    
                    HStack(spacing: 12) {
                        // 배달 버튼
                        Button(action: {
                            guard let restaurant = selectedRestaurant else { return }
                            if viewModel.apiManager.usePoints(amount: pointsToUse) {
                                Task {
                                    await viewModel.refreshUserData()
                                    let activity = await viewModel.processDeliveryOrder(restaurant: restaurant, menu: menu, useReusableContainer: false)
                                    orderComplete = OrderCompleteData(type: .delivery, itemName: menu.name, earnedPoints: activity?.pointsEarned ?? 0, distance: 0)
                                    selectedMenu = nil; selectedRestaurant = nil; usePointsAmount = ""
                                }
                            }
                        }) {
                            VStack {
                                Text("🛵 배달 주문").font(.headline)
                                Text("최종 \(finalPriceDelivery.formatted())원").font(.caption)
                            }
                            .frame(maxWidth: .infinity).padding()
                            .background(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4), lineWidth: 2))
                        }.foregroundColor(.primary)
                        
                        // 포장 버튼
                        Button(action: {
                            guard let restaurant = selectedRestaurant else { return }
                            if viewModel.apiManager.usePoints(amount: pointsToUse) {
                                Task {
                                    await viewModel.refreshUserData()
                                    viewModel.startPickup(restaurant: restaurant, menu: menu, useReusableContainer: useReusableContainer)
                                    selectedMenu = nil; selectedRestaurant = nil; usePointsAmount = ""
                                }
                            }
                        }) {
                            VStack {
                                Text("🏃 포장 주문").font(.headline)
                                Text("최종 \(finalPricePickup.formatted())원").font(.caption)
                            }
                            .frame(maxWidth: .infinity).padding()
                            .background(Color.emerald_100.opacity(0.3))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.emerald_500, lineWidth: 2))
                        }.foregroundColor(.emerald_500)
                    }
                }.padding().background(Color(.systemBackground))
            }.cornerRadius(16).padding()
        }
    }
    
    // MARK: - Order Complete View (폭죽 적용)
    
    func orderCompleteView(order: OrderCompleteData) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.emerald_500)
                .padding(20)
                .background(Circle().fill(Color.emerald_100))
            
            Text("주문이 완료되었습니다!")
                .font(.title2.bold())
            
            Text("\(order.itemName)\(order.type == .pickup ? "을(를) 포장 주문했습니다." : "이(가) 곧 배달됩니다.")")
                .multilineTextAlignment(.center)
            
            Text("+\(order.earnedPoints) P 적립 완료!")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.orange)
                .cornerRadius(20)
            
            if order.type == .pickup {
                VStack(alignment: .leading, spacing: 4) {
                    Text("🎁 픽업 보너스")
                        .font(.headline)
                        .foregroundColor(.emerald_500)
                    Text("매장 방문 시 배달비 절약 인증을 통해 포인트를 획득하세요!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.emerald_100.opacity(0.3))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.emerald_100, lineWidth: 1))
            }
            
            Button("홈으로 돌아가기") {
                orderComplete = nil
                confettiCounter = 0
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.emerald_500)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.top, 20)
        }
        .padding(30)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()
        // [수정] Confetti 라이브러리 문법 업데이트 (counter -> trigger)
        .confettiCannon(trigger: $confettiCounter, num: 50, colors: [.emerald_500, .orange, .blue], confettiSize: 10, rainHeight: 800, fadesOut: true, opacity: 1.0, openingAngle: .degrees(0), closingAngle: .degrees(360), radius: 300)
        .onAppear {
            confettiCounter += 1
        }
    }
}
