import SwiftUI

struct TopNav_V: View {
    @ObservedObject var navManager: NavManager
    
    init(appManager: AppManager){
        self.navManager = appManager.getNavManagerForNavView()
    }
    
    var body: some View {
        HStack {
            Button(action: { navManager.movePrev() }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
                    .font(.system(size: 24))
                    .frame(width: 60)
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text(navManager.title)
                    .font(.largeTitle)
                    .background(navManager.title == "TODAY" ? Color.yellow.opacity(0.8) : Color.clear)
                Text(navManager.subtitle)
                    .font(.headline)
            }.padding(10)
            
            Spacer()
            
            Button(action: { navManager.moveNext() }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.blue)
                    .font(.system(size: 24))
                    .frame(width: 60)
            }
        }.background(Color(.white))

    }
}

#Preview {
    VStack {
        TopNav_V(appManager: AppManager())
        Spacer()
    }.background(Color(.green))
}
