// MARK: - HeaderView.swift (수정됨)

import SwiftUI

struct HeaderView: View {
    let user: User
    let onShare: () -> Void
    let onOpenMyPage: () -> Void

    var body: some View {
        HStack {
            // 로고 영역
            HStack(spacing: 4) {
                Text("🌍")
                    .font(.title)
                Text("픽업팰")
                    .font(.title2.bold())
                    .foregroundColor(Color(.label))
                Text("v1.0")
                    .font(.caption.weight(.medium))
                    .foregroundColor(Color(.systemGray))
            }
            
            Spacer()
            
            // 우측 버튼 영역
            HStack(spacing: 12) {
                // [수정] 공유 버튼: 프레임을 명시하여 1:1 비율 강제
                Button(action: onShare) {
                    Image(systemName: "square.and.arrow.up")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20) // 아이콘 크기
                        .foregroundColor(Color(.systemGray))
                }
                .frame(width: 40, height: 40) // 버튼 전체 크기를 1:1(40x40)로 고정
                .background(Color(.secondarySystemBackground)) // 둥근 배경 추가 (선택 사항)
                .clipShape(Circle()) // 원형으로 자르기
                
                // 마이페이지 버튼
                Button(action: onOpenMyPage) {
                    HStack(spacing: 8) {
                        // 모바일에서는 공간 절약을 위해 이름 숨김 처리 가능 (여기선 유지)
                        Text("\(user.name) (Lv. \(user.level))")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(Color(.label))
                            .lineLimit(1)
                            .fixedSize() // 텍스트 줄바꿈 방지
                        
                        AsyncImage(url: URL(string: "https://i.pravatar.cc/150?u=\(user.id)")) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Color(.systemGray5)
                        }
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.emerald_500, lineWidth: 2))
                    }
                    .padding(.leading, 8)
                    .padding(.trailing, 4)
                    .padding(.vertical, 4)
                    .background(Color(.systemBackground)) // 버튼 배경
                }
            }
        }
        .padding(.horizontal)
        .frame(height: 56)
        .background(Color(.systemBackground).opacity(0.8).ignoresSafeArea(edges: .top))
        .background(.ultraThinMaterial) // 블러 효과 추가
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
