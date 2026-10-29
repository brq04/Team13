//
//  OnboardingPage.swift
//  AcademyFirst
//
//  Created by Layan Nasser on 13/05/1448 AH.
//
import SwiftUI
import CoreLocation

struct OnboardingPage: View {
 
    @State var step = 0
    var onFinish: () -> Void = {}
    var body: some View {
     
        
        ZStack        {
            ZStack {
            Color(red: 240/255, green: 245/255, blue: 238/255)

            Circle()
            .fill(RadialGradient(colors: [Color(red: 230/255, green: 236/255, blue: 200/255), Color.clear], center: .center, startRadius: 0, endRadius: 150))
           .frame(width: 300, height: 300)
           .offset(x: -80, y: -200)

            Circle()
            .fill(RadialGradient(colors: [Color(red: 230/255, green: 236/255, blue: 200/255), Color.clear], center: .center, startRadius: 0, endRadius: 150))
                .frame(width: 300, height: 300)
                .offset(x: 100, y: 50)

                Circle()
                .fill(RadialGradient(colors: [Color(red: 230/255, green: 236/255, blue: 200/255), Color.clear], center: .center, startRadius: 0, endRadius: 150))
                    .frame(width: 300, height: 300)
                    .offset(x: -60, y: 250)
                      }
                      .ignoresSafeArea()
            
            
        
            Section{
                 
                    VStack(alignment: .trailing, spacing:  16){
                        Text(step == 0 ? "إنجازك يتجدّد كل يوم" : "حدّد موقعك")
                       .font(.custom("TheYearofHandicrafts-Bold", size: 30))
                       .foregroundStyle(Color("DarkGreen2"))
                        Text(step == 0 ? "سجّل إنجازاتك، \n وتابع أثرك الإيجابي باستمرار" : "فعّل الموقع، \n ونوصلك بالفرص القريبة منك")
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(Color("DarkGreen2"))
                                                
                    
                    
                   }
                
            .id(step) //يخلي الشاشة تعتبر النص الجديد شي مختلف عن القديم، فيطلع القديم ويدخل الجديد بحركة. وذا
                
                
            .transition(.move(edge: .trailing).combined(with: .opacity))
                
                
                // transition: يحدد كيف يدخل الشي ويطلع من الشاشة
                // .move(edge: .trailing): ينزاح من الجنب (اليمين)
                // .opacity: يظهر تدريجي (من شفاف لواضح)
                // .combined(with:): يجمع حركتين مع بعض، يعني ينزاح ويظهر تدريجي في نفس الوقت
              
                
                
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                
            .padding(.top, 80)
            }
            
            
            Image(.ourEarthWlc1)
                .resizable()
                .scaledToFit()
                .frame(width: 370)
                
                .overlay {
                    if step == 1 {
                        Image(.locationPin)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 61)
                            .offset(x:20 , y: 10)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity,alignment: .bottomTrailing)
                .ignoresSafeArea(.container, edges: .bottom)
            
            
            
            Button{
                if step == 0 {
                    withAnimation(.easeInOut(duration: 0.6)) { step = 1 }
                } else {
                    // نطلب الإذن (نافذة أبل) وندخل التطبيق على طول
                    LocationService.shared.requestPermission()
                    onFinish()
                }
            }
            label:{
                Image(systemName: "arrowshape.left.fill")
                    .foregroundStyle(Color("DarkGreen1"))
                            .frame(width: 55, height: 48)
                    }
                    .buttonStyle(.glass)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .padding(.leading, 39)
            }
       
            
        .preferredColorScheme(.light)

        }

}

            
            
                
          

#Preview {
    OnboardingPage()
}
