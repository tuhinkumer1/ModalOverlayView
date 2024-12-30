//
//  FeedbackView.swift
//  AI Video
//
//  Created by Tuhin Kumer on 2/12/24.
//

import SwiftUI

protocol FeedbackDelegate: AnyObject {
    func didSubmitFeedback(option: FeedbackOption, comment: String?)
}

enum FeedbackOption: String, CaseIterable, Identifiable {
    case wrongGeneration = "feedback option 1"
    case bodyBroken = "feedback option 2"
    case faceChanged = "feedback option 3"
    case other = "Other"
    
    var id: String { self.rawValue }
}

struct FeedbackView: View {
    @State private var selectedOption: FeedbackOption? = nil
    @State private var showTextView: Bool = false
    @State private var otherComment: String = ""
    @State private var isKeyboardVisible: Bool = false
    @State private var backgroundOpacity: Double = 0.0
    @State private var offsetY: CGFloat = UIScreen.main.bounds.height
    
    weak var delegate: FeedbackDelegate?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Background with animating opacity
                Color.black.opacity(backgroundOpacity)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        dismissView()
                    }
                
                // Modal content with animating offset
                VStack(spacing: 20) {
                    // Small bar at the top middle
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 40, height: 4)
                        .padding(.top, 10)
                    
                    Text("Give your feedback")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    ForEach(FeedbackOption.allCases) { option in
                        Button(action: {
                            withAnimation {
                                selectedOption = option
                                showTextView = (option == .other)
                            }
                        }) {
                            HStack {
                                Circle()
                                    .stroke(selectedOption == option ? Color.purple : Color.gray, lineWidth: 2)
                                    .frame(width: 20, height: 20)
                                    .overlay(
                                        Circle()
                                            .fill(selectedOption == option ? Color.purple : Color.clear)
                                            .frame(width: 10, height: 10)
                                    )
                                Text(option.rawValue)
                                    .foregroundColor(.white)
                                    .padding(.leading, 10)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    if showTextView {
                        VStack {
                            ZStack(alignment: .bottomTrailing) {
                                TextEditor(text: $otherComment)
                                    .scrollContentBackground(.hidden)
                                    .frame(height: 100)
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 40)
                                    .foregroundColor(.white)
                                    .background(Color(hex: "21232C"))
                                    .cornerRadius(12)
                                    .onChange(of: otherComment) { _ in
                                        if otherComment.count > 500 {
                                            otherComment = String(otherComment.prefix(500))
                                        }
                                    }
                                
                                Text("\(otherComment.count)/500")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 10)
                                    .padding(.bottom, 10)
                            }
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeInOut, value: showTextView)
                    }
                    
                    Button(action: {
                        sendFeedback()
                    }) {
                        Text("Send Feedback")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, isKeyboardVisible ? geometry.safeAreaInsets.bottom : 30)
                .padding(.horizontal)
                .padding(.top, 20)
                .background(Color.black)
                .offset(y: offsetY)
                .animation(.easeInOut(duration: 0.3), value: offsetY)
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                    withAnimation {
                        isKeyboardVisible = true
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                    withAnimation {
                        isKeyboardVisible = false
                    }
                }
                .onTapGesture {
                    hideKeyboard()
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 0.3)) {
                    backgroundOpacity = 0.6 // Adjust opacity as desired
                    offsetY = 0
                }
            }
        }
    }
    
    private func sendFeedback() {
        guard let option = selectedOption else { return }
        delegate?.didSubmitFeedback(option: option, comment: showTextView ? otherComment : nil)
        dismissView()
    }
    
    private func dismissView() {
        withAnimation(.easeInOut(duration: 0.3)) {
            hideKeyboard()
            backgroundOpacity = 0.0
            offsetY = UIScreen.main.bounds.height
        }
        
        // Dismiss the hosting controller after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let hostingController = UIApplication.shared.windows.first?.rootViewController?.presentedViewController as? UIHostingController<FeedbackView> {
                hostingController.dismiss(animated: true, completion: nil)
            }
        }
    }

}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.currentIndex = hex.startIndex
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}
#endif

struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackView()
    }
}

