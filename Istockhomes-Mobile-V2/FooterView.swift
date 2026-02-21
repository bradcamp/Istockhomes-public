// FooterView.swift
import SwiftUI

struct FooterView: View {
    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 4) {
                // ✅ Istockhomes Logo (universal)
                AsyncImage(url: URL(string: "https://istockhomes.com/App/images/Istockhomes_logo-2020-Clear.jpg")) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                            .opacity(0.8)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                            .opacity(0.3)
                    @unknown default:
                        EmptyView()
                    }
                }

                // ✅ Verified Text
                Text("Istockhomes Verified")
                    .font(.footnote)
                    .foregroundColor(.secondary)

                // ✅ Powered by OpenAI
                Text("Powered by OpenAI")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.bottom, 12)
    }
}

#Preview {
    FooterView()
}

