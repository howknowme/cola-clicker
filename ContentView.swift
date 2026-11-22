import SwiftUI

@main
struct CocaColaClickerApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
    }
}

// MARK: - Общие правила игры (используются и в AdminView)

enum Game {
    static let limit = 1_000_000_000_000
    static let critMultiplier = 5
    static let maxMultLevel = 50
    static let maxCritLevel = 10

    /// Множитель дохода в процентах: 100 + 10% за уровень
    static func multiplier(_ level: Int) -> Int { 100 + 10 * level }
    /// Шанс крита в процентах: 5% за уровень
    static func critChance(_ level: Int) -> Int { 5 * level }
}

// MARK: - Дизайны крышек

struct CapSkin: Identifiable {
    let id: String
    let name: String
    let price: Int
    let colors: [Color]
    let rim: Color
    let text: Color
    var angular = false

    static let all: [CapSkin] = [
        CapSkin(id: "classic", name: "Классика", price: 0,
                colors: [Color(red: 0.88, green: 0.12, blue: 0.14), Color(red: 0.6, green: 0.03, blue: 0.06)],
                rim: Color(red: 0.5, green: 0.02, blue: 0.05), text: .white),
        CapSkin(id: "silver", name: "Серебро", price: 500,
                colors: [Color(red: 0.95, green: 0.95, blue: 0.97), Color(red: 0.55, green: 0.57, blue: 0.62)],
                rim: .gray, text: Color(red: 0.2, green: 0.2, blue: 0.25)),
        CapSkin(id: "gold", name: "Золото", price: 2_500,
                colors: [Color(red: 1.0, green: 0.88, blue: 0.4), Color(red: 0.75, green: 0.5, blue: 0.08)],
                rim: Color(red: 0.6, green: 0.4, blue: 0.05), text: Color(red: 0.4, green: 0.2, blue: 0.0)),
        CapSkin(id: "neon", name: "Неон", price: 10_000,
                colors: [.cyan, .purple],
                rim: .cyan, text: .white),
        CapSkin(id: "ice", name: "Лёд", price: 40_000,
                colors: [Color(red: 0.85, green: 0.97, blue: 1.0), Color(red: 0.2, green: 0.5, blue: 0.85)],
                rim: .blue, text: Color(red: 0.05, green: 0.2, blue: 0.5)),
        CapSkin(id: "dark", name: "Чёрная", price: 150_000,
                colors: [Color(white: 0.22), .black],
                rim: .red, text: .red),
        CapSkin(id: "rainbow", name: "Радуга", price: 750_000,
                colors: [.red, .orange, .yellow, .green, .blue, .purple, .red],
                rim: .white, text: .white, angular: true),
        CapSkin(id: "cosmos", name: "Космос", price: 5_000_000,
                colors: [.indigo, .purple, .black],
                rim: .purple, text: .white),
    ]

    static func find(_ id: String) -> CapSkin {
        all.first { $0.id == id } ?? all[0]
    }
}

struct CapEdge: Shape {
    var teeth = 21

    func path(in rect: CGRect) -> Path {
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let steps = teeth * 2
        var p = Path()
        for i in 0..<steps {
            let a = Double(i) / Double(steps) * 2 * Double.pi - Double.pi / 2
            let r = i % 2 == 0 ? radius : radius * 0.93
            let pt = CGPoint(x: c.x + CGFloat(cos(a)) * r, y: c.y + CGFloat(sin(a)) * r)
            if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
        }
        p.closeSubpath()
        return p
    }
}

struct CapView: View {
    let skin: CapSkin
    var size: CGFloat = 200

    private var fill: AnyShapeStyle {
        if skin.angular {
            return AnyShapeStyle(AngularGradient(colors: skin.colors, center: .center))
        }
        return AnyShapeStyle(LinearGradient(colors: skin.colors,
                                            startPoint: .topLeading, endPoint: .bottomTrailing))
    }

    var body: some View {
        ZStack {
            CapEdge().fill(fill)
            CapEdge().stroke(skin.rim.opacity(0.7), lineWidth: max(1, size * 0.012))
            Circle()
                .fill(RadialGradient(colors: [.white.opacity(0.3), .clear],
                                     center: .topLeading, startRadius: 0, endRadius: size * 0.7))
                .padding(size * 0.08)
            Circle()
                .strokeBorder(.white.opacity(0.35), lineWidth: max(1, size * 0.01))
                .padding(size * 0.08)
            if size >= 80 {
                Text("Coca-Cola")
                    .font(.system(size: size * 0.15, weight: .bold, design: .serif))
                    .italic()
                    .foregroundStyle(skin.text)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .padding(.horizontal, size * 0.2)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Всплывающие "+N"

struct Floater: Identifiable {
    let id = UUID()
    let text: String
    let crit: Bool
    let dx: CGFloat
}

struct FloaterView: View {
    let floater: Floater
    @State private var up = false

    var body: some View {
        Text(floater.text)
            .font(floater.crit ? .title.bold() : .title3.bold())
            .foregroundStyle(floater.crit ? Color.yellow : Color.white)
            .shadow(radius: 2)
            .offset(x: floater.dx, y: up ? -130 : -20)
            .opacity(up ? 0 : 1)
            .allowsHitTesting(false)
            .onAppear { withAnimation(.easeOut(duration: 0.8)) { up = true } }
    }
}

// MARK: - Главный экран

struct ContentView: View {
    @AppStorage("count") private var count = 0
    @AppStorage("perClick") private var perClick = 1
    @AppStorage("autoRate") private var autoRate = 0
    @AppStorage("multLevel") private var multLevel = 0
    @AppStorage("critLevel") private var critLevel = 0
    @AppStorage("maxOfflineHours") private var maxOfflineHours = 24
    @AppStorage("ownedSkins") private var ownedSkins = "classic"
    @AppStorage("selectedSkin") private var selectedSkin = "classic"
    @AppStorage("lastSeen") private var lastSeen: Double = 0

    @State private var pressed = false
    @State private var showAdmin = false
    @State private var showOffline = false
    @State private var offlineGain = 0
    @State private var taps = 0
    @State private var lastTap = Date.distantPast
    @State private var tab = 0
    @State private var floaters: [Floater] = []

    @Environment(\.scenePhase) private var scenePhase

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // Стоимости
    private var clickCost: Int { 25 * perClick * perClick }
    private var autoCost: Int { 50 * (autoRate + 1) }
    private var multCost: Int { 300 * (multLevel + 1) * (multLevel + 1) }
    private var critCost: Int { 1_000 * (critLevel + 1) * (critLevel + 1) }

    // Доход
    private var clickGain: Int { max(1, perClick * Game.multiplier(multLevel) / 100) }
    private var autoGain: Int { autoRate * Game.multiplier(multLevel) / 100 }

    private var ownedList: [String] { ownedSkins.split(separator: ",").map(String.init) }
    private var currentSkin: CapSkin { CapSkin.find(selectedSkin) }

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.75, green: 0.05, blue: 0.1), .black],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Text("Coca-Cola Clicker")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)

                VStack(spacing: 2) {
                    Text(count.formatted())
                        .font(.system(size: 56, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.4)
                        .lineLimit(1)
                    Text("крышек")
                        .foregroundStyle(.white.opacity(0.7))
                }
                .frame(minWidth: 200, minHeight: 90)
                .contentShape(Rectangle())
                .onTapGesture {
                    let now = Date()
                    if now.timeIntervalSince(lastTap) > 1 { taps = 0 }
                    lastTap = now
                    taps += 1
                    if taps >= 3 {
                        taps = 0
                        showAdmin = true
                    }
                }
                .onLongPressGesture(minimumDuration: 1.5) { showAdmin = true }

                Text("+\(clickGain.formatted()) за клик • +\(autoGain.formatted())/сек"
                     + (critLevel > 0 ? " • крит \(Game.critChance(critLevel))%" : ""))
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)

                ZStack {
                    Button(action: tap) {
                        CapView(skin: currentSkin, size: 190)
                            .scaleEffect(pressed ? 0.9 : 1)
                            .shadow(color: .black.opacity(0.5), radius: 12)
                    }
                    .buttonStyle(.plain)

                    ForEach(floaters) { FloaterView(floater: $0) }
                }

                Picker("", selection: $tab) {
                    Text("Улучшения").tag(0)
                    Text("Дизайн крышки").tag(1)
                }
                .pickerStyle(.segmented)

                ScrollView {
                    VStack(spacing: 10) {
                        if tab == 0 { upgradesList } else { skinsList }
                    }
                    .padding(.bottom, 4)
                }

                Text(buildStamp)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding()
        }
        .onReceive(timer) { _ in
            count = min(count + autoGain, Game.limit)
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
                .presentationDetents([.medium, .large])
        }
        .alert("С возвращением!", isPresented: $showOffline) {
            Button("Ок", role: .cancel) {}
        } message: {
            Text("Пока вас не было, автокликер набил \(offlineGain.formatted()) крышек")
        }
    }

    // MARK: Списки

    private var upgradesList: some View {
        VStack(spacing: 10) {
            upgradeRow("Сильнее клик", "+1 к силе клика (сейчас \(perClick))", cost: clickCost) {
                count -= clickCost
                perClick += 1
            }
            upgradeRow("Автокликер", "+1 крышка/сек (сейчас \(autoRate))", cost: autoCost) {
                count -= autoCost
                autoRate += 1
            }
            upgradeRow("Множитель дохода",
                       "+10% ко всему (сейчас ×\(String(format: "%.1f", Double(Game.multiplier(multLevel)) / 100)))",
                       cost: multCost, maxed: multLevel >= Game.maxMultLevel) {
                count -= multCost
                multLevel += 1
            }
            upgradeRow("Критический клик",
                       "+5% шанс ×\(Game.critMultiplier) (сейчас \(Game.critChance(critLevel))%)",
                       cost: critCost, maxed: critLevel >= Game.maxCritLevel) {
                count -= critCost
                critLevel += 1
            }
        }
    }

    private var skinsList: some View {
        VStack(spacing: 10) {
            ForEach(CapSkin.all) { skinRow($0) }
        }
    }

    // MARK: Действия

    private func tap() {
        let crit = Int.random(in: 1...100) <= Game.critChance(critLevel)
        let gain = clickGain * (crit ? Game.critMultiplier : 1)
        count = min(count + gain, Game.limit)
        UIImpactFeedbackGenerator(style: crit ? .heavy : .light).impactOccurred()
        withAnimation(.spring(duration: 0.15)) { pressed = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.spring(duration: 0.2)) { pressed = false }
        }

        let f = Floater(text: "+\(gain.formatted())", crit: crit, dx: CGFloat.random(in: -50...50))
        floaters.append(f)
        if floaters.count > 8 { floaters.removeFirst() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            floaters.removeAll { $0.id == f.id }
        }
    }

    private func applyOffline() {
        let now = Date().timeIntervalSince1970
        if lastSeen > 0 && autoGain > 0 {
            let maxSeconds = Double(max(1, maxOfflineHours)) * 3600
            let elapsed = min(max(0, now - lastSeen), maxSeconds)
            if elapsed >= 3 {
                let gain = Int(elapsed) * autoGain
                if gain > 0 {
                    count = min(count + gain, Game.limit)
                    offlineGain = gain
                    showOffline = true
                }
            }
        }
        lastSeen = now
    }

    // MARK: Строки интерфейса

    private func upgradeRow(_ title: String, _ detail: String, cost: Int,
                            maxed: Bool = false, action: @escaping () -> Void) -> some View {
        let affordable = !maxed && count >= cost
        return Button {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            action()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).bold()
                    Text(detail).font(.caption).opacity(0.6)
                }
                Spacer()
                Text(maxed ? "МАКС" : cost.formatted()).bold()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(affordable ? 0.95 : 0.35),
                        in: RoundedRectangle(cornerRadius: 14))
            .foregroundStyle(.black)
        }
        .disabled(!affordable)
    }

    private func skinRow(_ skin: CapSkin) -> some View {
        let owned = ownedList.contains(skin.id)
        let selected = selectedSkin == skin.id
        let canBuy = count >= skin.price
        return Button {
            if owned {
                selectedSkin = skin.id
            } else if canBuy {
                count -= skin.price
                ownedSkins += "," + skin.id
                selectedSkin = skin.id
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        } label: {
            HStack(spacing: 12) {
                CapView(skin: skin, size: 48)
                Text(skin.name).bold()
                Spacer()
                Text(selected ? "Выбрано ✓" : (owned ? "Выбрать" : skin.price.formatted())).bold()
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity((owned || canBuy) ? 0.95 : 0.35),
                        in: RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(selected ? Color.yellow : .clear, lineWidth: 3)
            )
            .foregroundStyle(.black)
        }
        .disabled(!owned && !canBuy)
    }
}
