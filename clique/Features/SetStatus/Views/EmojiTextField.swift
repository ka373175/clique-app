//
//  EmojiTextField.swift
//  clique
//
//  Custom UIViewRepresentable that forces emoji keyboard input
//  and limits to a single emoji character.
//

import SwiftUI
import UIKit

struct EmojiTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String = "+"
    
    func makeUIView(context: Context) -> EmojiUITextField {
        let textField = EmojiUITextField()
        textField.textAlignment = .center
        textField.font = .systemFont(ofSize: 48)
        textField.delegate = context.coordinator
        textField.tintColor = .clear // Hide cursor
        textField.backgroundColor = .clear
        textField.returnKeyType = .done
        
        // Set placeholder
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .font: UIFont.systemFont(ofSize: 48),
                .foregroundColor: UIColor.systemGray3
            ]
        )
        
        return textField
    }
    
    func updateUIView(_ uiView: EmojiUITextField, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: EmojiTextField
        
        init(_ parent: EmojiTextField) {
            self.parent = parent
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            // Allow deletion
            if string.isEmpty {
                parent.text = ""
                return true
            }
            
            // Check if the input is an emoji
            if string.isSingleEmoji {
                parent.text = string
                textField.text = string
                // Dismiss keyboard after selection
                textField.resignFirstResponder()
                return false
            }
            
            // Reject non-emoji input
            return false
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    }
}

// MARK: - Custom UITextField that defaults to Emoji Keyboard
class EmojiUITextField: UITextField {
    override var textInputMode: UITextInputMode? {
        // Find and return the emoji input mode
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" {
                return mode
            }
        }
        return super.textInputMode
    }
}

// MARK: - String Extension for Emoji Detection
extension String {
    var isSingleEmoji: Bool {
        guard count == 1 else { return false }
        guard let firstScalar = unicodeScalars.first else { return false }
        return firstScalar.properties.isEmoji && firstScalar.value > 0x238C
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var emoji = ""
        
        var body: some View {
            VStack {
                EmojiTextField(text: $emoji)
                    .frame(width: 100, height: 100)
                    .background(Circle().fill(Color(.systemGray6)))
                
                Text("Selected: \(emoji.isEmpty ? "none" : emoji)")
            }
        }
    }
    
    return PreviewWrapper()
}
