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
    
    private var contributions: (energy: Bool, water: Bool, emissions: Bool) {
        switch activity.title {
        case "فرز النفايات",
            "إعداد كميات مناسبة",
            "الاستفادة من بقايا الطعام",
            "التخطيط لشراء الطعام",
            "استخدام الأطعمة الأقرب انتهاءً",
            "ترشيد استهلاك المياه":
            return (energy: true, water: true, emissions: true)
            
        case "استخدام النقل العام",
            "المشي بدلًا من القيادة",
            "التخلّص الآمن من الأجهزة الإلكترونية",
            "المساهمة المجتمعية",
            "إطفاء الأنوار غير المستخدمة",
            "إطفاء المكيّف عند الخروج":
            return (energy: true, water: false, emissions: true)
            
        case "الحدّ من استخدام البلاستيك":
            return (energy: false, water: false, emissions: true)
            
        default:
            return (energy: false, water: false, emissions: false)
        }
    }
    
    private func fullDescription() -> String {
        let descriptions: [String: String] = [
            "استخدام النقل العام": "في هذا النشاط، ستقوم باستخدام المترو أو الحافلة بدلًا من السيارة الخاصة للوصول إلى وجهتك، واختيار المسار والمحطّة المناسبين لرحلتك.",



            "المشي بدلًا من القيادة": "في هذا النشاط، ستقوم بالذهاب إلى وجهتك سيرًا على الأقدام بدلًا من استخدام السيارة، عندما تكون المسافة مناسبة لك، والأجواء ملائمة، ويتوفّر مسار آمن للمشي.",



            "فرز النفايات": "في هذا النشاط، ستقوم بفصل المواد القابلة لإعادة التدوير، مثل الورق والبلاستيك والمعادن، عن بقية النفايات، ووضعها في الحاويات المخصّصة لها حسب التعليمات الموضّحة عليها.",



            "التخلّص الآمن من الأجهزة الإلكترونية": "في هذا النشاط، ستقوم بتسليم الأجهزة الإلكترونية التالفة والبطاريات إلى نقاط الجمع المخصّصة لها، بدلًا من رميها مع النفايات المنزلية، مع اتباع تعليمات الجهة المستقبلة.",



            "الحدّ من استخدام البلاستيك": "في هذا النشاط، ستقوم باستبدال المنتجات البلاستيكية التي تُستخدم مرة واحدة ببدائل قابلة لإعادة الاستخدام، مثل القوارير والأكياس والأكواب وأدوات الطعام، واستخدامها مجددًا بدلًا من التخلّص منها بعد كل استخدام.",



            "المساهمة المجتمعية": "في هذا النشاط، ستقوم باختيار الملابس والأثاث الذي لم تعد تحتاج إليه، والتأكّد من نظافته وصلاحيته للاستخدام، ثم التبرّع به إلى جهة تستقبل هذه الأغراض.",



            "إعداد كميات مناسبة": "في هذا النشاط، ستقوم بتحديد كمية الطعام التي تحتاج إلى إعدادها بحسب عدد الأشخاص، وتقديم حصص مناسبة دون تحضير كميات تزيد على الحاجة.",



            "الاستفادة من بقايا الطعام": "في هذا النشاط، ستقوم بالاستفادة من بقايا الطعام الصالحة للأكل والمحفوظة بطريقة آمنة، من خلال تناولها لاحقًا أو استخدامها في إعداد وجبة أخرى.",



            "التخطيط لشراء الطعام": "في هذا النشاط، ستقوم بمراجعة الأطعمة الموجودة لديك قبل التسوّق، ثم كتابة قائمة بالأطعمة والكميات التي تحتاج إليها، والاعتماد عليها أثناء الشراء.",



            "استخدام الأطعمة الأقرب انتهاءً": "في هذا النشاط، ستقوم بمراجعة تواريخ صلاحية الأطعمة، ووضع الأقرب انتهاءً في مكان واضح لاستخدامها أولًا، مع الالتزام بتعليمات الحفظ والصلاحية على العبوة.",



            "ترشيد استهلاك المياه": "في هذا النشاط، ستقوم باستخدام المياه بقدر حاجتك في أنشطتك اليومية، وإيقاف تدفّقها عند عدم استخدامها، وتجنّب تركها تجري دون حاجة.",



            "إطفاء الأنوار غير المستخدمة": "في هذا النشاط، ستقوم بإطفاء الأنوار عند مغادرة الغرفة إذا لم يكن أحد بحاجة إليها، أو عندما تكون الإضاءة الطبيعية كافية.",



            "إطفاء المكيّف عند الخروج": "في هذا النشاط، ستقوم بالتأكّد من إطفاء المكيّف قبل مغادرة المنزل، إذا لم يكن هناك أحد يحتاج إلى بقائه قيد التشغيل.",



            "مبادرة السعودية الخضراء": "في هذا النشاط، ستقوم بالمشاركة في حملة للتشجير أو تنظيف المواقع الطبيعية، من خلال زراعة الشتلات أو جمع المخلفات، وفق تعليمات الجهة المنظّمة."

        ]
        return descriptions[activity.title] ?? activity.details
    }
    
    
    
    
    var body: some View {
        ZStack(alignment: .top) {
            
            AppBackground()
            
            
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.5))
                .frame(width: 329, height: 700)
                .frame(maxHeight: .infinity, alignment: .bottom)
            
            
            
           
            
           
            
            
            
            
            ZStack {
                Circle()
                    .fill(Color("LightGreen2").opacity(0.5))
                    .frame(width: 140, height: 140)
                

                Image(systemName: activity.category.look.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60)
                    .foregroundStyle(Color("DarkGreen1"))
                    .frame(width: 120)
                
            }
            
            .padding(.top , 150)
            
            
            
            
            VStack(spacing: 16) {
                VStack(alignment: .trailing, spacing: 20) {
                    
                    
                        //tag
                        Text(activity.category.rawValue)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(Color("DarkGreen1"))
                        //   الخلفيه البيضاويه
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(Color("LightGreen2").opacity(0.1), in: Capsule())
                    
                
                    
                    
                    Text(activity.title)
                        .font(.custom("TheYearofHandicrafts-medium", size: 20))
                        .foregroundStyle(Color("DarkGreen2"))
                    
                    
                    
                    Text(fullDescription())
                        .font(.system(size: 16, weight: .light))
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(Color("DarkGreen2"))
                        .padding(12)
                        .frame(width: 277, height: 160, alignment: .center)
                        .background(Color("LightGreen1"), in: RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color("LightGreen2"), lineWidth: 1)
                        )
                    
                    
                    
                    
                    if contributions.energy || contributions.water || contributions.emissions {
                        
                        Text("بإنجاز النشاط، تساهم في:")
                            .font(.system(size: 14, weight: .regular))
                        
                            .foregroundStyle(Color("DarkGreen2"))
                            .padding(.top, 20)
                        
                    }
                    
                    
                    
                    
                    
                    
                    
                    HStack(spacing: 16) {
                        
                        if contributions.energy {
                            
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
                        }
                        
                        if contributions.water{
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
                            
                        }
                        
                        
                        
                        if contributions.emissions{
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
                        }}
                        
                            .frame(width: 80, height: 80)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 10)
                        
                        
                    }
                }
                .frame(width: 277, alignment: .trailing)
                
                .padding(.top, 300)
                
                HStack {
                    Spacer()
                    
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.right")
                    }
                    .buttonStyle(.glass)
                    .buttonBorderShape(.circle)
                    .controlSize(.large)
                    
                }
                .overlay {
                    Text("تفاصيل النشاط")
                        .font(.custom("TheYearofHandicrafts-medium", size: 25))
                        .foregroundStyle(Color("DarkGreen2"))
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                
            }
            
            .preferredColorScheme(.light)
            // ✅ تغيير 8: يخفي زر الرجوع حق النظام، لأن عندك زر السهم الخاص فيك (عشان ما يطلع زرين)
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
            .toolbar(.hidden, for: .tabBar)
        }
    }

// ✅ تغيير 9: الصفحة صارت تطلب نشاط، فنعطيها نشاط تجريبي عشان المعاينة تشتغل
#Preview {

DetailsPage(activity: Activity(.transport,
                "التخلّص الآمن من الأجهزة الإلكترونية", "وصف تجريبي", 20, tag: "استخدام النقل العام"))
    }
