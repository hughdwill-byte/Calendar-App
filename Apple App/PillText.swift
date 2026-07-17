import SwiftUI

struct PillText: View {
    var text: String
    var background: Color = Color.gray.opacity(0.2)
    var textColor: Color = .darkgrey
    
    var action: () -> Void = { print("This is default action") }
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(text)
                .bold(true)
                .foregroundStyle(textColor)
                .padding(.vertical, 8)
                .padding(.horizontal, 25)
                .background {
                    background
                        .cornerRadius(20)
                    
                }
               
        }
        

    }
}

#Preview {
    PillText(text: "This Week", background: .gray.opacity(0.2))
}
