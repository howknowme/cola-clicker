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

// MARK: - Биржа

struct CoinInfo: Identifiable {
    let id: String
    let name: String
    let symbol: String
    let icon: String
    let color: Color
    let base: Double   // "справедливая" цена, к которой курс тянется
    let vol: Double    // волатильность за секунду

    static let all: [CoinInfo] = [
        CoinInfo(id: "cola", name: "КолаКоин", symbol: "COLA", icon: "drop.fill",
                 color: .red, base: 100, vol: 0.01),
        CoinInfo(id: "cap", name: "КрышкаКоин", symbol: "CAP", icon: "bitcoinsign.circle.fill",
                 color: .orange, base: 500, vol: 0.02),
        CoinInfo(id: "fizz", name: "ФиззКоин", symbol: "FIZZ", icon: "bolt.fill",
                 color: .teal, base: 2_500, vol: 0.035),
        CoinInfo(id: "moon", name: "МунКоин", symbol: "MOON", icon: "moon.stars.fill",
                 color: .purple, base: 20_000, vol: 0.05),
    ]
}

struct CoinState: Codable {
    var price: Double
    var trend: Double
    var history: [Double]

    static func initial(_ coin: CoinInfo) -> CoinState {
        CoinState(price: coin.base, trend: 0, history: [coin.base])
    }

    /// Один шаг рынка: случайный шум + затяжной тренд + слабая тяга к базовой цене
    mutating func step(_ coin: CoinInfo) {
        let noise = (Double.random(in: -1...1) + Double.random(in: -1...1)) / 2
        trend = trend * 0.95 + Double.random(in: -1...1) * coin.vol * 0.15
        let reversion = 0.01 * log(coin.base / price)
        let r = trend + noise * coin.vol + reversion
        price = min(max(price * exp(r), coin.base * 0.1), coin.base * 10)
        history.append(price)
        if history.count > 60 { history.removeFirst(history.count - 60) }
    }
}

struct Holding: Codable {
    var units: Int
    var spent: Int
}

struct Sparkline: View {
    let values: [Double]
    let color: Color

    var body: some View {
        GeometryReader { geo in
            let lo = values.min() ?? 0
            let hi = values.max() ?? 1
            let range = max(hi - lo, 0.0001)
            Path { p in
                for (i, v) in values.enumerated() {
                    let x = values.count > 1 ? geo.size.width * CGFloat(i) / CGFloat(values.count - 1) : 0
                    let y = hi - lo < 0.0001
                        ? geo.size.height / 2
                        : geo.size.height * (1 - CGFloat((v - lo) / range))
                    if i == 0 { p.move(to: CGPoint(x: x, y: y)) }
                    else { p.addLine(to: CGPoint(x: x, y: y)) }
                }
            }
            .stroke(color, style: StrokeStyle(lineWidth: 2, lineJoin: .round))
        }
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
    @State private var market: [String: CoinState] = [:]
    @AppStorage("market") private var marketJSON = ""
    @AppStorage("holdings") private var holdingsJSON = ""

    private let upColor = Color(red: 0.1, green: 0.65, blue: 0.25)
    private let downColor = Color(red: 0.85, green: 0.1, blue: 0.1)

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
                    Text("Крышки").tag(1)
                    Text("Биржа").tag(2)
                }
                .pickerStyle(.segmented)

                ScrollView {
                    if tab == 0 { upgradesList }
                    else if tab == 1 { shopGrid }
                    else { marketList }
                }

                Text(buildStamp)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding()
        }
        .onReceive(timer) { _ in
            stepMarket()
            count = min(count + autoGain, Game.limit)
            lastSeen = Date().timeIntervalSince1970
        }
        .onAppear {
            loadMarket()
            applyOffline()
        }
        .onChange(of: marketJSON) { _, new in
            if new.isEmpty { market = [:] }   // сброс из админки
        }
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

    // MARK: Биржа

    private var holdings: [String: Holding] {
        get {
            (try? JSONDecoder().decode([String: Holding].self, from: Data(holdingsJSON.utf8))) ?? [:]
        }
        nonmutating set {
            if let data = try? JSONEncoder().encode(newValue),
               let str = String(data: data, encoding: .utf8) {
                holdingsJSON = str
            }
        }
    }

    private func loadMarket() {
        if let data = marketJSON.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([String: CoinState].self, from: data) {
            market = decoded
        }
    }

    private func stepMarket(times: Int = 1) {
        var m = market
        for _ in 0..<max(1, times) {
            for coin in CoinInfo.all {
                var s = m[coin.id] ?? CoinState.initial(coin)
                s.step(coin)
                m[coin.id] = s
            }
        }
        market = m
        if let data = try? JSONEncoder().encode(m),
           let str = String(data: data, encoding: .utf8) {
            marketJSON = str
        }
    }

    private var marketList: some View {
        VStack(spacing: 10) {
            Picker("", selection: $buyAmount) {
                Text("×1").tag(1)
                Text("×10").tag(10)
                Text("×100").tag(100)
                Text("×1000").tag(1000)
                Text("МАКС").tag(0)
            }
            .pickerStyle(.segmented)

            Text("Курс меняется каждую секунду. Покупайте дёшево, продавайте дорого!")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)

            ForEach(CoinInfo.all) { coinCard($0) }
        }
        .padding(.bottom, 4)
    }

    private func coinCard(_ coin: CoinInfo) -> some View {
        let st = market[coin.id] ?? CoinState.initial(coin)
        let price = max(1, Int(st.price.rounded()))
        let h = holdings[coin.id] ?? Holding(units: 0, spent: 0)
        let first = st.history.first ?? st.price
        let change = first > 0 ? (st.price / first - 1) * 100 : 0
        let trendColor: Color = st.price >= first ? upColor : downColor
        let value = h.units * price
        let pl = value - h.spent
        let afford = count / price
        let buyN = buyAmount == 0 ? afford : min(buyAmount, afford)
        let sellN = buyAmount == 0 ? h.units : min(buyAmount, h.units)
        let buyShow = buyN > 0 ? buyN : max(1, buyAmount)

        return VStack(spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: coin.icon)
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(coin.color))
                VStack(alignment: .leading, spacing: 0) {
                    Text(coin.name).bold()
                    Text(coin.symbol).font(.caption).opacity(0.6)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 0) {
                    Text(price.formatted()).font(.title3.bold())
                    Text("\(change >= 0 ? "▲" : "▼") \(String(format: "%.1f", abs(change)))%")
                        .font(.caption.bold())
                        .foregroundStyle(trendColor)
                }
            }

            Sparkline(values: st.history, color: trendColor)
                .frame(height: 44)

            HStack {
                Text(h.units > 0
                     ? "У вас: \(h.units.formatted()) • \(value.formatted())"
                     : "У вас пока нет монет")
                    .font(.caption)
                Spacer()
                if h.units > 0 {
                    Text("\(pl >= 0 ? "+" : "−")\(abs(pl).formatted())")
                        .font(.caption.bold())
                        .foregroundStyle(pl >= 0 ? upColor : downColor)
                }
            }

            HStack(spacing: 8) {
                tradeButton("Купить",
                            "×\(buyShow.formatted()) • \((buyShow * price).formatted())",
                            color: upColor, enabled: buyN > 0) {
                    buy(coin, price: price, n: buyN)
                }
                tradeButton("Продать",
                            sellN > 0 ? "×\(sellN.formatted()) • +\((sellN * price).formatted())" : "—",
                            color: downColor, enabled: sellN > 0) {
                    sell(coin, price: price, n: sellN)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.95), in: RoundedRectangle(cornerRadius: 14))
        .foregroundStyle(.black)
    }

    private func tradeButton(_ title: String, _ sub: String, color: Color, enabled: Bool,
                             action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Text(title).bold()
                Text(sub).font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(color.opacity(enabled ? 1 : 0.35), in: RoundedRectangle(cornerRadius: 10))
            .foregroundStyle(.white)
        }
        .disabled(!enabled)
    }

    private func buy(_ coin: CoinInfo, price: Int, n: Int) {
        guard n > 0, count >= n * price else { return }
        count -= n * price
        var all = holdings
        var h = all[coin.id] ?? Holding(units: 0, spent: 0)
        h.units += n
        h.spent += n * price
        all[coin.id] = h
        holdings = all
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    private func sell(_ coin: CoinInfo, price: Int, n: Int) {
        var all = holdings
        guard var h = all[coin.id], n > 0, n <= h.units else { return }
        count = min(count + n * price, Game.limit)
        let removed = Int(Double(h.spent) * Double(n) / Double(h.units))
        h.units -= n
        h.spent = max(0, h.spent - removed)
        all[coin.id] = h.units == 0 ? nil : h
        holdings = all
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
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
        let away = lastSeen > 0 ? max(0, now - lastSeen) : 0
        if away >= 3 { stepMarket(times: min(Int(away), 1800)) }
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
