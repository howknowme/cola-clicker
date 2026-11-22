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
    static let maxPerClick = 1_000_000
    static let maxAutoRate = 1_000_000

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
        CapSkin(id: "lime", name: "Лайм", price: 300,
                colors: [Color(red: 0.6, green: 0.92, blue: 0.3), Color(red: 0.15, green: 0.55, blue: 0.1)],
                rim: Color(red: 0.1, green: 0.4, blue: 0.08), text: .white),
        CapSkin(id: "lemon", name: "Лимон", price: 600,
                colors: [Color(red: 1.0, green: 0.95, blue: 0.4), Color(red: 0.9, green: 0.7, blue: 0.05)],
                rim: Color(red: 0.7, green: 0.5, blue: 0.0), text: Color(red: 0.45, green: 0.3, blue: 0.0)),
        CapSkin(id: "orange", name: "Оранж", price: 1_000,
                colors: [Color(red: 1.0, green: 0.65, blue: 0.2), Color(red: 0.85, green: 0.3, blue: 0.0)],
                rim: Color(red: 0.65, green: 0.2, blue: 0.0), text: .white),
        CapSkin(id: "silver", name: "Серебро", price: 2_000,
                colors: [Color(red: 0.95, green: 0.95, blue: 0.97), Color(red: 0.55, green: 0.57, blue: 0.62)],
                rim: .gray, text: Color(red: 0.2, green: 0.2, blue: 0.25)),
        CapSkin(id: "pink", name: "Розовая", price: 4_000,
                colors: [Color(red: 1.0, green: 0.6, blue: 0.8), Color(red: 0.85, green: 0.15, blue: 0.5)],
                rim: Color(red: 0.65, green: 0.1, blue: 0.4), text: .white),
        CapSkin(id: "blue", name: "Синяя", price: 8_000,
                colors: [Color(red: 0.35, green: 0.6, blue: 1.0), Color(red: 0.05, green: 0.2, blue: 0.7)],
                rim: Color(red: 0.03, green: 0.15, blue: 0.5), text: .white),
        CapSkin(id: "gold", name: "Золото", price: 15_000,
                colors: [Color(red: 1.0, green: 0.88, blue: 0.4), Color(red: 0.75, green: 0.5, blue: 0.08)],
                rim: Color(red: 0.6, green: 0.4, blue: 0.05), text: Color(red: 0.4, green: 0.2, blue: 0.0)),
        CapSkin(id: "purple", name: "Фиолет", price: 30_000,
                colors: [Color(red: 0.7, green: 0.45, blue: 1.0), Color(red: 0.35, green: 0.08, blue: 0.65)],
                rim: Color(red: 0.25, green: 0.05, blue: 0.5), text: .white),
        CapSkin(id: "neon", name: "Неон", price: 60_000,
                colors: [.cyan, .purple],
                rim: .cyan, text: .white),
        CapSkin(id: "ice", name: "Лёд", price: 120_000,
                colors: [Color(red: 0.85, green: 0.97, blue: 1.0), Color(red: 0.2, green: 0.5, blue: 0.85)],
                rim: .blue, text: Color(red: 0.05, green: 0.2, blue: 0.5)),
        CapSkin(id: "dark", name: "Чёрная", price: 300_000,
                colors: [Color(white: 0.22), .black],
                rim: .red, text: .red),
        CapSkin(id: "rainbow", name: "Радуга", price: 1_000_000,
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
    /// Сколько улучшений покупать за раз: 1, 10, 100, 1000 или 0 = максимум
    @AppStorage("buyAmount") private var buyAmount = 1

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
                    Text("Магазин крышек").tag(1)
                }
                .pickerStyle(.segmented)

                ScrollView {
                    if tab == 0 { upgradesList } else { shopGrid }
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

    // MARK: Улучшения (с массовой покупкой)

    /// Считает, сколько уровней купится и сколько это стоит.
    /// `cost(level)` — цена перехода с уровня `level` на следующий.
    private func plan(level: Int, maxLevel: Int, cost: (Int) -> Int) -> (n: Int, total: Int) {
        let room = max(0, maxLevel - level)
        if room == 0 { return (0, 0) }

        if buyAmount == 0 {
            // Максимум, что можно купить на текущие крышки
            var n = 0
            var total = 0
            while n < room {
                let c = cost(level + n)
                if total + c > count { break }
                total += c
                n += 1
            }
            if n == 0 { return (1, cost(level)) } // не хватает даже на один — показываем цену одного
            return (n, total)
        }

        let n = min(buyAmount, room)
        var total = 0
        for i in 0..<n { total += cost(level + i) }
        return (n, total)
    }

    private var upgradesList: some View {
        let clickPlan = plan(level: perClick, maxLevel: Game.maxPerClick) { 25 * $0 * $0 }
        let autoPlan = plan(level: autoRate, maxLevel: Game.maxAutoRate) { 50 * ($0 + 1) }
        let multPlan = plan(level: multLevel, maxLevel: Game.maxMultLevel) { 300 * ($0 + 1) * ($0 + 1) }
        let critPlan = plan(level: critLevel, maxLevel: Game.maxCritLevel) { 1_000 * ($0 + 1) * ($0 + 1) }

        return VStack(spacing: 10) {
            Picker("", selection: $buyAmount) {
                Text("×1").tag(1)
                Text("×10").tag(10)
                Text("×100").tag(100)
                Text("×1000").tag(1000)
                Text("МАКС").tag(0)
            }
            .pickerStyle(.segmented)

            upgradeRow("Сильнее клик", "сейчас \(perClick.formatted())", plan: clickPlan) { n in
                perClick += n
            }
            upgradeRow("Автокликер", "сейчас \(autoRate.formatted())/сек", plan: autoPlan) { n in
                autoRate += n
            }
            upgradeRow("Множитель дохода",
                       "сейчас ×\(String(format: "%.1f", Double(Game.multiplier(multLevel)) / 100))",
                       plan: multPlan) { n in
                multLevel += n
            }
            upgradeRow("Критический клик",
                       "сейчас \(Game.critChance(critLevel))% ×\(Game.critMultiplier)",
                       plan: critPlan) { n in
                critLevel += n
            }
        }
        .padding(.bottom, 4)
    }

    private func upgradeRow(_ title: String, _ detail: String,
                            plan: (n: Int, total: Int),
                            action: @escaping (Int) -> Void) -> some View {
        let maxed = plan.n == 0
        let affordable = !maxed && count >= plan.total
        return Button {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            count -= plan.total
            action(plan.n)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).bold()
                    Text(maxed ? detail : "\(detail) • купить ×\(plan.n.formatted())")
                        .font(.caption)
                        .opacity(0.6)
                }
                Spacer()
                Text(maxed ? "МАКС" : plan.total.formatted()).bold()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(affordable ? 0.95 : 0.35),
                        in: RoundedRectangle(cornerRadius: 14))
            .foregroundStyle(.black)
        }
        .disabled(!affordable)
    }

    // MARK: Магазин крышек

    private var shopGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)],
                  spacing: 10) {
            ForEach(CapSkin.all) { skinCell($0) }
        }
        .padding(.bottom, 4)
    }

    private func skinCell(_ skin: CapSkin) -> some View {
        let owned = ownedList.contains(skin.id)
        let selected = selectedSkin == skin.id
        let canBuy = count >= skin.price
        let status = selected ? "Выбрано ✓" : (owned ? "Выбрать" : skin.price.formatted())
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
            VStack(spacing: 6) {
                CapView(skin: skin, size: 90)
                Text(skin.name).bold()
                Text(status)
                    .font(.subheadline.bold())
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.08), in: Capsule())
            }
            .padding(.vertical, 12)
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
}
