// MARK: - LuckyDrawView.swift (4번 기능: 신규 파일)

import SwiftUI

struct LuckyDrawView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var showResult = false
    @State private var wonCoupon: Coupon? = nil
    @State private var isAnimating = false
    
    let drawCost = 1000 // 1회 비용
    
    var body: some View {
        VStack(spacing: 30) {
            Text("🍀 행운의 뽑기")
                .font(.largeTitle.bold())
            
            Spacer()
            
            // 뽑기 기계 이미지 (텍스트나 아이콘으로 대체)
            VStack {
                Text(isAnimating ? "🎰" : "🎁")
                    .font(.system(size: 100))
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.2).repeatForever(), value: isAnimating)
            }
            
            Spacer()
            
            Text("1회: \(drawCost) P")
                .font(.headline)
                .foregroundColor(.gray)
            
            Button(action: startDraw) {
                Text("뽑기 시작!")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.user?.cashPoints ?? 0 >= drawCost ? Color.emerald_500 : Color.gray)
                    .cornerRadius(16)
            }
            .disabled(viewModel.user?.cashPoints ?? 0 < drawCost || isAnimating)
            .padding()
        }
        .padding()
        .alert("결과", isPresented: $showResult) {
            Button("확인", role: .cancel) { }
        } message: {
            if let coupon = wonCoupon {
                Text("축하합니다! '\(coupon.name)'에 당첨되었습니다!")
            } else {
                Text("아쉽지만 꽝입니다. 다음 기회에!")
            }
        }
    }
    
    func startDraw() {
        isAnimating = true
        
        // 2초 딜레이 후 결과 확인
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isAnimating = false
            wonCoupon = viewModel.apiManager.drawCoupon(cost: drawCost)
            showResult = true
        }
    }
}
