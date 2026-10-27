import SwiftUI

@main
struct CocaColaClickerApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
    }
}

struct ContentView: View {
    @AppStorage("count") private var count = 0
    @AppStorage("perClick") private var perClick = 1
    @AppStorage("autoRate") private var autoRate = 0
    @AppStorage("lastSeen") private var lastSeen: Double = 0

    @State private var pressed = false
    @State private var showAdmin = false
    @State private var showOffline = false
    @State private var offlineGain = 0

    @Environment(\.scenePhase) private var scenePhase

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let maxOffline: Double = 24 * 60 * 60
    private let limit = 1_000_000_000_000

    private var clickCost: Int { 25 * perClick * perClick }
    private var autoCost: Int { 50 * (autoRate + 1) }

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.75, green: 0.05, blue: 0.1), .black],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Coca-Cola Clicker v3")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)

                VStack(spacing: 2) {
                    Text("\(count)")
                        .font(.system(size: 64, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                        .minimumScaleFactor(0.4)
                        .lineLimit(1)
                    Text("крышек")
                        .foregroundStyle(.white.opacity(0.7))
                }
                .contentShape(Rectangle())
                .onTapGesture(count: 3) { showAdmin = true }

                Text("+\(perClick) за клик • +\(autoRate)/сек")
                    .foregroundStyle(.white.opacity(0.8))

                Button {
                    count = min(count + perClick, limit)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.spring(duration: 0.15)) { pressed = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                        withAnimation(.spring(duration: 0.2)) { pressed = false }
                    }
                } label: {
                    Image(systemName: "waterbottle.fill")
                        .font(.system(size: 130))
                        .foregroundStyle(.white)
                        .padding(40)
                        .background(Circle().fill(Color.red.gradient))
                        .scaleEffect(pressed ? 0.88 : 1)
                        .shadow(radius: 12)
                }
                .buttonStyle(.plain)

                VStack(spacing: 12) {
                    upgrade("Сильнее клик (+1)", cost: clickCost) {
                        count -= clickCost
                        perClick += 1
                    }
                    upgrade("Автокликер (+1/сек)", cost: autoCost) {
                        count -= autoCost
                        autoRate += 1
                    }
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .onReceive(timer) { _ in
            count = min(count + autoRate, limit)
            lastSeen = Date().timeIntervalSince1970
        }
        .onAppear { applyOffline() }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active:
                applyOffline()
            case .inactive, .background:
                lastSeen = Date().timeIntervalSince1970
            @unknown default:
                break
            }
        }
        .sheet(isPresented: $showAdmin) {
            AdminView(count: $count)
                .presentationDetents([.medium])
        }
        .alert("С возвращением!", isPresented: $showOffline) {
            Button("Ок", role: .cancel) {}
        } message: {
            Text("Пока вас не было, автокликер набил +\(offlineGain) крышек")
        }
    }

    private func applyOffline() {
        let now = Date().timeIntervalSince1970
        if lastSeen > 0 && autoRate > 0 {
            let elapsed = min(max(0, now - lastSeen), maxOffline)
            if elapsed >= 3 {
                let gain = Int(elapsed) * autoRate
                if gain > 0 {
                    count = min(count + gain, limit)
                    offlineGain = gain
                    showOffline = true
                }
            }
        }
        lastSeen = now
    }

    private func upgrade(_ title: String, cost: Int, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                Text("\(cost)").bold()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(count >= cost ? 0.95 : 0.35),
                        in: RoundedRectangle(cornerRadius: 14))
            .foregroundStyle(.black)
        }
        .disabled(count < cost)
    }
}

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
                        quick("+1K", 1_000)
                        quick("+100K", 100_000)
                        quick("+1M", 1_000_000)
                        quick("+1B", 1_000_000_000)
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
