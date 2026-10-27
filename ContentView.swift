import SwiftUI
import Combine

// MARK: - Главная точка входа в приложение
@main
struct CockacolaClickerApp: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            CokeClickerView()
        }
    }
}

// MARK: - Главный экран кликера
struct CokeClickerView: View {
    // Хранение баланса и параметров в памяти устройства
    @AppStorage("cockacolaBalance") private var balance: Int = 0
    @AppStorage("clickPower") private var clickPower: Int = 1
    @AppStorage("autoClickRate") private var autoClickRate: Int = 0
    
    // Состояние анимаций и секретного меню
    @State private var isPressed: Bool = false
    @State private var showCheatMenu: Bool = false
    @State private var cheatAmountInput: String = ""
    @State private var pressTimer: Timer? = nil
    @State private var isHolding: Bool = false
    
    // Таймер пассивного дохода (автокликер)
    let autoTimer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Тёмный фон в стиле Coca-Cola
                LinearGradient(gradient: Gradient(colors: [Color.black, Color(red: 0.3, green: 0.0, blue: 0.0)]),
                               startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Счётчик крышек
                    VStack {
                        Text("КРЫШКИ")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                        Text("\(balance)")
                            .font(.system(size: 48, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Большая крышка от колы
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.red, Color(red: 0.6, green: 0, blue: 0)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 220, height: 220)
                            .shadow(color: .red.opacity(0.5), radius: isPressed ? 10 : 25, x: 0, y: 0)
                        
                        Circle()
                            .stroke(Color.white.opacity(0.8), lineWidth: 6)
                            .frame(width: 190, height: 190)
                        
                        Text("Coca-Cola")
                            .font(.system(size: 28, weight: .bold, design: .serif))
                            .italic()
                            .foregroundColor(.white)
                    }
                    .scaleEffect(isPressed ? 0.88 : 1.0)
                    .animation(.spring(response: 0.2, dampingFraction: 0.5), value: isPressed)
                    // Обработка обычного клика и долгого нажатия на 5 секунд
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                if !isHolding {
                                    isHolding = true
                                    isPressed = true
                                    startPressTimer()
                                }
                            }
                            .onEnded { _ in
                                isHolding = false
                                isPressed = false
                                resetPressTimer()
                                balance += clickPower
                            }
                    )
                    
                    Spacer()
                    
                    // Переход в магазин улучшений
                    NavigationLink(destination: UpgradesStoreView()) {
                        HStack {
                            Image(systemName: "cart.fill")
                            Text("Магазин улучшений")
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(15)
                        .padding(.horizontal, 40)
                    }
                    .padding(.bottom, 20)
                }
            }
            .onReceive(autoTimer) { _ in
                if autoClickRate > 0 {
                    balance += autoClickRate
                }
            }
            // Секретное Чит-меню (Alert)
            .alert("Секретное Чит-Меню", isPresented: $showCheatMenu) {
                TextField("Введите количество крышек", text: $cheatAmountInput)
                    .keyboardType(.numberPad)
                Button("Применить") {
                    if let newBalance = Int(cheatAmountInput) {
                        balance = newBalance
                    }
                    cheatAmountInput = ""
                }
                Button("Отмена", role: .cancel) { cheatAmountInput = "" }
            } message: {
                Text("Вы нашли пасхалку! Введите сколько крышек хотите получить на баланс:")
            }
        }
    }
    
    // Таймер на 5 секунд для пасхалки
    private func startPressTimer() {
        pressTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
            showCheatMenu = true
        }
    }
    
    private func resetPressTimer() {
        pressTimer?.invalidate()
        pressTimer = nil
    }
}

// MARK: - Экран Магазина Улучшений
struct UpgradesStoreView: View {
    @AppStorage("cockacolaBalance") private var balance: Int = 0
    @AppStorage("clickPower") private var clickPower: Int = 1
    @AppStorage("autoClickRate") private var autoClickRate: Int = 0
    
    @AppStorage("clickUpgradeCost") private var clickUpgradeCost: Int = 10
    @AppStorage("autoUpgradeCost") private var autoUpgradeCost: Int = 50
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Баланс: \(balance) крышек")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
                    .padding(.top)
                
                List {
                    // Улучшение клика
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Быстрый палец (+1 за клик)")
                                .font(.headline)
                            Text("Текущий сипа: +\(clickPower)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Button("\(clickUpgradeCost) крышек") {
                            if balance >= clickUpgradeCost {
                                balance -= clickUpgradeCost
                                clickPower += 1
                                clickUpgradeCost = Int(Double(clickUpgradeCost) * 1.5)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                        .disabled(balance < clickUpgradeCost)
                    }
                    
                    // Автокликер
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Завод Колы (+1/сек)")
                                .font(.headline)
                            Text("Доход: \(autoClickRate)/сек")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Button("\(autoUpgradeCost) крышек") {
                            if balance >= autoUpgradeCost {
                                balance -= autoUpgradeCost
                                autoClickRate += 1
                                autoUpgradeCost = Int(Double(autoUpgradeCost) * 1.6)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                        .disabled(balance < autoUpgradeCost)
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("Магазин")
    }
}