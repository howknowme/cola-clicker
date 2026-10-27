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
    @State private var pressed = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var clickCost: Int { 25 * perClick * perClick }
    private var autoCost: Int { 50 * (autoRate + 1) }

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.75, green: 0.05, blue: 0.1), .black],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Coca-Cola Clicker")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)

                Text("\(count)")
                    .font(.system(size: 64, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())

                Text("+\(perClick) за клик • +\(autoRate)/сек")
                    .foregroundStyle(.white.opacity(0.8))

                Button {
                    count += perClick
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
                        count -= clickCost; perClick += 1
                    }
                    upgrade("Автокликер (+1/сек)", cost: autoCost) {
                        count -= autoCost; autoRate += 1
                    }
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .onReceive(timer) { _ in count += autoRate }
    }

    private func upgrade(_ title: String, cost: Int, action: @escaping () -> Void) -> some View {
