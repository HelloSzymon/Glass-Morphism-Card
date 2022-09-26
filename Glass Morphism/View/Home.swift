//
//  Home.swift
//  Glass Morphism
//
//  Created by Szymon Wnuk on 26/09/2022.
//

import SwiftUI

struct Home: View {
    @State var blurView: UIVisualEffectView = .init()
    @State var defaultBlurRadius: CGFloat = 0
    @State var defaultSaturationAmount: CGFloat =  0
    @State var activateGlassMorphism: Bool = false
    var body: some View {
        ZStack {
            Color.black
            
            Circle()
                .fill(LinearGradient (gradient: Gradient(colors: [.purple, .blue]), startPoint: .leading, endPoint: .trailing))
                .frame(maxWidth: 250, maxHeight: 250)
                .offset(x: 150, y: -90)
            
            Circle()
                .fill(LinearGradient (gradient: Gradient(colors: [.orange, .red]), startPoint: .leading, endPoint: .trailing))
                .frame(maxWidth: 120, maxHeight: 120)
                .offset(x: -150, y: 90)
            
            Circle()
                .fill(LinearGradient (gradient: Gradient(colors: [.mint, .white]), startPoint: .leading, endPoint: .trailing))
                .frame(maxWidth: 50, maxHeight: 50)
                .offset(x: -40, y: -100)
            
            GlassMorphicCard()
            
                      Toggle("Activate", isOn: $activateGlassMorphism)
                .font(.title3)
                .fontWeight(.semibold)
            
                            .onChange(of: activateGlassMorphism) {
                                newValue in
                                blurView.gausianBlurRadius = (activateGlassMorphism ? 10 : defaultBlurRadius)
                                blurView.saturationAmount = (activateGlassMorphism ? 1.8: defaultSaturationAmount)
                            }
                            .frame(maxHeight: .infinity, alignment: .bottom)
                            .padding(15)
        }
    }
    
    @ViewBuilder
    func GlassMorphicCard() -> some View {
        ZStack {
            CustomBlurView(effect: .systemUltraThinMaterialDark) {
                view in
                blurView = view
                if defaultBlurRadius == 0 {defaultBlurRadius = view.gausianBlurRadius}
                if defaultSaturationAmount == 0 {defaultSaturationAmount = view.saturationAmount}
            }
            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
            
        }
        RoundedRectangle(cornerRadius: 25,style: .continuous)
            .fill(
                .linearGradient(colors: [.white.opacity(0.25),
                                         .white.opacity(0.05),
                                         .clear], startPoint: .topLeading, endPoint: .bottomTrailing)).blur(radius: 5)
        
        RoundedRectangle(cornerRadius: 25,style: .continuous)
            .stroke(
                .linearGradient(colors: [.white.opacity(0.6),
                                         .clear,
                                         .white.opacity(0.2),
                                         .white.opacity(0.5)],
                                startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 3)
            .shadow(color: .black.opacity(0.15), radius: 5, x: -10,  y: 10)
            .shadow(color: .black.opacity(0.15), radius: 5, x: 10,  y: -10)
            .overlay(content: {
                CardContent()
                    .opacity(activateGlassMorphism ? 1 : 0)
                    .animation(.easeIn(duration: 0.5 ), value: activateGlassMorphism)
            })
            .padding(.horizontal, 25)
            .frame(height: 220)
    }
    
    
    @ViewBuilder
    func CardContent() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("MEMBERSHIP")
                    .modifier(CustomModifier(font: .callout))
                
                Image("Chelsea-logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
            }
            Spacer()
            Text("Szymon Wnuk")
                .modifier(CustomModifier(font: .title3))
            Text("Chelsea FC")
                .modifier(CustomModifier(font: .callout))
            
        }
        .padding(20)
        .padding(.vertical, 10)
        .blendMode(.overlay)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct CustomModifier: ViewModifier {
    var font: Font
    func body (content:Content) -> some View {
        content
            .font(font)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .kerning(1.2)
            .shadow(radius: 15)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}


struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct CustomBlurView: UIViewRepresentable {
    var effect: UIBlurEffect.Style
    var oncChange: (UIVisualEffectView) -> ()
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: effect))
        return view
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        DispatchQueue.main.async {
            oncChange(uiView)
        }
    }
}
extension UIVisualEffectView
{
    var backDrop: UIView? {
        return subView(forClass: NSClassFromString("_ UIVisualEffectBackdropView"))
    }
    var gaussianBlur: NSObject? {
        return backDrop?.value(key: "filters", filter: "gaussinBlur")
    }
    var saturation: NSObject? {
        return backDrop?.value(key: "filters", filter: "colorSaturate")
    }
    var gausianBlurRadius: CGFloat{
        get {
            return gaussianBlur?.values?["inputRadius"] as? CGFloat ?? 0
        }
        set {
            gaussianBlur?.values?["inputRadius"] =  newValue
        }
    }
    func applyNewEffects() {
        backDrop?.perform(Selector(("applyFilers")))
    }
     
    var saturationAmount: CGFloat{
        get {
            return saturation?.values?["inputAmount"] as? CGFloat ?? 0
        }
        set {
            saturation?.values?["inputAmount"] =  newValue
            applyNewEffects()
        }
    }
}
extension UIView{
    func subView(forClass : AnyClass?) -> UIView? {
        return subviews.first { view in
            type(of: view) == forClass
        }
    }
}
extension NSObject {
    var values: [String: Any]? {
        get  {
            return value(forKeyPath: "requestedValues") as? [String: Any]
        }
        set {
            setValue(newValue, forKeyPath: "requestedValues")
        }
    }
}

extension NSObject {
    func value (key: String, filter: String) -> NSObject?{
        (value(forKey: key) as? [NSObject])?.first(where : { obj in
            return obj.value(forKeyPath: "filtertype") as? String == filter
        })
    }
}
