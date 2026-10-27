import SwiftUI

struct ContentView: View {
    @State private var count = 0
    
    var body: some View {
        ZStack {
            // Фон приложения
            LinearGradient(colors: [.red, .black], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                Text("Coca-Cola Clicker")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                
                // Счётчик кликов
                Text("Score: \(count)")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.yellow)
                
                Spacer()
                
                // Кнопка-кликер с иконкой
                Button(action: {
                    count += 1
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 180, height: 180)
                            .shadow(radius: 10)
                        
                        VStack(spacing: 5) {
                            Image(systemName: "cup.and.saucer.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.red)
                            
                            Text("DRINK!")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                        }
                    }
                }
                .scaleEffect(1.0)
                
                Spacer()
            }
            .padding()
        }
    }
}
