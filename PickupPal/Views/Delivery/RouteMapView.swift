// MARK: - RouteMapView.swift

import SwiftUI

// [핵심 1] 경로를 따라 이동하는 애니메이션 효과 (마커 이동용)
struct RouteFollower: GeometryEffect {
    var pct: CGFloat
    let p1: CGPoint, p2: CGPoint, p3: CGPoint, p4: CGPoint
    
    var animatableData: CGFloat {
        get { pct }
        set { pct = newValue }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let pt = calculatePosition(progress: pct)
        return ProjectionTransform(CGAffineTransform(translationX: pt.x, y: pt.y))
    }
    
    private func calculatePosition(progress: CGFloat) -> CGPoint {
        let d1 = abs(p2.y - p1.y), d2 = abs(p3.x - p2.x), d3 = abs(p4.y - p3.y)
        let total = d1 + d2 + d3
        let r1 = d1 / total, r2 = d2 / total
        
        if progress <= r1 {
            let local = r1 > 0 ? progress / r1 : 1.0
            return CGPoint(x: p1.x, y: p1.y + (p2.y - p1.y) * local)
        } else if progress <= (r1 + r2) {
            let local = r2 > 0 ? (progress - r1) / r2 : 1.0
            return CGPoint(x: p2.x + (p3.x - p2.x) * local, y: p2.y)
        } else {
            let r3 = 1.0 - (r1 + r2)
            let local = r3 > 0 ? (progress - (r1 + r2)) / r3 : 1.0
            return CGPoint(x: p3.x, y: p3.y + (p4.y - p3.y) * local)
        }
    }
}

// [핵심 2] 숫자가 부드럽게 변하는 텍스트 뷰 (카운팅 애니메이션용)
struct RollingText: View, Animatable {
    var value: Double
    var format: String
    var suffix: String = ""
    var font: Font = .body
    var color: Color = .primary
    
    var animatableData: Double {
        get { value }
        set { value = newValue }
    }
    
    var body: some View {
        Text("\(String(format: format, value))\(suffix)")
            .font(font)
            .foregroundColor(color)
            // 숫자가 흔들리지 않도록 고정폭 폰트 적용 (선택사항)
            .monospacedDigit()
    }
}

struct RouteMapView: View {
    @EnvironmentObject var viewModel: AppViewModel
    let onComplete: (Activity) -> Void
    
    @State private var progress: CGFloat = 0.0
    @State private var showArrivalModal: Bool = false
    
    var session: PickupSession? { viewModel.currentPickupSession }
    
    // 좌표 설정
    let p1 = CGPoint(x: 120, y: 650)
    let p2 = CGPoint(x: 120, y: 400)
    let p3 = CGPoint(x: 280, y: 400)
    let p4 = CGPoint(x: 280, y: 200)
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 1. 지도 배경 및 요소
            ZStack(alignment: .topLeading) {
                Color(red: 0.9, green: 0.93, blue: 0.9).ignoresSafeArea()
                
                // 도로망
                Path { path in
                    for x in [40, 120, 200, 280, 360] {
                        path.move(to: CGPoint(x: x, y: 0)); path.addLine(to: CGPoint(x: x, y: 900))
                    }
                    for y in [100, 250, 400, 550, 700] {
                        path.move(to: CGPoint(x: 0, y: y)); path.addLine(to: CGPoint(x: 450, y: y))
                    }
                }
                .stroke(Color.white, lineWidth: 15)
                
                // 경로선
                Path { path in
                    path.move(to: p1); path.addLine(to: p2); path.addLine(to: p3); path.addLine(to: p4)
                }
                .trim(from: 0, to: progress)
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 5, lineCap: .round, dash: [8, 8]))
                
                // 가게 마커
                VStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.red)
                        .background(Circle().fill(Color.white))
                        .shadow(radius: 2)
                    Text(session?.restaurant.name ?? "가게")
                        .font(.caption.bold())
                        .padding(6)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 1)
                }
                .position(p4)
                .offset(y: -35)
                
                // 내 위치 마커
                ZStack {
                    Circle().fill(Color.blue.opacity(0.2)).frame(width: 60, height: 60)
                    Circle().fill(Color.white).frame(width: 24, height: 24).shadow(radius: 2)
                    Circle().fill(Color.blue).frame(width: 16, height: 16)
                }
                .position(x: 0, y: 0)
                .modifier(RouteFollower(pct: progress, p1: p1, p2: p2, p3: p3, p4: p4))
            }
            
            // 2. 하단 정보 카드
            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(progress < 1.0 ? "픽업 매장으로 이동 중" : "매장 도착!")
                            .font(.headline)
                            .foregroundColor(progress < 1.0 ? .gray : .emerald_500)
                        Text(session?.restaurant.name ?? "")
                            .font(.title2.bold())
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("남은 거리")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        // [수정] RollingText 적용: 남은 거리 줄어드는 애니메이션
                        RollingText(
                            value: (session?.distance ?? 0) * (1.0 - Double(progress)),
                            format: "%.1f",
                            suffix: "km",
                            font: .title.bold(),
                            color: .blue
                        )
                    }
                }
                
                Divider()
                
                HStack {
                    Image(systemName: "shoeprints.fill")
                        .foregroundColor(.emerald_500)
                    
                    HStack(spacing: 4) {
                        Text("현재 걸음 수: 약")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        
                        // [수정] RollingText 적용: 걸음 수 늘어나는 애니메이션
                        RollingText(
                            value: (session?.distance ?? 0) * 1300 * Double(progress),
                            format: "%.0f",
                            suffix: "보",
                            font: .subheadline.bold(), // 숫자는 굵게
                            color: .black
                        )
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(Color.emerald_100.opacity(0.5))
                .cornerRadius(12)
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.1), radius: 10, y: -5)
            .padding(.bottom, 100)
            
            // 3. 도착 알림 모달
            if showArrivalModal {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea().onTapGesture { }
                    
                    VStack(spacing: 24) {
                        Image(systemName: "flag.checkered.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.emerald_500)
                            .background(Circle().fill(Color.white))
                        
                        VStack(spacing: 8) {
                            Text("매장에 도착했습니다!")
                                .font(.title2.bold())
                            Text("주문하신 메뉴를 픽업해주세요.")
                                .foregroundColor(.gray)
                        }
                        
                        Button(action: {
                            Task {
                                if let activity = await viewModel.completePickup() {
                                    onComplete(activity)
                                }
                            }
                        }) {
                            Text("픽업 완료 및 포인트 받기")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.emerald_500)
                                .cornerRadius(16)
                        }
                    }
                    .padding(30)
                    .background(Color.white)
                    .cornerRadius(24)
                    .shadow(radius: 20)
                    .padding(.horizontal, 40)
                    .offset(y: -50)
                }
                .zIndex(100)
                .transition(.opacity)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            // 4초 동안 이동 애니메이션
            withAnimation(.linear(duration: 4.0)) {
                progress = 1.0
            }
            
            // 4초 후 도착 모달
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                withAnimation(.spring()) {
                    showArrivalModal = true
                }
            }
        }
    }
}
