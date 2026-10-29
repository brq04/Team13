//
//  ContentView.swift
//  AcademyFirst
//
//  Created by Layan Nasser on 09/05/1448 AH.
//

import SwiftUI
import CoreLocation

struct WlcPage: View {
    var onNext: () -> Void = {}
    
    

  
   
    
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
            
            
            
            //(spacing: 27)
            Section{
                VStack {
                       Text(" مـرحـبًـا بـك!")
                           .font(.custom("TheYearofHandicrafts-Bold", size: 40))
                       Text(" فـي أثـر ")
                           .font(.custom("TheYearofHandicrafts-medium", size: 30))
                   }
                
                    .foregroundStyle(Color("DarkGreen2"))
                    .multilineTextAlignment(.center)
                    
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.top, 80)
            }
            
            
            Image(.ourCharacterWlc1)
                .resizable()
                .scaledToFit()
                .frame(width: 370)
                .frame(maxWidth: .infinity, maxHeight: .infinity,alignment: .bottomTrailing)
                .ignoresSafeArea(.container, edges: .bottom)
            
            
            Button{
                onNext()
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
       
            
            
               /* .onAppear {
                    // جديد: يطلب من iOS إظهار نافذة الإذن
                    locationManager.requestWhenInUseAuthorization()
                }*/
        .preferredColorScheme(.light)

        }

}

#Preview {
    WlcPage()
}
