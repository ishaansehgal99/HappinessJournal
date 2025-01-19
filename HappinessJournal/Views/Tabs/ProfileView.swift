//
//  ProfileView.swift
//  HappinessJournal
//
//  Created by Ishaan Sehgal on 12/31/24.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject private var user = User.sharedUser
    @State private var isImagePickerPresented = false
    @State private var inputImage: UIImage?

    var body: some View {
        VStack(spacing: 20) {
            ProfileHeaderView(user: user, inputImage: $inputImage, isImagePickerPresented: $isImagePickerPresented)
            XPProgressView(user: user)
            StatsView(user: user)
            Spacer()
        }
        .padding()
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: $inputImage)
        }
    }
}

struct ProfileHeaderView: View {
    @ObservedObject var user: User
    @Binding var inputImage: UIImage?
    @Binding var isImagePickerPresented: Bool

    var body: some View {
        VStack {
            ZStack {
                if let inputImage = inputImage {
                    Image(uiImage: inputImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(user.color, lineWidth: 3))
                        .shadow(radius: 5)
                } else {
                    Circle()
                        .fill(user.color)
                        .frame(width: 100, height: 100)
                        .overlay(Text("Add").foregroundColor(.white))
                }
            }
            .onTapGesture {
                isImagePickerPresented = true
            }
            .padding(.bottom, 10)

            TextField("Enter Name", text: $user.name)
                .font(.title2)
                .foregroundColor(user.color)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct XPProgressView: View {
    @ObservedObject var user: User

    var body: some View {
        VStack(spacing: 10) {
            Text("Level \(user.level)")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(user.color)

            ProgressView(value: Double(user.xp), total: Double(user.level * 20 - 10))
                .progressViewStyle(LinearProgressViewStyle(tint: user.color))
                .padding(.horizontal, 40)

            Text("\(user.level * 20 - 10 - user.xp) XP to Next Level")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

struct StatsView: View {
    @ObservedObject var user: User

    var body: some View {
        VStack(spacing: 10) {
            StatsRowView(title: "Current Streak", value: "\(user.streakDates.count)")
            StatsRowView(title: "Longest Streak", value: "\(user.longestStreak)")
            StatsRowView(title: "Total Completed Days", value: "\(getTotalFullDays())")
            StatsRowView(title: "Total Good Things", value: "\(getTotalGoodThings())")
        }
        .padding(.top, 20)
    }

    private func getTotalFullDays() -> Int {
        user.days.values.filter { $0.isComplete }.count
    }

    private func getTotalGoodThings() -> Int {
        user.days.values.reduce(0) { sum, day in
            sum + day.entries.filter { !$0.isEmpty && $0 != "Press here to begin typing..." }.count
        }
    }
}

struct StatsRowView: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .frame(width: 80, alignment: .center)
                .foregroundColor(.blue)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(height: 50)
        .background(Color.white.opacity(0.9))
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker

        init(parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

#Preview {
    ProfileView()
}
