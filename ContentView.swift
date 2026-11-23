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
    static let maxBizLevel = 100
    static let maxWarehouse = 30

    /// Множитель дохода в процентах: 100 + 10% за уровень
    static func multiplier(_ level: Int) -> Int { 100 + 10 * level }
    /// Шанс крита в процентах: 5% за уровень
    static func critChance(_ level: Int) -> Int { 5 * level }
    /// Вместимость склада (бутылок всего) по уровню
    static func capacity(_ level: Int) -> Int { 500 * (level + 1) * (level + 1) }

    // MARK: Уровень игрока (по всему заработанному за игру)

    static let maxLevel = 100
    /// Сколько нужно заработать всего для уровня (индекс = уровень − 1)
    static let thresholds: [Int] = (1...Game.maxLevel).map { l in
        l == 1 ? 0 : Int(100 * pow(1.3, Double(l - 2)))
    }

    static func level(for earned: Int) -> Int {
        var lv = 1
        while lv < maxLevel && earned >= thresholds[lv] { lv += 1 }
        return lv
    }

    /// Прогресс до следующего уровня, 0...1
    static func levelProgress(_ earned: Int) -> Double {
        let lv = level(for: earned)
        if lv >= maxLevel { return 1 }
        let lo = thresholds[lv - 1]
        let hi = thresholds[lv]
        return min(1, max(0, Double(earned - lo) / Double(max(1, hi - lo))))
    }

    /// Награда в крышках за достижение уровня
    static func levelReward(_ l: Int) -> Int {
        max(100, thresholds[min(max(l, 1), maxLevel) - 1] / 10)
    }

    static func levelTitle(_ l: Int) -> String {
        switch l {
        case ..<5: return "Новичок"
        case 5..<10: return "Продавец"
        case 10..<20: return "Торговец"
        case 20..<30: return "Бизнесмен"
        case 30..<45: return "Магнат"
        case 45..<60: return "Король колы"
        case 60..<80: return "Легенда"
        default: return "Бог газировки"
        }
    }
}

// MARK: - JSON-помощники для хранения в @AppStorage

func decodeJSON<T: Decodable>(_ type: T.Type, _ s: String) -> T? {
    try? JSONDecoder().decode(type, from: Data(s.utf8))
}

func encodeJSON<T: Encodable>(_ value: T) -> String? {
    guard let d = try? JSONEncoder().encode(value) else { return nil }
    return String(data: d, encoding: .utf8)
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
        CapSkin(id: "mint", name: "Мята", price: 450,
                colors: [Color(red: 0.7, green: 1.0, blue: 0.85), Color(red: 0.2, green: 0.7, blue: 0.55)],
                rim: Color(red: 0.1, green: 0.5, blue: 0.4), text: Color(red: 0.0, green: 0.3, blue: 0.25)),
        CapSkin(id: "lemon", name: "Лимон", price: 600,
                colors: [Color(red: 1.0, green: 0.95, blue: 0.4), Color(red: 0.9, green: 0.7, blue: 0.05)],
                rim: Color(red: 0.7, green: 0.5, blue: 0.0), text: Color(red: 0.45, green: 0.3, blue: 0.0)),
        CapSkin(id: "orange", name: "Оранж", price: 1_000,
                colors: [Color(red: 1.0, green: 0.65, blue: 0.2), Color(red: 0.85, green: 0.3, blue: 0.0)],
                rim: Color(red: 0.65, green: 0.2, blue: 0.0), text: .white),
        CapSkin(id: "silver", name: "Серебро", price: 2_000,
                colors: [Color(red: 0.95, green: 0.95, blue: 0.97), Color(red: 0.55, green: 0.57, blue: 0.62)],
                rim: .gray, text: Color(red: 0.2, green: 0.2, blue: 0.25)),
        CapSkin(id: "bronze", name: "Бронза", price: 3_000,
                colors: [Color(red: 0.85, green: 0.55, blue: 0.3), Color(red: 0.5, green: 0.28, blue: 0.1)],
                rim: Color(red: 0.4, green: 0.2, blue: 0.05), text: .white),
        CapSkin(id: "pink", name: "Розовая", price: 4_000,
                colors: [Color(red: 1.0, green: 0.6, blue: 0.8), Color(red: 0.85, green: 0.15, blue: 0.5)],
                rim: Color(red: 0.65, green: 0.1, blue: 0.4), text: .white),
        CapSkin(id: "coral", name: "Коралл", price: 6_000,
                colors: [Color(red: 1.0, green: 0.55, blue: 0.5), Color(red: 0.9, green: 0.3, blue: 0.3)],
                rim: Color(red: 0.7, green: 0.2, blue: 0.2), text: .white),
        CapSkin(id: "blue", name: "Синяя", price: 8_000,
                colors: [Color(red: 0.35, green: 0.6, blue: 1.0), Color(red: 0.05, green: 0.2, blue: 0.7)],
                rim: Color(red: 0.03, green: 0.15, blue: 0.5), text: .white),
        CapSkin(id: "sky", name: "Небо", price: 12_000,
                colors: [Color(red: 0.6, green: 0.85, blue: 1.0), Color(red: 0.3, green: 0.6, blue: 0.95)],
                rim: Color(red: 0.2, green: 0.45, blue: 0.8), text: .white),
        CapSkin(id: "gold", name: "Золото", price: 15_000,
                colors: [Color(red: 1.0, green: 0.88, blue: 0.4), Color(red: 0.75, green: 0.5, blue: 0.08)],
                rim: Color(red: 0.6, green: 0.4, blue: 0.05), text: Color(red: 0.4, green: 0.2, blue: 0.0)),
        CapSkin(id: "candy", name: "Карамель", price: 18_000,
                colors: [Color(red: 1.0, green: 0.75, blue: 0.85), Color(red: 0.6, green: 0.85, blue: 1.0)],
                rim: .pink, text: Color(red: 0.6, green: 0.1, blue: 0.4)),
        CapSkin(id: "emerald", name: "Изумруд", price: 22_000,
                colors: [Color(red: 0.3, green: 0.9, blue: 0.6), Color(red: 0.0, green: 0.4, blue: 0.25)],
                rim: Color(red: 0.0, green: 0.3, blue: 0.2), text: .white),
        CapSkin(id: "purple", name: "Фиолет", price: 30_000,
                colors: [Color(red: 0.7, green: 0.45, blue: 1.0), Color(red: 0.35, green: 0.08, blue: 0.65)],
                rim: Color(red: 0.25, green: 0.05, blue: 0.5), text: .white),
        CapSkin(id: "ruby", name: "Рубин", price: 45_000,
                colors: [Color(red: 1.0, green: 0.3, blue: 0.4), Color(red: 0.5, green: 0.0, blue: 0.15)],
                rim: Color(red: 0.4, green: 0.0, blue: 0.1), text: .white),
        CapSkin(id: "neon", name: "Неон", price: 60_000,
                colors: [.cyan, .purple],
                rim: .cyan, text: .white),
        CapSkin(id: "sunset", name: "Закат", price: 80_000,
                colors: [.orange, .pink, .purple],
                rim: .purple, text: .white),
        CapSkin(id: "ice", name: "Лёд", price: 120_000,
                colors: [Color(red: 0.85, green: 0.97, blue: 1.0), Color(red: 0.2, green: 0.5, blue: 0.85)],
                rim: .blue, text: Color(red: 0.05, green: 0.2, blue: 0.5)),
        CapSkin(id: "lava", name: "Лава", price: 200_000,
                colors: [.yellow, .orange, .red, .black],
                rim: .orange, text: .white),
        CapSkin(id: "dark", name: "Чёрная", price: 300_000,
                colors: [Color(white: 0.22), .black],
                rim: .red, text: .red),
        CapSkin(id: "aurora", name: "Сияние", price: 450_000,
                colors: [.green, .cyan, .purple, .green],
                rim: .cyan, text: .white, angular: true),
        CapSkin(id: "rainbow", name: "Радуга", price: 1_000_000,
                colors: [.red, .orange, .yellow, .green, .blue, .purple, .red],
                rim: .white, text: .white, angular: true),
        CapSkin(id: "platinum", name: "Платина", price: 2_000_000,
                colors: [Color(white: 0.97), Color(red: 0.7, green: 0.75, blue: 0.8), Color(white: 0.85)],
                rim: .gray, text: Color(red: 0.25, green: 0.3, blue: 0.35)),
        CapSkin(id: "cosmos", name: "Космос", price: 5_000_000,
                colors: [.indigo, .purple, .black],
                rim: .purple, text: .white),
        CapSkin(id: "diamond", name: "Алмаз", price: 10_000_000,
                colors: [.white, .cyan, .blue, .white, .cyan, .white],
                rim: .cyan, text: Color(red: 0.1, green: 0.3, blue: 0.5), angular: true),
        CapSkin(id: "blackhole", name: "Чёрная дыра", price: 50_000_000,
                colors: [.black, .purple, .black, .indigo, .black],
                rim: .white, text: .white, angular: true),
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

// MARK: - Фоны и шрифты

extension Color {
    static func rgb(_ r: Double, _ g: Double, _ b: Double) -> Color {
        Color(red: r, green: g, blue: b)
    }
}

struct SplitMix: RandomNumberGenerator {
    var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}

struct StarField: View {
    var body: some View {
        Canvas { ctx, size in
            var g = SplitMix(seed: 7)
            for _ in 0..<70 {
                let x = CGFloat.random(in: 0...size.width, using: &g)
                let y = CGFloat.random(in: 0...size.height, using: &g)
                let r = CGFloat.random(in: 0.5...1.8, using: &g)
                let a = Double.random(in: 0.3...0.9, using: &g)
                ctx.fill(Path(ellipseIn: CGRect(x: x, y: y, width: r * 2, height: r * 2)),
                         with: .color(.white.opacity(a)))
            }
        }
        .allowsHitTesting(false)
    }
}

struct AppBackground: Identifiable {
    let id: String
    let name: String
    let price: Int
    let minLevel: Int
    let colors: [Color]
    var angular = false
    var stars = false

    static let all: [AppBackground] = [
        AppBackground(id: "classic", name: "Классика", price: 0, minLevel: 1,
                      colors: [.rgb(0.75, 0.05, 0.1), .black]),
        AppBackground(id: "ocean", name: "Океан", price: 5_000, minLevel: 3,
                      colors: [.rgb(0.05, 0.4, 0.7), .rgb(0.0, 0.08, 0.2)]),
        AppBackground(id: "forest", name: "Лес", price: 20_000, minLevel: 5,
                      colors: [.rgb(0.1, 0.5, 0.2), .rgb(0.0, 0.1, 0.05)]),
        AppBackground(id: "sunset", name: "Закат", price: 80_000, minLevel: 8,
                      colors: [.rgb(0.9, 0.4, 0.2), .rgb(0.6, 0.15, 0.45), .rgb(0.1, 0.05, 0.2)]),
        AppBackground(id: "night", name: "Ночь", price: 250_000, minLevel: 10,
                      colors: [.rgb(0.15, 0.15, 0.5), .black]),
        AppBackground(id: "candy", name: "Конфета", price: 600_000, minLevel: 14,
                      colors: [.rgb(0.85, 0.3, 0.6), .rgb(0.25, 0.05, 0.3)]),
        AppBackground(id: "desert", name: "Пустыня", price: 1_200_000, minLevel: 16,
                      colors: [.rgb(0.8, 0.55, 0.2), .rgb(0.25, 0.1, 0.0)]),
        AppBackground(id: "gold", name: "Золотой", price: 2_000_000, minLevel: 18,
                      colors: [.rgb(0.7, 0.5, 0.05), .rgb(0.12, 0.07, 0.0)]),
        AppBackground(id: "glacier", name: "Ледник", price: 6_000_000, minLevel: 22,
                      colors: [.rgb(0.3, 0.6, 0.85), .rgb(0.02, 0.1, 0.25)]),
        AppBackground(id: "volcano", name: "Вулкан", price: 20_000_000, minLevel: 26,
                      colors: [.rgb(0.9, 0.3, 0.0), .rgb(0.35, 0.0, 0.0), .black]),
        AppBackground(id: "neoncity", name: "Неон-сити", price: 60_000_000, minLevel: 30,
                      colors: [.rgb(0.5, 0.0, 0.7), .rgb(0.0, 0.5, 0.7), .black]),
        AppBackground(id: "aurora", name: "Северное сияние", price: 200_000_000, minLevel: 36,
                      colors: [.rgb(0.0, 0.5, 0.3), .rgb(0.1, 0.2, 0.6), .rgb(0.4, 0.1, 0.6), .rgb(0.0, 0.5, 0.3)],
                      angular: true),
        AppBackground(id: "galaxy", name: "Галактика", price: 800_000_000, minLevel: 42,
                      colors: [.rgb(0.1, 0.0, 0.25), .black], stars: true),
        AppBackground(id: "rainbow", name: "Радуга", price: 3_000_000_000, minLevel: 50,
                      colors: [.rgb(0.7, 0.1, 0.1), .rgb(0.7, 0.4, 0.0), .rgb(0.6, 0.6, 0.0),
                               .rgb(0.1, 0.5, 0.1), .rgb(0.1, 0.2, 0.7), .rgb(0.4, 0.1, 0.6),
                               .rgb(0.7, 0.1, 0.1)],
                      angular: true),
        AppBackground(id: "void", name: "Бездна", price: 20_000_000_000, minLevel: 60,
                      colors: [.rgb(0.2, 0.0, 0.3), .black, .black], stars: true),
    ]

    static func find(_ id: String) -> AppBackground {
        all.first { $0.id == id } ?? all[0]
    }
}

struct BackgroundArt: View {
    let bg: AppBackground

    var body: some View {
        ZStack {
            if bg.angular {
                AngularGradient(colors: bg.colors, center: .center)
            } else {
                LinearGradient(colors: bg.colors, startPoint: .top, endPoint: .bottom)
            }
            if bg.stars { StarField() }
        }
    }
}

struct GameFont: Identifiable {
    let id: String
    let name: String
    let price: Int
    let minLevel: Int
    var family: String? = nil
    var design: Font.Design? = nil

    func font(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        if let family {
            return Font.custom(family, size: size).weight(weight)
        }
        return Font.system(size: size, weight: weight, design: design ?? .default)
    }

    static let all: [GameFont] = [
        GameFont(id: "system", name: "Стандартный", price: 0, minLevel: 1),
        GameFont(id: "rounded", name: "Округлый", price: 10_000, minLevel: 2, design: .rounded),
        GameFont(id: "serif", name: "С засечками", price: 30_000, minLevel: 4, design: .serif),
        GameFont(id: "mono", name: "Моно", price: 100_000, minLevel: 6, design: .monospaced),
        GameFont(id: "typewriter", name: "Пишущая машинка", price: 400_000, minLevel: 9,
                 family: "American Typewriter"),
        GameFont(id: "georgia", name: "Georgia", price: 1_200_000, minLevel: 13, family: "Georgia"),
        GameFont(id: "avenir", name: "Avenir Next", price: 3_000_000, minLevel: 17, family: "Avenir Next"),
        GameFont(id: "marker", name: "Маркер", price: 8_000_000, minLevel: 21, family: "Marker Felt"),
        GameFont(id: "noteworthy", name: "Заметки", price: 25_000_000, minLevel: 25, family: "Noteworthy"),
        GameFont(id: "chalk", name: "Мел", price: 70_000_000, minLevel: 29, family: "Chalkduster"),
        GameFont(id: "futura", name: "Futura", price: 200_000_000, minLevel: 34, family: "Futura"),
        GameFont(id: "copper", name: "Copperplate", price: 600_000_000, minLevel: 40, family: "Copperplate"),
        GameFont(id: "snell", name: "Каллиграфия", price: 2_000_000_000, minLevel: 46,
                 family: "Snell Roundhand"),
        GameFont(id: "papyrus", name: "Папирус", price: 6_000_000_000, minLevel: 55, family: "Papyrus"),
        GameFont(id: "zapfino", name: "Zapfino", price: 25_000_000_000, minLevel: 65, family: "Zapfino"),
    ]

    static func find(_ id: String) -> GameFont {
        all.first { $0.id == id } ?? all[0]
    }
}

struct GameFontKey: EnvironmentKey {
    static let defaultValue = GameFont.all[0]
}

extension EnvironmentValues {
    var gameFont: GameFont {
        get { self[GameFontKey.self] }
        set { self[GameFontKey.self] = newValue }
    }
}

struct AppFont: ViewModifier {
    @Environment(\.gameFont) private var gameFont
    let size: CGFloat
    let weight: Font.Weight

    func body(content: Content) -> some View {
        content.font(gameFont.font(size: size, weight: weight))
    }
}

extension View {
    /// Шрифт, выбранный игроком в магазине
    func appFont(_ size: CGFloat, _ weight: Font.Weight = .regular) -> some View {
        modifier(AppFont(size: size, weight: weight))
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
            .appFont(floater.crit ? 28 : 20, .bold)
            .foregroundStyle(floater.crit ? Color.yellow : Color.white)
            .shadow(radius: 2)
            .offset(x: floater.dx, y: up ? -130 : -20)
            .opacity(up ? 0 : 1)
            .allowsHitTesting(false)
            .onAppear { withAnimation(.easeOut(duration: 0.8)) { up = true } }
    }
}

// MARK: - Котировки (монеты и цены поставщиков)

struct Quote {
    let id: String
    let base: Double   // "справедливая" цена, к которой курс тянется
    let vol: Double    // волатильность за секунду
    let lo: Double     // нижняя граница (доля от base)
    let hi: Double     // верхняя граница (доля от base)
}

struct CoinState: Codable {
    var price: Double
    var trend: Double
    var history: [Double]

    static func initial(_ q: Quote) -> CoinState {
        CoinState(price: q.base, trend: 0, history: [q.base])
    }

    /// Один шаг рынка: случайный шум + затяжной тренд + слабая тяга к базовой цене
    mutating func step(_ q: Quote) {
        let noise = (Double.random(in: -1...1) + Double.random(in: -1...1)) / 2
        trend = trend * 0.95 + Double.random(in: -1...1) * q.vol * 0.15
        let reversion = 0.01 * log(q.base / price)
        let r = trend + noise * q.vol + reversion
        price = min(max(price * exp(r), q.base * q.lo), q.base * q.hi)
        history.append(price)
        if history.count > 60 { history.removeFirst(history.count - 60) }
    }
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

// MARK: - Биржа: монеты

struct CoinInfo: Identifiable {
    let id: String
    let name: String
    let symbol: String
    let icon: String
    let color: Color
    let base: Double
    let vol: Double

    var quote: Quote { Quote(id: id, base: base, vol: vol, lo: 0.1, hi: 10) }

    static let all: [CoinInfo] = [
        CoinInfo(id: "gas", name: "ГазКоин", symbol: "GAS", icon: "wind",
                 color: .mint, base: 50, vol: 0.008),
        CoinInfo(id: "cola", name: "КолаКоин", symbol: "COLA", icon: "drop.fill",
                 color: .red, base: 100, vol: 0.01),
        CoinInfo(id: "ice", name: "ЛёдКоин", symbol: "ICE", icon: "snowflake",
                 color: .cyan, base: 250, vol: 0.015),
        CoinInfo(id: "cap", name: "КрышкаКоин", symbol: "CAP", icon: "bitcoinsign.circle.fill",
                 color: .orange, base: 500, vol: 0.02),
        CoinInfo(id: "bottle", name: "БутылкаКоин", symbol: "BTL", icon: "waterbottle.fill",
                 color: .green, base: 1_200, vol: 0.025),
        CoinInfo(id: "fizz", name: "ФиззКоин", symbol: "FIZZ", icon: "bolt.fill",
                 color: .teal, base: 2_500, vol: 0.035),
        CoinInfo(id: "lava", name: "ЛаваКоин", symbol: "LAVA", icon: "flame.fill",
                 color: .red, base: 8_000, vol: 0.04),
        CoinInfo(id: "moon", name: "МунКоин", symbol: "MOON", icon: "moon.stars.fill",
                 color: .purple, base: 20_000, vol: 0.05),
        CoinInfo(id: "star", name: "ЗвёздоКоин", symbol: "STAR", icon: "star.fill",
                 color: .yellow, base: 50_000, vol: 0.045),
        CoinInfo(id: "king", name: "КоролевКоин", symbol: "KING", icon: "crown.fill",
                 color: .indigo, base: 150_000, vol: 0.035),
        CoinInfo(id: "gem", name: "АлмазКоин", symbol: "GEM", icon: "diamond.fill",
                 color: .pink, base: 1_000_000, vol: 0.05),
        CoinInfo(id: "rocket", name: "РокетКоин", symbol: "ROCK", icon: "sparkles",
                 color: .gray, base: 5_000_000, vol: 0.06),
    ]
}

struct Holding: Codable {
    var units: Int
    var spent: Int
}

// MARK: - Бизнес: сорта колы, поставщики, бизнесы

struct Grade: Identifiable {
    let id: String
    let index: Int
    let name: String
    let percent: Int   // во сколько раз (в %) выше платят за этот сорт
    let color: Color

    static let all: [Grade] = [
        Grade(id: "std", index: 0, name: "Обычная", percent: 100, color: .gray),
        Grade(id: "prem", index: 1, name: "Премиум", percent: 160, color: .blue),
        Grade(id: "lux", index: 2, name: "Люкс", percent: 250, color: .orange),
    ]

    static func find(_ id: String) -> Grade {
        all.first { $0.id == id } ?? all[0]
    }
}

struct SupplierInfo: Identifiable {
    let id: String
    let name: String
    let icon: String
    let note: String
    let grade: String
    let base: Double   // цена одной бутылки
    let pack: Int      // бутылок в одной партии
    let vol: Double
    let risk: Double   // доля брака (теряется при доставке)

    var quoteKey: String { "sup_" + id }
    var quote: Quote { Quote(id: quoteKey, base: base, vol: vol, lo: 0.5, hi: 2.0) }

    static let all: [SupplierInfo] = [
        SupplierInfo(id: "rynok", name: "Рынок у дома", icon: "house.fill",
                     note: "Дорого, зато по одной бутылке",
                     grade: "std", base: 6, pack: 1, vol: 0.008, risk: 0),
        SupplierInfo(id: "opt", name: "ОптБаза", icon: "shippingbox.fill",
                     note: "Ящиками по 24 — дешевле",
                     grade: "std", base: 4, pack: 24, vol: 0.012, risk: 0),
        SupplierInfo(id: "mega", name: "МегаОпт", icon: "truck.box.fill",
                     note: "Фурой по 240, ~5% брака",
                     grade: "std", base: 3, pack: 240, vol: 0.02, risk: 0.05),
        SupplierInfo(id: "factory", name: "Завод «Газировка»", icon: "building.2.fill",
                     note: "Премиум-розлив, по 12",
                     grade: "prem", base: 11, pack: 12, vol: 0.015, risk: 0),
        SupplierInfo(id: "black", name: "Чёрный рынок", icon: "theatermasks.fill",
                     note: "Премиум дёшево, но ~25% брака",
                     grade: "prem", base: 7, pack: 10, vol: 0.03, risk: 0.25),
        SupplierInfo(id: "import", name: "Лакшери Импорт", icon: "airplane",
                     note: "Люкс из-за границы, по 12",
                     grade: "lux", base: 20, pack: 12, vol: 0.02, risk: 0),
    ]
}

struct Business: Identifiable {
    let id: String
    let name: String
    let icon: String
    let color: Color
    let cost: Int       // базовая цена уровня (растёт как cost × (ур+1)²)
    let demand: Int     // бутылок в секунду на 1 уровень
    let price: Int      // крышек за обычную бутылку
    let minGrade: Int   // минимальный сорт колы

    static let all: [Business] = [
        Business(id: "kiosk", name: "Ларёк у остановки", icon: "storefront.fill", color: .orange,
                 cost: 300, demand: 1, price: 10, minGrade: 0),
        Business(id: "cafe", name: "Кафе «Уют»", icon: "cup.and.saucer.fill", color: .brown,
                 cost: 2_500, demand: 3, price: 13, minGrade: 0),
        Business(id: "market", name: "Супермаркет", icon: "cart.fill", color: .green,
                 cost: 20_000, demand: 12, price: 14, minGrade: 0),
        Business(id: "restaurant", name: "Ресторан", icon: "fork.knife", color: .red,
                 cost: 120_000, demand: 10, price: 35, minGrade: 1),
        Business(id: "cinema", name: "Кинотеатр", icon: "film.fill", color: .purple,
                 cost: 700_000, demand: 45, price: 22, minGrade: 0),
        Business(id: "hotel", name: "Отель", icon: "bed.double.fill", color: .blue,
                 cost: 4_000_000, demand: 40, price: 60, minGrade: 1),
        Business(id: "stadium", name: "Стадион", icon: "sportscourt.fill", color: .teal,
                 cost: 30_000_000, demand: 300, price: 30, minGrade: 0),
        Business(id: "spaceport", name: "Космопорт", icon: "globe", color: .indigo,
                 cost: 250_000_000, demand: 200, price: 140, minGrade: 2),
    ]

    /// Порядок продажи: сначала бизнесы, которым нужен лучший сорт и которые платят больше
    static let sellOrder: [Business] = all.sorted {
        if $0.minGrade != $1.minGrade { return $0.minGrade > $1.minGrade }
        return $0.price > $1.price
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
    /// Сколько штук покупать за раз: 1, 10, 100, 1000 или 0 = максимум
    @AppStorage("buyAmount") private var buyAmount = 1
    @AppStorage("market") private var marketJSON = ""
    @AppStorage("holdings") private var holdingsJSON = ""
    @AppStorage("stock") private var stockJSON = ""
    @AppStorage("bizLevels") private var bizLevelsJSON = ""
    @AppStorage("warehouse") private var warehouse = 0
    @AppStorage("ownedBackgrounds") private var ownedBackgrounds = "classic"
    @AppStorage("selectedBackground") private var selectedBackground = "classic"
    @AppStorage("ownedFonts") private var ownedFonts = "system"
    @AppStorage("selectedFont") private var selectedFont = "system"
    @AppStorage("totalEarned") private var totalEarned = 0
    @AppStorage("lastLevel") private var lastLevel = 1

    @State private var pressed = false
    @State private var showAdmin = false
    @State private var showOffline = false
    @State private var offlineGain = 0
    @State private var taps = 0
    @State private var lastTap = Date.distantPast
    @State private var tab = 0
    @State private var bizTab = 0
    @State private var floaters: [Floater] = []
    @State private var market: [String: CoinState] = [:]
    @State private var supplyNote = ""
    @State private var shopTab = 0
    @State private var levelUpText = ""

    @Environment(\.scenePhase) private var scenePhase

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private let upColor = Color(red: 0.1, green: 0.65, blue: 0.25)
    private let downColor = Color(red: 0.85, green: 0.1, blue: 0.1)

    // Доход
    private var clickGain: Int { max(1, perClick * Game.multiplier(multLevel) / 100) }
    private var autoGain: Int { autoRate * Game.multiplier(multLevel) / 100 }

    private var ownedList: [String] { ownedSkins.split(separator: ",").map(String.init) }
    private var currentSkin: CapSkin { CapSkin.find(selectedSkin) }
    private var currentBackground: AppBackground { AppBackground.find(selectedBackground) }
    private var currentFont: GameFont { GameFont.find(selectedFont) }
    private var playerLevel: Int { Game.level(for: totalEarned) }
    private var ownedBgList: [String] { ownedBackgrounds.split(separator: ",").map(String.init) }
    private var ownedFontList: [String] { ownedFonts.split(separator: ",").map(String.init) }

    var body: some View {
        ZStack {
            BackgroundArt(bg: currentBackground)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Text("Coca-Cola Clicker")
                    .appFont(28, .bold)
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)

                levelBar

                VStack(spacing: 2) {
                    Text(count.formatted())
                        .appFont(56, .heavy)
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
                    .appFont(15)
                    .foregroundStyle(.white.opacity(0.8))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)

                ZStack {
                    Button(action: tap) {
                        CapView(skin: currentSkin, size: 170)
                            .scaleEffect(pressed ? 0.9 : 1)
                            .shadow(color: .black.opacity(0.5), radius: 12)
                    }
                    .buttonStyle(.plain)

                    ForEach(floaters) { FloaterView(floater: $0) }
                }

                tabBar

                ScrollView {
                    if tab == 0 { upgradesList }
                    else if tab == 1 { shopScreen }
                    else if tab == 2 { marketList }
                    else { businessScreen }
                }

                Text(buildStamp)
                    .appFont(11)
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding()
        }
        .environment(\.gameFont, currentFont)
        .overlay(alignment: .top) { levelBanner }
        .onReceive(timer) { _ in
            stepMarket()
            let bizIncome = runBusinesses(seconds: 1)
            count = min(count + autoGain + bizIncome, Game.limit)
            addEarned(autoGain + bizIncome)
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
            Text("Пока вас не было, вы заработали \(offlineGain.formatted()) крышек")
        }
    }

    // MARK: Панель вкладок

    private var tabBar: some View {
        HStack(spacing: 6) {
            ForEach(Array(["Прокачка", "Магазин", "Биржа", "Бизнес"].enumerated()), id: \.offset) { i, name in
                Button { tab = i } label: {
                    Text(name)
                        .appFont(15, .bold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(tab == i ? Color.white : Color.white.opacity(0.18), in: Capsule())
                        .foregroundStyle(tab == i ? Color.black : Color.white)
                }
            }
        }
    }

    private var amountPicker: some View {
        Picker("", selection: $buyAmount) {
            Text("×1").tag(1)
            Text("×10").tag(10)
            Text("×100").tag(100)
            Text("×1000").tag(1000)
            Text("МАКС").tag(0)
        }
        .pickerStyle(.segmented)
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
            amountPicker

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
                        .appFont(12)
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
                    .appFont(15, .bold)
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

    // MARK: Уровень

    private var levelBar: some View {
        let lv = playerLevel
        let frac = Game.levelProgress(totalEarned)
        let right = lv >= Game.maxLevel ? "МАКС" : "\(Int(frac * 100))%"
        return VStack(spacing: 3) {
            HStack {
                Text("Ур. \(lv) • \(Game.levelTitle(lv))").appFont(13, .bold)
                Spacer()
                Text(right).appFont(12, .bold).opacity(0.7)
            }
            ProgressView(value: frac).tint(.yellow)
        }
        .foregroundStyle(.white)
    }

    @ViewBuilder
    private var levelBanner: some View {
        if !levelUpText.isEmpty {
            Text(levelUpText)
                .appFont(15, .bold)
                .foregroundStyle(.black)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.yellow, in: Capsule())
                .shadow(radius: 6)
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

    private func addEarned(_ n: Int) {
        guard n > 0 else { return }
        totalEarned += n
        let lv = Game.level(for: totalEarned)
        if lv > lastLevel {
            var reward = 0
            for l in (lastLevel + 1)...lv { reward += Game.levelReward(l) }
            lastLevel = lv
            count = min(count + reward, Game.limit)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            let text = "Уровень \(lv)! Награда: +\(reward.formatted())"
            withAnimation { levelUpText = text }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                if levelUpText == text {
                    withAnimation { levelUpText = "" }
                }
            }
        }
    }

    // MARK: Магазин: фоны и шрифты

    private var shopScreen: some View {
        VStack(spacing: 10) {
            Picker("", selection: $shopTab) {
                Text("Крышки").tag(0)
                Text("Фоны").tag(1)
                Text("Шрифты").tag(2)
            }
            .pickerStyle(.segmented)

            if shopTab == 0 { shopGrid }
            else if shopTab == 1 { backgroundGrid }
            else { fontList }
        }
        .padding(.bottom, 4)
    }

    private var backgroundGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)],
                  spacing: 10) {
            ForEach(AppBackground.all) { backgroundCell($0) }
        }
    }

    private func backgroundCell(_ bg: AppBackground) -> some View {
        let owned = ownedBgList.contains(bg.id)
        let selected = selectedBackground == bg.id
        let locked = !owned && playerLevel < bg.minLevel
        let canBuy = !locked && count >= bg.price
        let status = selected ? "Выбрано ✓" : (owned ? "Выбрать" : (locked ? "🔒 Ур. \(bg.minLevel)" : bg.price.formatted()))
        return Button {
            if owned {
                selectedBackground = bg.id
            } else if canBuy {
                count -= bg.price
                ownedBackgrounds += "," + bg.id
                selectedBackground = bg.id
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        } label: {
            VStack(spacing: 6) {
                BackgroundArt(bg: bg)
                    .frame(height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Text(bg.name).bold().lineLimit(1).minimumScaleFactor(0.7)
                if locked {
                    Text(bg.price.formatted()).appFont(11).opacity(0.6)
                }
                Text(status)
                    .appFont(15, .bold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.08), in: Capsule())
            }
            .padding(10)
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

    private var fontList: some View {
        VStack(spacing: 10) {
            Text("Если в шрифте нет русских букв, iOS заменит их стандартными")
                .appFont(11)
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
            ForEach(GameFont.all) { fontRow($0) }
        }
    }

    private func fontRow(_ gf: GameFont) -> some View {
        let owned = ownedFontList.contains(gf.id)
        let selected = selectedFont == gf.id
        let locked = !owned && playerLevel < gf.minLevel
        let canBuy = !locked && count >= gf.price
        let status = selected ? "Выбрано ✓" : (owned ? "Выбрать" : (locked ? "🔒 Ур. \(gf.minLevel)" : gf.price.formatted()))
        return Button {
            if owned {
                selectedFont = gf.id
            } else if canBuy {
                count -= gf.price
                ownedFonts += "," + gf.id
                selectedFont = gf.id
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        } label: {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(gf.name).font(.system(size: 13, weight: .bold)).opacity(0.6)
                    Text("Крышки 12345 Coca")
                        .font(gf.font(size: 20, weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    if locked {
                        Text(gf.price.formatted()).font(.system(size: 11)).opacity(0.6)
                    }
                }
                Spacer()
                Text(status)
                    .font(.system(size: 15, weight: .bold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.08), in: Capsule())
            }
            .padding(12)
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
        get { decodeJSON([String: Holding].self, holdingsJSON) ?? [:] }
        nonmutating set { if let s = encodeJSON(newValue) { holdingsJSON = s } }
    }

    private func loadMarket() {
        if let decoded = decodeJSON([String: CoinState].self, marketJSON) {
            market = decoded
        }
    }

    private func stepMarket(times: Int = 1) {
        let quotes = CoinInfo.all.map { $0.quote } + SupplierInfo.all.map { $0.quote }
        var m = market
        for _ in 0..<max(1, times) {
            for q in quotes {
                var s = m[q.id] ?? CoinState.initial(q)
                s.step(q)
                m[q.id] = s
            }
        }
        market = m
        if let s = encodeJSON(m) { marketJSON = s }
    }

    private var marketList: some View {
        VStack(spacing: 10) {
            amountPicker

            Text("Курс меняется каждую секунду. Покупайте дёшево, продавайте дорого!")
                .appFont(12)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)

            ForEach(CoinInfo.all) { coinCard($0) }
        }
        .padding(.bottom, 4)
    }

    private func coinCard(_ coin: CoinInfo) -> some View {
        let st = market[coin.id] ?? CoinState.initial(coin.quote)
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
        let arrow = change >= 0 ? "▲" : "▼"
        let changeText = "\(arrow) \(String(format: "%.1f", abs(change)))%"
        let holdText = h.units > 0
            ? "У вас: \(h.units.formatted()) • \(value.formatted())"
            : "У вас пока нет монет"
        let plText = (pl >= 0 ? "+" : "−") + abs(pl).formatted()
        let buySub = "×\(buyShow.formatted()) • \((buyShow * price).formatted())"
        let sellSub = sellN > 0 ? "×\(sellN.formatted()) • +\((sellN * price).formatted())" : "—"

        return VStack(spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: coin.icon)
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(coin.color))
                VStack(alignment: .leading, spacing: 0) {
                    Text(coin.name).bold()
                    Text(coin.symbol).appFont(12).opacity(0.6)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 0) {
                    Text(price.formatted()).appFont(20, .bold)
                    Text(changeText)
                        .appFont(12, .bold)
                        .foregroundStyle(trendColor)
                }
            }

            Sparkline(values: st.history, color: trendColor)
                .frame(height: 44)

            HStack {
                Text(holdText).appFont(12)
                Spacer()
                if h.units > 0 {
                    Text(plText)
                        .appFont(12, .bold)
                        .foregroundStyle(pl >= 0 ? upColor : downColor)
                }
            }

            HStack(spacing: 8) {
                tradeButton("Купить", buySub, color: upColor, enabled: buyN > 0) {
                    buy(coin, price: price, n: buyN)
                }
                tradeButton("Продать", sellSub, color: downColor, enabled: sellN > 0) {
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
                Text(sub).appFont(11)
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

    // MARK: Бизнес

    private var stock: [String: Int] {
        get { decodeJSON([String: Int].self, stockJSON) ?? [:] }
        nonmutating set { if let s = encodeJSON(newValue) { stockJSON = s } }
    }

    private var bizLevels: [String: Int] {
        get { decodeJSON([String: Int].self, bizLevelsJSON) ?? [:] }
        nonmutating set { if let s = encodeJSON(newValue) { bizLevelsJSON = s } }
    }

    private func totalStock(_ st: [String: Int]) -> Int {
        Grade.all.reduce(0) { $0 + (st[$1.id] ?? 0) }
    }

    /// Бизнесы покупают колу со склада. Возвращает заработанные крышки.
    private func runBusinesses(seconds: Int) -> Int {
        guard seconds > 0 else { return 0 }
        let levels = bizLevels
        if levels.isEmpty { return 0 }
        var st = stock
        var income = 0
        for biz in Business.sellOrder {
            let level = levels[biz.id] ?? 0
            if level <= 0 { continue }
            var want = biz.demand * level * seconds
            for g in Grade.all.reversed() where g.index >= biz.minGrade {
                if want <= 0 { break }
                let have = st[g.id] ?? 0
                let take = min(want, have)
                if take > 0 {
                    st[g.id] = have - take
                    income += take * biz.price * g.percent / 100
                    want -= take
                }
            }
        }
        if income > 0 { stock = st }
        return income * Game.multiplier(multLevel) / 100
    }

    private var businessScreen: some View {
        VStack(spacing: 10) {
            stockHeader

            Picker("", selection: $bizTab) {
                Text("Бизнесы").tag(0)
                Text("Поставщики").tag(1)
            }
            .pickerStyle(.segmented)

            amountPicker

            if bizTab == 0 {
                ForEach(Business.all) { businessCard($0) }
            } else {
                if !supplyNote.isEmpty {
                    Text(supplyNote)
                        .appFont(12, .bold)
                        .foregroundStyle(.yellow)
                        .multilineTextAlignment(.center)
                }
                ForEach(SupplierInfo.all) { supplierCard($0) }
            }
        }
        .padding(.bottom, 4)
    }

    private var stockHeader: some View {
        let st = stock
        let total = totalStock(st)
        let cap = Game.capacity(warehouse)
        let levels = bizLevels
        let demand = Business.all.reduce(0) { $0 + $1.demand * (levels[$1.id] ?? 0) }
        let whPlan = plan(level: warehouse, maxLevel: Game.maxWarehouse) { 2_000 * ($0 + 1) * ($0 + 1) }
        let fill = cap > 0 ? min(1, Double(total) / Double(cap)) : 0

        return VStack(spacing: 8) {
            HStack {
                Image(systemName: "shippingbox.fill")
                Text("Склад").bold()
                Spacer()
                Text("\(total.formatted()) / \(cap.formatted())").bold()
            }
            ProgressView(value: fill)
                .tint(fill >= 1 ? downColor : upColor)
            HStack {
                ForEach(Grade.all) { g in
                    VStack(spacing: 0) {
                        Text((st[g.id] ?? 0).formatted()).appFont(15, .bold)
                        Text(g.name).appFont(11).opacity(0.6)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            Text("Бизнесы потребляют \(demand.formatted()) бут./сек")
                .appFont(12)
                .opacity(0.7)

            warehouseButton(whPlan)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.95), in: RoundedRectangle(cornerRadius: 14))
        .foregroundStyle(.black)
    }

    private func warehouseButton(_ p: (n: Int, total: Int)) -> some View {
        let maxed = p.n == 0
        let affordable = !maxed && count >= p.total
        let newCap = Game.capacity(warehouse + p.n)
        let label = maxed ? "Склад: максимум" : "Расширить склад до \(newCap.formatted())"
        return Button {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            count -= p.total
            warehouse += p.n
        } label: {
            HStack {
                Text(label).appFont(15, .bold)
                Spacer()
                Text(maxed ? "МАКС" : p.total.formatted()).appFont(15, .bold)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(Color.black.opacity(affordable ? 0.85 : 0.25), in: RoundedRectangle(cornerRadius: 10))
            .foregroundStyle(.white)
        }
        .disabled(!affordable)
    }

    private func businessCard(_ biz: Business) -> some View {
        let level = bizLevels[biz.id] ?? 0
        let p = plan(level: level, maxLevel: Game.maxBizLevel) { biz.cost * ($0 + 1) * ($0 + 1) }
        let st = stock
        let available = Grade.all
            .filter { $0.index >= biz.minGrade }
            .reduce(0) { $0 + (st[$1.id] ?? 0) }
        let need = biz.demand * level
        let maxed = p.n == 0
        let affordable = !maxed && count >= p.total
        let minName = Grade.all[biz.minGrade].name
        let subtitle = biz.minGrade > 0
            ? "Платит \(biz.price) за бутылку • нужен сорт: \(minName)+"
            : "Платит \(biz.price) за бутылку"
        let statusText = available >= need ? "работает" : (available == 0 ? "⚠︎ нет колы" : "⚠︎ мало колы")
        let verb = level == 0 ? "Открыть" : "Улучшить"
        let buyLabel = maxed ? "Максимум" : "\(verb) ×\(p.n.formatted())"

        return VStack(spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: biz.icon)
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(biz.color))
                VStack(alignment: .leading, spacing: 0) {
                    Text(biz.name).bold()
                    Text(subtitle).appFont(12).opacity(0.6)
                }
                Spacer()
                Text(level > 0 ? "ур. \(level)" : "закрыт")
                    .appFont(15, .bold)
            }

            if level > 0 {
                HStack {
                    Text("Спрос: \(need.formatted()) бут./сек").appFont(12)
                    Spacer()
                    Text(statusText)
                        .appFont(12, .bold)
                        .foregroundStyle(available >= need ? upColor : downColor)
                }
            }

            Button {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                count -= p.total
                var all = bizLevels
                all[biz.id] = level + p.n
                bizLevels = all
            } label: {
                HStack {
                    Text(buyLabel).bold()
                    Spacer()
                    Text(maxed ? "МАКС" : p.total.formatted()).bold()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(affordable ? 0.85 : 0.25), in: RoundedRectangle(cornerRadius: 10))
                .foregroundStyle(.white)
            }
            .disabled(!affordable)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.95), in: RoundedRectangle(cornerRadius: 14))
        .foregroundStyle(.black)
    }

    private func supplyCost(_ price: Double, pack: Int, n: Int) -> Int {
        Int((price * Double(pack) * Double(n)).rounded(.up))
    }

    private func supplierCard(_ sup: SupplierInfo) -> some View {
        let st = market[sup.quoteKey] ?? CoinState.initial(sup.quote)
        let grade = Grade.find(sup.grade)
        let first = st.history.first ?? st.price
        let trendColor: Color = st.price >= first ? downColor : upColor   // для покупателя рост цены — плохо
        let change = first > 0 ? (st.price / first - 1) * 100 : 0
        let arrow = change >= 0 ? "▲" : "▼"
        let changeText = "\(arrow) \(String(format: "%.1f", abs(change)))%"
        let perBottle = String(format: "%.2f", st.price)

        let cap = Game.capacity(warehouse)
        let free = max(0, cap - totalStock(stock))
        let spacePacks = free / sup.pack
        let packCost = max(0.01, st.price * Double(sup.pack))
        let afford = Int(Double(count) / packCost)
        let buyN = buyAmount == 0 ? min(afford, spacePacks) : min(buyAmount, spacePacks)
        let shown = buyN > 0 ? buyN : max(1, min(buyAmount == 0 ? 1 : buyAmount, max(1, spacePacks)))
        let cost = supplyCost(st.price, pack: sup.pack, n: shown)
        let canBuy = buyN > 0 && cost <= count
        let bottles = sup.pack * shown
        let btnSub = spacePacks == 0
            ? "склад полон"
            : "×\(shown.formatted()) = \(bottles.formatted()) бут. • \(cost.formatted())"

        return VStack(spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: sup.icon)
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(grade.color))
                VStack(alignment: .leading, spacing: 0) {
                    Text(sup.name).bold()
                    Text("\(grade.name) • партия \(sup.pack.formatted()) бут.")
                        .appFont(12).opacity(0.6)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 0) {
                    Text("\(perBottle) / бут.").appFont(15, .bold)
                    Text(changeText).appFont(12, .bold).foregroundStyle(trendColor)
                }
            }

            Sparkline(values: st.history, color: trendColor)
                .frame(height: 28)

            Text(sup.note).appFont(12).opacity(0.7)
                .frame(maxWidth: .infinity, alignment: .leading)

            tradeButton("Заказать", btnSub, color: upColor, enabled: canBuy) {
                buySupply(sup, price: st.price, n: buyN)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.95), in: RoundedRectangle(cornerRadius: 14))
        .foregroundStyle(.black)
    }

    private func buySupply(_ sup: SupplierInfo, price: Double, n: Int) {
        let cost = supplyCost(price, pack: sup.pack, n: n)
        guard n > 0, cost <= count else { return }
        var delivered = sup.pack * n
        var lost = 0
        if sup.risk > 0 {
            lost = Int(Double(delivered) * sup.risk * Double.random(in: 0.5...1.5))
            lost = min(lost, delivered)
            delivered -= lost
        }
        count -= cost
        var st = stock
        st[sup.grade, default: 0] += delivered
        stock = st
        supplyNote = lost > 0 ? "Брак при доставке: потеряно \(lost.formatted()) бут." : ""
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        if lost > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) { supplyNote = "" }
        }
    }

    // MARK: Действия

    private func tap() {
        let crit = Int.random(in: 1...100) <= Game.critChance(critLevel)
        let gain = clickGain * (crit ? Game.critMultiplier : 1)
        count = min(count + gain, Game.limit)
        addEarned(gain)
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
        if away >= 3 {
            stepMarket(times: min(Int(away), 1800))
            let maxSeconds = Double(max(1, maxOfflineHours)) * 3600
            let secs = Int(min(away, maxSeconds))
            let gain = secs * autoGain + runBusinesses(seconds: secs)
            if gain > 0 {
                count = min(count + gain, Game.limit)
                addEarned(gain)
                offlineGain = gain
                showOffline = true
            }
        }
        lastSeen = now
    }
}
