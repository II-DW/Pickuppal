// MARK: - CharacterView.swift

import SwiftUI

struct CharacterView: View {
    let character: Character
    let level: Int
    let exp: Int
    let expToNextLevel: Int
    let onManage: () -> Void
    
    @State private var animationName: String = "Idle"
    
    private let animations = [
        (key: "Idle", label: "대기", variants: ["Idle"]),
        (key: "Walking", label: "걷기", variants: ["Walking"]),
        (key: "Running", label: "뛰기", variants: ["Running"]),
        (key: "Dance", label: "댄스", variants: ["Dance", "Jump", "Wave"])
    ]

    var body: some View {
        ScrollView { // [수정] 전체 스크롤 가능하도록 변경
            VStack(spacing: 16) {
                
                // 3D Model Area
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                        .frame(height: 350) // 높이 확보
                    
                    // [수정] WebModelViewer 사용
                    WebModelViewer(src: character.modelUrl, animationName: animationName)
                        .frame(height: 350)
                        .cornerRadius(16)
                        .allowsHitTesting(true) // 터치 허용 (모델 돌리기)
                    
                    // Level Badge
                    VStack {
                        HStack {
                            Text("\(level)")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .frame(width: 48, height: 48)
                                .background(Color.emerald_500)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .padding(16)
                            Spacer()
                        }
                        Spacer()
                    }
                    
                    // Animation Controls
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(animations, id: \.key) { anim in
                                Button {
                                    if let randomVariant = anim.variants.randomElement() {
                                        animationName = randomVariant
                                    }
                                } label: {
                                    Text(anim.label)
                                        .font(.caption.bold())
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8) // 터치 영역 확보
                                        .background(anim.variants.contains(animationName) ? Color.emerald_500 : Color.white.opacity(0.9))
                                        .foregroundColor(anim.variants.contains(animationName) ? .white : .primary)
                                        .cornerRadius(20)
                                        .shadow(radius: 2)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                    }
                }
                
                // Character Info
                VStack(spacing: 4) {
                    Text(character.name)
                        .font(.largeTitle.bold())
                        .foregroundColor(Color(.label))
                    Text("Lv. \(level)")
                        .font(.headline)
                        .foregroundColor(Color(.systemGray))
                }

                // Experience Bar
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("다음 레벨까지")
                            .font(.subheadline)
                            .foregroundColor(Color(.systemGray))
                        Spacer()
                        Text("\(exp) / \(expToNextLevel) EXP")
                            .font(.subheadline.bold())
                            .foregroundColor(Color(.label))
                    }
                    
                    ProgressView(value: Double(exp) / Double(expToNextLevel))
                        .progressViewStyle(LinearProgressViewStyle(tint: .emerald_500))
                        .frame(height: 8)
                        .scaleEffect(y: 2) // 바 두께 조절
                        .background(Color(.systemGray5))
                        .cornerRadius(4)
                }
                .padding(.top, 8)

                // Stats
                HStack {
                    statDisplay(label: "⚔️ 공격력", value: character.attack)
                    Spacer()
                    Divider()
                    Spacer()
                    statDisplay(label: "🛡️ 방어력", value: character.defense)
                }
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 2)

                // Manage Button [수정] 클릭 잘 되도록 크기 및 위치 조정
                Button(action: onManage) {
                    HStack {
                        Text("아바타 관리")
                            .font(.headline.bold())
                        if character.statPoints > 0 {
                            Text("+\(character.statPoints)")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                                .padding(6)
                                .background(Color.red)
                                .clipShape(Circle())
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .foregroundColor(character.statPoints > 0 ? .yellow_900 : Color(.label))
                    .background(character.statPoints > 0 ? Color.yellow_400 : Color(.systemGray5))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                }
                .padding(.bottom, 20) // 하단 여백 확보
            }
            .padding()
            .padding(.bottom, 80) // 탭바 가림 방지
        }
        .background(Color(.systemGroupedBackground)) // 전체 배경색 지정
    }
    
    private func statDisplay(label: String, value: Int) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.subheadline.weight(.medium))
                .foregroundColor(Color(.systemGray))
            Text("\(value)")
                .font(.title2.bold())
                .foregroundColor(Color(.label))
        }
        .frame(maxWidth: .infinity)
    }
}
