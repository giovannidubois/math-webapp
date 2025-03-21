import SwiftUI

struct NumericKeyboardView: View {
    @Binding var enteredAnswer: String
    var onSubmit: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                KeyboardButton(title: "1", action: { enteredAnswer += "1" })
                KeyboardButton(title: "2", action: { enteredAnswer += "2" })
                KeyboardButton(title: "3", action: { enteredAnswer += "3" })
            }
            
            HStack(spacing: 10) {
                KeyboardButton(title: "4", action: { enteredAnswer += "4" })
                KeyboardButton(title: "5", action: { enteredAnswer += "5" })
                KeyboardButton(title: "6", action: { enteredAnswer += "6" })
            }
            
            HStack(spacing: 10) {
                KeyboardButton(title: "7", action: { enteredAnswer += "7" })
                KeyboardButton(title: "8", action: { enteredAnswer += "8" })
                KeyboardButton(title: "9", action: { enteredAnswer += "9" })
            }
            
            HStack(spacing: 10) {
                KeyboardButton(title: "-", action: { enteredAnswer += "-" })
                KeyboardButton(title: "0", action: { enteredAnswer += "0" })
                KeyboardButton(title: "DEL", action: {
                    if !enteredAnswer.isEmpty {
                        enteredAnswer.removeLast()
                    }
                })
            }
            
            Button(action: onSubmit) {
                Text("SUBMIT")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.gray.opacity(0.8))
                    .cornerRadius(10)
            }
            .padding(.top, 5)
        }
        .padding()
        .background(Color.black.opacity(0.6))
        .cornerRadius(16)
    }
}

struct KeyboardButton: View {
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 70)
                .background(Color.gray.opacity(0.8))
                .cornerRadius(8)
        }
    }
}

struct NumericKeyboardView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.blue.opacity(0.5).edgesIgnoringSafeArea(.all)
            
            NumericKeyboardView(enteredAnswer: .constant(""), onSubmit: {})
                .padding()
                .previewLayout(.sizeThatFits)
        }
    }
}
