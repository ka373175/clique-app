//
//  IconColorPickerSheet.swift
//  clique
//
//  Created by Clique on 1/9/26.
//

import SwiftUI

struct IconColorPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedColor: IconColor
    let onColorSelected: (IconColor) -> Void
    
    private let columns = [
        GridItem(.adaptive(minimum: 60, maximum: 80), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Preview
                Circle()
                    .fill(selectedColor.color.gradient)
                    .frame(width: 80, height: 80)
                    .overlay {
                        Text("AB")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    }
                    .padding(.top, 24)
                
                Text("Choose a Color")
                    .font(.headline)
                
                // Color grid
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(IconColor.allCases) { color in
                        ColorButton(
                            color: color,
                            isSelected: selectedColor == color
                        ) {
                            selectedColor = color
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .navigationTitle("Icon Color")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        onColorSelected(selectedColor)
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct ColorButton: View {
    let color: IconColor
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color.color.gradient)
                .frame(width: 50, height: 50)
                .overlay {
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                    }
                }
                .overlay {
                    Circle()
                        .strokeBorder(isSelected ? Color.primary : Color.clear, lineWidth: 3)
                }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    IconColorPickerSheet(selectedColor: .constant(.blue)) { _ in }
}
