// MARK: - AvatarModal.swift (2번 기능: 이미지 참조 UI 구현)

import SwiftUI

struct AvatarModal: View {
    @Binding var isOpen: Bool
    let character: CharacterDisplayData
    let onSubmit: (Int, Int) async -> Void
    
    @State private var attackAdd: Int = 0
    @State private var defenseAdd: Int = 0
    @State private var isSaving: Bool = false
    
    private var currentAttack: Int { character.attack + attackAdd }
    private var currentDefense: Int { character.defense + defenseAdd }
    private var remainingPoints: Int { character.statPoints - (attackAdd + defenseAdd) }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea().onTapGesture { isOpen = false }
            
            VStack(spacing: 0) {
                // 헤더
                Text("아바타 관리")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.white)
                
                Divider()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 1. 프로필 섹션
                        HStack(spacing: 16) {
                            AsyncImage(url: URL(string: character.thumbnailUrl)) { img in
                                img.resizable().scaledToFill()
                            } placeholder: { Color.gray }
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.emerald_500, lineWidth: 3))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(character.name)
                                    .font(.title2.bold())
                                Text("Lv. \(character.level)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        
                        // 2. 포인트 정보 박스 (노란색 배경)
                        VStack(spacing: 8) {
                            Text("사용 가능한 스탯 포인트: \(remainingPoints) / \(character.statPoints)")
                                .font(.headline)
                                .foregroundColor(Color.yellow_900)
                            Text("스탯을 분배하여 캐릭터를 성장시키세요!")
                                .font(.caption)
                                .foregroundColor(Color.yellow_900.opacity(0.8))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.yellow_400.opacity(0.2))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.yellow_400, lineWidth: 1))
                        
                        // 3. 스탯 분배 컨트롤
                        VStack(spacing: 16) {
                            HStack {
                                Text("스탯 분배").font(.headline)
                                Spacer()
                            }
                            
                            statControlRow(label: "⚔️ 공격력", baseValue: character.attack, addedValue: attackAdd) { change in
                                if change > 0 {
                                    if remainingPoints > 0 { attackAdd += 1 }
                                } else {
                                    if attackAdd > 0 { attackAdd -= 1 }
                                }
                            }
                            
                            statControlRow(label: "🛡️ 방어력", baseValue: character.defense, addedValue: defenseAdd) { change in
                                if change > 0 {
                                    if remainingPoints > 0 { defenseAdd += 1 }
                                } else {
                                    if defenseAdd > 0 { defenseAdd -= 1 }
                                }
                            }
                        }
                        
                        // 4. 보유 스킬 리스트
                        VStack(alignment: .leading, spacing: 12) {
                            Text("보유 스킬").font(.headline)
                            
                            ForEach(character.skills, id: \.name) { skill in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(skill.name)
                                        .font(.subheadline.bold())
                                        .foregroundColor(.emerald_500)
                                    Text(skill.description)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                }
                
                // 하단 버튼
                HStack(spacing: 12) {
                    Button("닫기") { isOpen = false }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                        .cornerRadius(12)
                    
                    Button(action: {
                        Task {
                            isSaving = true
                            await onSubmit(attackAdd, defenseAdd)
                            isSaving = false
                            isOpen = false
                        }
                    }) {
                        Text(isSaving ? "저장 중..." : "분배 완료")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.slate_600) // 진한 회색/파란색 계열
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(isSaving || (attackAdd == 0 && defenseAdd == 0))
                }
                .padding()
                .background(Color.white)
            }
            .background(Color.white)
            .cornerRadius(20)
            .padding(.horizontal, 20)
            .padding(.vertical, 40)
        }
    }
    
    // 스탯 조절 행 컴포넌트
    private func statControlRow(label: String, baseValue: Int, addedValue: Int, onChange: @escaping (Int) -> Void) -> some View {
        HStack {
            Text("\(label): \(baseValue + addedValue)")
                .font(.body)
            if addedValue > 0 {
                Text("(+\(addedValue))")
                    .font(.caption.bold())
                    .foregroundColor(.emerald_500)
            }
            Spacer()
            HStack(spacing: 12) {
                Button(action: { onChange(-1) }) {
                    Image(systemName: "minus")
                        .frame(width: 32, height: 32)
                        .background(Color(.systemGray5))
                        .clipShape(Circle())
                        .foregroundColor(.black)
                }
                Button(action: { onChange(1) }) {
                    Image(systemName: "plus")
                        .frame(width: 32, height: 32)
                        .background(Color(.systemGray3)) // 활성 느낌
                        .clipShape(Circle())
                        .foregroundColor(.black)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
    }
}

// 필요한 색상 추가 정의
extension Color {
    static let slate_600 = Color(red: 71/255, green: 85/255, blue: 105/255)
}
