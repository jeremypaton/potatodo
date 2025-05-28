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
                    .font(.system(size: 34))
                    .fontWeight(.bold)
                    .frame(width: 60)
            }
            
            Spacer()
            
            VStack(spacing: 4) {
//                if(navManager.title == "TODAY") {
//                    Text("★ " + navManager.title + " ★")
//                        .font(.largeTitle)
//                        .background(Color.clear)
//                    Text(navManager.subtitle)
//                        .font(.headline)
//                } else {
                    Text(navManager.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text(navManager.subtitle)
                        .font(.headline)
                        .foregroundColor(.gray)
//                }
            }.padding(10)
            
            Spacer()
            
            Button(action: { navManager.moveNext() }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.blue)
                    .font(.system(size: 34))
                    .fontWeight(.bold)
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
