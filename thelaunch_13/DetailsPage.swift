//
//  DetailsPage.swift
//  AcademyFirst
//
//  Created by Layan Nasser on 09/05/1448 AH.
//

import Foundation
import SwiftUI



struct DetailsPage: View {
    // ✅ تغيير 1: النشاط اللي ضغطتي عليه. بدونه الصفحة ما تعرف وش تعرض
    let activity: Activity
    // ✅ تغيير 2: عشان نرجع للصفحة اللي قبلها (زر السهم)
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .top) {

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
            
                    
            
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.5))
                .frame(width: 329, height: 700)
                .frame(maxHeight: .infinity, alignment: .bottom)
            
            
            
        RoundedRectangle(cornerRadius: 12)
                           
                .fill(Color("LightGreen1"))
                .frame(width: 280, height: 159)
                            
                .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color("LightGreen2") , lineWidth: 1)
                            )
            
            // for both of them
                .frame(maxHeight: .infinity, alignment: .center)
            .padding(.top , 150)
                        
            
           
          
            
            ZStack {
                Image("PathShape")
                Image("Recycle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120)
                
            }
            
            .padding(.top , 170)
            
               
          
            
        VStack(spacing: 16) {
        VStack(alignment: .trailing, spacing: 8) {
   
            
            //tag
            Text(activity.category.rawValue)
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(Color("DarkGreen1"))
            //   الخلفيه البيضاويه
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color("LightGreen2").opacity(0.1), in: Capsule())
            
            
            //Title of the activity
            Text(activity.title)
                .font(.custom("TheYearofHandicrafts-medium", size: 24))
                .foregroundStyle(Color("DarkGreen2"))
            
                
            
            ZStack{
                
                // ✅ تغيير 5: بدل الوصف الثابت، صار يطلع وصف النشاط
                Text(activity.details)
                
                    .font(.system(size: 16, weight: .light))
                    .multilineTextAlignment(.trailing)
                    .padding(12)
                    //.padding(.vertical , 20)
                   // .padding(.horizontal, 20)
                    .frame(width: 280, height: 160)
                    .foregroundStyle(Color("DarkGreen2"))
            }
            
            
            
            
            
            Text("بإنجاز هذه المهمة تساهم في:")
                .font(.system(size: 14, weight: .regular))
            
                .foregroundStyle(Color("DarkGreen2"))
                .padding(.top, 20)
          
            
            
        
            
            
           

          
        HStack(spacing: 16) {
                        
            
        ZStack {
        RoundedRectangle(cornerRadius: 12)
                .fill(Color("LightGreen1").opacity(0.30).shadow(.inner(color: Color("ShadowColor").opacity(0.10), radius: 3)))
            
       .frame(width: 90, height: 100)
        VStack(spacing: 4) {
        Image(systemName: "bolt.fill")
                .foregroundStyle(Color("DarkGreen1"))
        .font(.system(size: 14))
        .frame(width: 28, height: 28)
        .background(Color("LightGreen2"), in: Circle())
        Text("توفير الطاقة")
       .font(.custom("TheYearofHandicrafts-regular", size: 12))
            .foregroundStyle(Color("DarkGreen2"))}
        }


                
        ZStack {
        RoundedRectangle(cornerRadius: 12)
                
                .fill(Color("LightGreen1").opacity(0.30).shadow(.inner(color: Color("ShadowColor").opacity(0.10), radius: 3)))
            
        .frame(width: 90, height: 100)
                    
        VStack(spacing: 4) {
        Image(systemName: "drop.fill")
        .foregroundStyle(Color("DarkGreen1"))
        .font(.system(size: 14))
        .frame(width: 28, height: 28)
        .background(Color("LightGreen2"), in:
                        Circle())
        Text("توفير المياة")
        .font(.custom("TheYearofHandicrafts-regular", size: 12))
            .foregroundStyle(Color("DarkGreen2"))}}
            
            
        ZStack {
        RoundedRectangle(cornerRadius: 12)
                .fill(Color("LightGreen1").opacity(0.30).shadow(.inner(color: Color("ShadowColor").opacity(0.10), radius: 3)))
            
                .frame(width: 90, height: 100)
                
        VStack(spacing: 4) {
        Image(systemName: "carbon.dioxide.cloud.fill")
        .foregroundStyle(Color("DarkGreen1"))
        .font(.system(size: 14))
        .frame(width: 28, height: 28)
        .background(Color("LightGreen2"), in: Circle())
        Text("خفض الانبعاثات")
        .font(.custom("TheYearofHandicrafts-regular", size: 12))
            .foregroundStyle(Color("DarkGreen2"))}}
        
        
        .frame(width: 80, height: 80) }
        .frame(maxWidth: .infinity)
        .padding(.top, 10)
            
            // ✅ تغيير 6: حذفنا زر "أضف المهمة" من هنا
                            }
                        }
    .frame(width: 277, alignment: .trailing)

    .padding(.top, 300)
                        
    HStack {
    Spacer()
        
        
    Button {
        // ✅ تغيير 7: بدل //action. زر السهم يرجعك للصفحة اللي قبلها
        dismiss()
    } label: {
        Image(systemName: "arrow.right")
                            }
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .controlSize(.large)
                            
                        }
        .overlay {
        Text("تفاصيل المهمة")
        .font(.custom("TheYearofHandicrafts-medium", size: 25))
        .foregroundStyle(Color("DarkGreen2"))
                        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
                        
                   
        }
        
        .preferredColorScheme(.light)
        // ✅ تغيير 8: يخفي زر الرجوع حق النظام، لأن عندك زر السهم الخاص فيك (عشان ما يطلع زرين)
        .navigationBarBackButtonHidden(true)
                }
            }

// ✅ تغيير 9: الصفحة صارت تطلب نشاط، فنعطيها نشاط تجريبي عشان المعاينة تشتغل
#Preview {
    DetailsPage(activity: Activity(.recycle, "فرز النفايات", "وصف تجريبي", 20, tag: "فرز النفايات"))
}
