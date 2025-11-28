// MARK: - LogPickupModal.swift

import SwiftUI

struct LogPickupModal: View {
    @EnvironmentObject var viewModel: AppViewModel
    
    // LogPickupModalProps의 역할
    let onClose: () -> Void
    let onSubmit: (NewPickupData) async -> Void
    
    // Form State (TypeScript의 useState 역할)
    @State private var restaurantName: String = ""
    @State private var distance: String = "" // String으로 받아서 숫자로 변환 (입력 필드 형식 유지)
    @State private var orderValue: String = "" // String으로 받아서 숫자로 변환
    @State private var useReusableContainer: Bool = false
    @State private var photo: Data? = nil // 인증샷 파일 (선택 사항)
    
    // Feedback State
    @State private var error: String = ""
    @State private var isSubmitting: Bool = false
    
    // MARK: - Validation & Submission Logic

    private func handleSubmit() {
        error = ""
        
        guard !restaurantName.isEmpty else {
            error = "가게 이름을 입력해주세요."
            return
        }
        
        // 숫자 및 유효성 검사 (distance, orderValue)
        guard let distanceNum = Double(distance), distanceNum > 0 else {
            error = "거리는 0보다 큰 숫자여야 합니다."
            return
        }
        guard let orderValueNum = Int(orderValue), orderValueNum > 0 else {
            error = "주문 금액은 0보다 큰 숫자여야 합니다."
            return
        }
        
        let data = NewPickupData(
            restaurantName: restaurantName,
            distance: distanceNum,
            orderValue: orderValueNum,
            useReusableContainer: useReusableContainer
        )
        
        isSubmitting = true
        Task {
            // onSubmit 호출 (AppViewModel.handleLogPickupSubmit)
            await onSubmit(data)
            
            // 제출 완료 후 모달 닫기 및 필드 초기화
            if viewModel.error == nil { // API 호출 성공 시
                resetForm()
                onClose()
            }
            isSubmitting = false
        }
    }
    
    private func resetForm() {
        restaurantName = ""
        distance = ""
        orderValue = ""
        useReusableContainer = false
        photo = nil
    }

    // MARK: - UI Body
    
    var body: some View {
        NavigationView {
            Form {
                if !error.isEmpty {
                    Text(error)
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Section(header: Text("픽업 정보 입력")) {
                    TextField("가게 이름 (예: 스타벅스)", text: $restaurantName)
                        .textContentType(.name)
                        
                    HStack {
                        TextField("거리 (km)", text: $distance)
                            .keyboardType(.decimalPad)
                        Text("km")
                    }
                    
                    HStack {
                        TextField("주문 금액 (원)", text: $orderValue)
                            .keyboardType(.numberPad)
                        Text("원")
                    }
                }
                
                Section {
                    Toggle(isOn: $useReusableContainer) {
                        Text("다회용기 사용하기 ♻️")
                            .font(.headline)
                            .foregroundColor(Color.green)
                    }
                    .tint(.emerald_500)
                    .padding(.vertical, 4)
                    
                    // 다회용기 사용 시 인증샷 섹션 (간소화)
                    if useReusableContainer {
                        Button("인증샷 첨부하기 (선택 사항)") {
                            // TODO: 실제 이미지 피커 구현 필요
                        }
                        .foregroundColor(Color(.systemGray))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
            }
            .navigationTitle("새로운 픽업 기록")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소", action: onClose)
                        .disabled(isSubmitting)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: handleSubmit) {
                        if isSubmitting {
                            ProgressView()
                        } else {
                            Text("기록하기")
                                .fontWeight(.bold)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.emerald_500)
                    .disabled(isSubmitting || restaurantName.isEmpty || distance.isEmpty || orderValue.isEmpty)
                }
            }
        }
    }
}
