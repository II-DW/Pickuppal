// MARK: - PointShopView.swift (수정됨)

import SwiftUI

struct PointShopView: View {
    @EnvironmentObject var viewModel: AppViewModel
    
    @State private var rotation: Double = 0
    @State private var isSpinning = false
    @State private var showResult = false
    @State private var prize: String = ""
    
    let drawCost = 1000
    let slices = ["꽝", "꽝", "꽝", "1000P", "20% 할인", "40% 할인"]
    
    // 색상을 더 다채롭게 구성
    let colors: [Color] = [
        Color(red: 0.9, green: 0.3, blue: 0.3), // 빨강 (꽝)
        Color(red: 1.0, green: 0.6, blue: 0.2), // 주황 (꽝)
        Color(red: 1.0, green: 0.4, blue: 0.6), // 핑크 (꽝)
        .yellow_400,                            // 노랑 (1000P)
        .blue,                                  // 파랑 (20%)
        .purple                                 // 보라 (40%)
    ]
    
    var body: some View {
        VStack(spacing: 30) {
            Text("🎡 포인트 룰렛")
                .font(.largeTitle.bold())
                .padding(.top)
            
            Spacer()
            
            // 룰렛 휠
            ZStack {
                // 화살표
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.largeTitle)
                    .foregroundColor(.red)
                    .offset(y: -150)
                    .zIndex(1)
                    .shadow(radius: 4)
                
                // 원판과 글자 렌더링 분리
                ZStack {
                    // 1. 배경 조각들
                    ForEach(0..<slices.count, id: \.self) { index in
                        let data = sliceData(at: index)
                        RouletteSlice(startAngle: data.start,
                                      endAngle: data.end,
                                      color: colors[index])
                    }
                    
                    // 2. 글자들 (맨 위에 그리기)
                    ForEach(0..<slices.count, id: \.self) { index in
                        let data = sliceData(at: index)
                        
                        Text(slices[index])
                            .font(.system(size: 18, weight: .heavy))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 1, x: 1, y: 1)
                            .offset(y: -100)
                            .rotationEffect(data.midRotation + .degrees(90))
                    }
                }
                .frame(width: 280, height: 280)
                .rotationEffect(.degrees(rotation))
                .shadow(radius: 10)
                .overlay(
                    Circle().stroke(Color.white, lineWidth: 5)
                )
                
                // 중앙 원
                Circle()
                    .fill(Color.white)
                    .frame(width: 30, height: 30)
                    .shadow(radius: 2)
            }
            
            Spacer()
            
            VStack(spacing: 8) {
                Text("1회 뽑기: \(drawCost) P")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Text("보유: \(viewModel.user?.cashPoints ?? 0) P")
                    .font(.caption)
                    .foregroundColor(.emerald_500)
            }
            
            Button(action: spinWheel) {
                Text(isSpinning ? "돌아가는 중..." : "돌려돌려 돌림판!")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canSpin ? Color.emerald_500 : Color.gray)
                    .cornerRadius(16)
            }
            .disabled(!canSpin || isSpinning)
            .padding()
        }
        .alert(isPresented: $showResult) {
            Alert(title: Text("결과"), message: Text(prize), dismissButton: .default(Text("확인")))
        }
    }
    
    // MARK: - Helper Methods
    
    private func sliceData(at index: Int) -> (start: Angle, end: Angle, midRotation: Angle) {
        let count = Double(slices.count)
        let anglePerSlice = 360.0 / count
        
        let start = Angle.degrees(Double(index) * anglePerSlice)
        let end = Angle.degrees(Double(index + 1) * anglePerSlice)
        
        let mid = Angle.degrees(Double(index) * anglePerSlice + (anglePerSlice / 2.0))
        
        return (start, end, mid)
    }
    
    var canSpin: Bool {
        (viewModel.user?.cashPoints ?? 0) >= drawCost
    }
    
    func spinWheel() {
        guard canSpin else { return }
        
        // 포인트 사용 (성공 시 UI 갱신)
        if viewModel.apiManager.usePoints(amount: drawCost) {
            Task {
                await viewModel.refreshUserData()
            }
        }
        
        isSpinning = true
        
        // 랜덤 회전
        let randomSpin = Double.random(in: 720...1440)
        
        withAnimation(.timingCurve(0.1, 0.7, 0.1, 1.0, duration: 3.0)) {
            rotation += randomSpin
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            isSpinning = false
            let finalResult = slices.randomElement() ?? "꽝"
            
            if finalResult == "꽝" {
                prize = "아쉽지만 꽝입니다! 😭"
            } else if finalResult == "1000P" {
                prize = "축하합니다! 1000P 당첨! (본전!)"
                // [수정] 인스턴스(viewModel.apiManager) 대신 타입(APIManager)으로 접근
                APIManager.mockUser.cashPoints += 1000
                Task { await viewModel.refreshUserData() }
            } else {
                prize = "축하합니다! \(finalResult) 쿠폰 당첨! 🎉"
                // 쿠폰 지급
                _ = viewModel.apiManager.drawCoupon(cost: 0)
                Task { await viewModel.refreshUserData() }
            }
            showResult = true
        }
    }
}

struct RouletteSlice: View {
    var startAngle: Angle
    var endAngle: Angle
    var color: Color
    
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 140, y: 140))
            path.addArc(center: CGPoint(x: 140, y: 140), radius: 140, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        }
        .fill(color)
        .overlay(
            Path { path in
                path.move(to: CGPoint(x: 140, y: 140))
                path.addArc(center: CGPoint(x: 140, y: 140), radius: 140, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            }
            .stroke(Color.white, lineWidth: 1)
        )
    }
}
