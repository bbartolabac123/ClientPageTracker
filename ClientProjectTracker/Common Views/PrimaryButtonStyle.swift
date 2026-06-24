//
//  PrimaryButtonStyle.swift
//  ClientProjectTracker
//
//  Created by Benjamin Bartolabac on 6/24/26.
//
import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    
    @Environment(\.isEnabled) private var isEnabled
    var cornerRadius: CGFloat = 16
    var borderWidth: CGFloat = 2.5
    var shadowOffset: CGFloat = 5
    
    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed
        configuration.label
            .foregroundStyle(Color.primaryText)
            .font(.title3)
            .fontWeight(.semibold)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(isEnabled ? Color.accentColor : Color.disabled)
            )
            .scaleEffect(pressed ? 0.9 : 1.0)
            .animation(.snappy(duration: 0.12), value: pressed)
    }
}


#Preview {
    VStack {
    
        Button {
            
        } label: {
            HStack {
                Text("Click me")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .buttonStyle(PrimaryButtonStyle())
        .padding(.horizontal, 16)
        .disabled(false)
    }
}
