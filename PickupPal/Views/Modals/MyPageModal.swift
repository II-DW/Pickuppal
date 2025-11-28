// MARK: - MyPageModal.swift (최종 안정화 버전)

import SwiftUI

// MARK: - MyPageTabButton (ForEach 오류 해결을 위한 분리된 컴포넌트)
// MyPageModal 구조체 외부에 정의되어야 MyPageModal.swift 파일 전체에서 참조 가능합니다.
struct MyPageTabButton: View {
    @Binding var activeTab: MyPageModal.Tab
    let tab: MyPageModal.Tab
    
    var body: some View {
        Button(tab.rawValue) { activeTab = tab }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(activeTab == tab ? Color.emerald_500 : Color.clear)
            .foregroundColor(activeTab == tab ? Color.emerald_500 : Color(.systemGray))
            .cornerRadius(8)
            .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - MyPageModal View

struct MyPageModal: View {
    @EnvironmentObject var viewModel: AppViewModel
    
    // Props
    let user: User
    let onUpdate: () async -> Void

    // MARK: - State & Enums
    
    // Enum은 struct 내부에 정의해도 됩니다.
    enum Tab: String, CaseIterable, Identifiable {
        case nickname = "이름 변경"
        case friends = "친구 신청"
        var id: String { self.rawValue }
    }
    
    enum MessageType {
        case success, error
        var color: Color { self == .success ? .green : .red }
    }
    
    @State private var activeTab: Tab = .nickname
    @State private var nickname: String = ""
    @State private var friendNickname: String = ""
    @State private var isLoading: Bool = false
    @State private var message: (type: MessageType, text: String)? = nil
    
    // MARK: - Initialization

    init(user: User, onUpdate: @escaping () async -> Void) {
        self.user = user
        self.onUpdate = onUpdate
        _nickname = State(initialValue: user.name)
    }
    
    // MARK: - API Handlers (함수들은 모두 struct 내부에 정의합니다)
    
    private func showMessage(type: MessageType, text: String) {
        self.message = (type, text)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.message = nil
        }
    }
    
    private func handleNicknameSubmit() {
        guard nickname != user.name && !nickname.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        isLoading = true
        Task {
            do {
                _ = try await viewModel.apiManager.updateUsername(newName: nickname)
                await onUpdate()
                showMessage(type: .success, text: "이름이 성공적으로 변경되었습니다.")
            } catch {
                showMessage(type: .error, text: "이름 변경에 실패했습니다.")
            }
            isLoading = false
        }
    }
    
    private func handleAddFriendSubmit() {
        guard !friendNickname.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        isLoading = true
        Task {
            do {
                let result = try await viewModel.apiManager.addFriend(nickname: friendNickname)
                if result.success {
                    await onUpdate()
                    showMessage(type: .success, text: result.message)
                    friendNickname = ""
                } else {
                    showMessage(type: .error, text: result.message)
                }
            } catch {
                showMessage(type: .error, text: "친구 추가에 실패했습니다.")
            }
            isLoading = false
        }
    }

    // MARK: - UI Body
    
    var body: some View {
        VStack(spacing: 0) {
            modalHeader
            tabSelector // MyPageTabButton 사용
            contentArea
            modalFooter
        }
        .presentationDetents([.fraction(0.6)])
    }
    
    // MARK: - Sub Views
    
    private var modalHeader: some View {
        Text("마이페이지")
            .font(.title2.bold())
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
    }
    
    private var tabSelector: some View {
        // MyPageTabButton을 사용해서 복잡도 감소
        HStack(spacing: 8) {
            ForEach(Tab.allCases) { tab in
                MyPageTabButton(activeTab: $activeTab, tab: tab)
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
    }
    
    private var contentArea: some View {
        VStack(spacing: 20) {
            if let msg = message {
                messageBanner(msg: msg)
            }
            
            tabContentView
            
            Spacer()
        }
        .padding()
        .frame(minHeight: 250)
    }

    private var tabContentView: some View {
        Group {
            if activeTab == .nickname {
                nicknameForm
            } else {
                friendForm
            }
        }
    }
    
    private var modalFooter: some View {
        HStack {
            Spacer()
            Button("닫기", action: { viewModel.isMyPageModalOpen = false })
                .buttonStyle(.bordered)
                .tint(Color(.systemGray))
        }
        .padding()
        .background(Color(.systemGray6))
    }

    private func messageBanner(msg: (type: MessageType, text: String)) -> some View {
        Text(msg.text)
            .foregroundColor(msg.type.color)
            .font(.subheadline.weight(.semibold))
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(msg.type.color.opacity(0.1))
            .cornerRadius(8)
    }

    private var nicknameForm: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("새 닉네임").font(.subheadline.weight(.medium))
            
            TextField("", text: $nickname)
                .textFieldStyle(.roundedBorder)
                .background(Color(.systemGray6)).cornerRadius(8)
            
            Button(action: handleNicknameSubmit) {
                Text(isLoading ? "저장 중..." : "저장하기").fontWeight(.bold).frame(maxWidth: .infinity).padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent).tint(.emerald_500).disabled(isLoading || nickname == user.name || nickname.isEmpty)
        }
    }
    
    private var friendForm: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("친구 닉네임").font(.subheadline.weight(.medium))
            
            TextField("친구의 닉네임을 입력하세요", text: $friendNickname)
                .textFieldStyle(.roundedBorder)
            
            Button(action: handleAddFriendSubmit) {
                Text(isLoading ? "추가 중..." : "친구 추가").fontWeight(.bold).frame(maxWidth: .infinity).padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent).tint(.emerald_500).disabled(isLoading || friendNickname.isEmpty)
        }
    }
}
