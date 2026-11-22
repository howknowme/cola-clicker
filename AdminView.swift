import SwiftUI

/// PIN-код для входа в админ-панель. Поменяйте на свой.
let adminPin = "1234"

// MARK: - Поле ввода числа со степпером

struct NumberRow: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    var step: Int = 1

    @State private var text = ""
    @FocusState private var focused: Bool

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            TextField("0", text: $text)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .textFieldStyle(.roundedBorder)
                .frame(width: 130)
                .focused($focused)
                .onChange(of: focused) { _, isFocused in
                    if !isFocused { commit() }
                }
            Stepper("", value: $value, in: range, step: step)
                .labelsHidden()
        }
        .onAppear { text = String(value) }
        .onChange(of: value) { _, newValue in
            if !focused { text = String(newValue) }
        }
    }

    private func commit() {
        let digits = text.filter(\.isNumber)
        var v = value
        if !digits.isEmpty {
            v = Int(digits) ?? range.upperBound
        }
        value = min(max(v, range.lowerBound), range.upperBound)
        text = String(value)
    }
}

// MARK: - Админ-панель

struct AdminView: View {
    @Binding var count: Int

    @AppStorage("perClick") private var perClick = 1
    @AppStorage("autoRate") private var autoRate = 0
    @AppStorage("multLevel") private var multLevel = 0
    @AppStorage("critLevel") private var critLevel = 0
    @AppStorage("maxOfflineHours") private var maxOfflineHours = 24
    @AppStorage("ownedSkins") private var ownedSkins = "classic"
    @AppStorage("selectedSkin") private var selectedSkin = "classic"

    @State private var unlocked = false
    @State private var pin = ""
    @State private var wrongPin = false
    @State private var confirmReset = false

    @Environment(\.dismiss) private var dismiss

    private let maxRate = 1_000_000

    var body: some View {
        NavigationStack {
            Group {
                if unlocked { panel } else { pinGate }
            }
            .navigationTitle("Админ-панель")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") { dismiss() }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Готово") {
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil, from: nil, for: nil)
                    }
                }
            }
        }
    }

    // MARK: Ввод PIN

    private var pinGate: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.fill").font(.system(size: 44))
            Text("Введите PIN-код").font(.headline)
            SecureField("PIN", text: $pin)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .textFieldStyle(.roundedBorder)
                .frame(width: 160)
            if wrongPin {
                Text("Неверный PIN").foregroundStyle(.red)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: pin) { _, value in
            if value == adminPin {
                unlocked = true
            } else if value.count >= adminPin.count {
                wrongPin = true
                pin = ""
            }
        }
    }

    // MARK: Панель

    private var panel: some View {
        Form {
            Section("Крышки") {
                NumberRow(title: "Количество", value: $count, range: 0...Game.limit, step: 1000)
                HStack {
                    quickButton("+1 тыс") { add(1_000) }
                    quickButton("+1 млн") { add(1_000_000) }
                    quickButton("+1 млрд") { add(1_000_000_000) }
                    quickButton("0") { count = 0 }
                }
            }

            Section {
                NumberRow(title: "Клики в секунду", value: $autoRate, range: 0...maxRate, step: 1)
                HStack {
                    quickButton("0") { autoRate = 0 }
                    quickButton("10") { autoRate = 10 }
                    quickButton("100") { autoRate = 100 }
                    quickButton("1000") { autoRate = 1000 }
                    quickButton("×2") { autoRate = min(max(autoRate, 1) * 2, maxRate) }
                }
                Text("Итого в секунду с множителем: \((autoRate * Game.multiplier(multLevel) / 100).formatted())")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } header: {
                Text("Автокликер")
            }

            Section("Улучшения") {
                NumberRow(title: "Сила клика", value: $perClick, range: 1...maxRate)
                NumberRow(title: "Множитель (ур.)", value: $multLevel, range: 0...Game.maxMultLevel)
                NumberRow(title: "Крит (ур.)", value: $critLevel, range: 0...Game.maxCritLevel)
                NumberRow(title: "Офлайн-лимит (часы)", value: $maxOfflineHours, range: 1...168)
            }

            Section("Дизайны крышек") {
                Button("Открыть все дизайны") {
                    ownedSkins = CapSkin.all.map(\.id).joined(separator: ",")
                }
                Button("Закрыть все (оставить классику)") {
                    ownedSkins = "classic"
                    selectedSkin = "classic"
                }
            }

            Section {
                Button("Сбросить весь прогресс", role: .destructive) {
                    confirmReset = true
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .confirmationDialog("Сбросить весь прогресс?", isPresented: $confirmReset,
                            titleVisibility: .visible) {
            Button("Сбросить", role: .destructive) { resetAll() }
            Button("Отмена", role: .cancel) {}
        }
    }

    // MARK: Помощники

    private func quickButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(title, action: action)
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)
    }

    private func add(_ amount: Int) {
        count = min(count + amount, Game.limit)
    }

    private func resetAll() {
        count = 0
        perClick = 1
        autoRate = 0
        multLevel = 0
        critLevel = 0
        maxOfflineHours = 24
        ownedSkins = "classic"
        selectedSkin = "classic"
    }
}
