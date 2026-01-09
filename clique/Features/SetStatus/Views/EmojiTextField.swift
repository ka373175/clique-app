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
    @Binding var isFocused: Bool
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
        
        // Store reference for focus control
        context.coordinator.textField = textField
        
        return textField
    }
    
    func updateUIView(_ uiView: EmojiUITextField, context: Context) {
        uiView.text = text
        
        // Keep coordinator bindings in sync with view updates
        context.coordinator.update(text: $text, isFocused: $isFocused)
        
        // Handle focus state changes from SwiftUI
        DispatchQueue.main.async {
            if self.isFocused && !uiView.isFirstResponder {
                uiView.becomeFirstResponder()
            } else if !self.isFocused && uiView.isFirstResponder {
                uiView.resignFirstResponder()
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, isFocused: $isFocused)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var text: Binding<String>
        var isFocused: Binding<Bool>
        weak var textField: UITextField?
        
        init(text: Binding<String>, isFocused: Binding<Bool>) {
            self.text = text
            self.isFocused = isFocused
        }
        
        func update(text: Binding<String>, isFocused: Binding<Bool>) {
            self.text = text
            self.isFocused = isFocused
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            // Allow deletion
            if string.isEmpty {
                text.wrappedValue = ""
                return true
            }
            
            // Check if the input is an emoji
            if string.isSingleEmoji {
                text.wrappedValue = string
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
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            isFocused.wrappedValue = true
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            isFocused.wrappedValue = false
        }
    }
}

// MARK: - Custom UITextField that defaults to Emoji Keyboard
class EmojiUITextField: UITextField {
    // Cache the emoji input mode to avoid repeated lookups
    private static var cachedEmojiInputMode: UITextInputMode? = {
        UITextInputMode.activeInputModes.first { $0.primaryLanguage == "emoji" }
    }()
    
    override var textInputMode: UITextInputMode? {
        Self.cachedEmojiInputMode ?? super.textInputMode
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
        @State private var isFocused = false
        
        var body: some View {
            VStack {
                EmojiTextField(text: $emoji, isFocused: $isFocused)
                    .frame(width: 100, height: 100)
                    .background(Circle().fill(Color(.systemGray6)))
                
                Text("Selected: \(emoji.isEmpty ? "none" : emoji)")
            }
        }
    }
    
    return PreviewWrapper()
}
