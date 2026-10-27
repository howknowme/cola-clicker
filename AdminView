import SwiftUI

struct AdminView: View {
    @Binding var count: Int
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @FocusState private var focused: Bool

    private let limit = 1_000_000_000_000

    private func add(_ n: Int) {
        let safe = max(0, min(n, limit))
        count = min(count + safe, limit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Сейчас крышек") {
                    Text("\(count)").font(.title2.bold())
                }
                Section("Добавить своё число") {
                    TextField("Например, 5000", text: $text)
                        .keyboardType(.numberPad)
                        .focused($focused)
                    Button("Добавить") {
                        if let n = Int(text) { add(n) }
                        text = ""
                        focused = false
                    }
                    .disabled(Int(text) == nil)
                }
                Section("Быстро") {
                    HStack {
                        quick("1K", 1_000)
                        quick("100K", 100_000)
                        quick("1M", 1_000_000)
                        quick("1B", 1_000_000_000)
                    }
                }
            }
            .navigationTitle("Админ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") { dismiss() }
                }
                ToolbarItem(placement: .keyboard) {
                    Button("Готово") { focused = false }
                }
            }
        }
    }

    private func quick(_ title: String, _ value: Int) -> some View {
        Button(title) { add(value) }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)
    }
}
