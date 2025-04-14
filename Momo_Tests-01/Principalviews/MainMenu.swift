//
//  MainMenu.swift
//  Momo_Tests-01
//
//  Created by Jose julian Lopez on 14/04/25.
//

import SwiftUI

struct MainMenu: View {
    var body: some View {
        
        VStack(spacing: 15){
            
            Image("Reason")
                .resizable()
                .scaledToFill()
                .frame(width:280,height: 420 )
                .clipped()
            
            VStack(spacing: 32){
                Text("Nueva partida")
                    .font(.system(size: 32, weight: .medium))
                Text("Capitulos")
                    .font(.system(size: 32, weight: .medium))
                Text("Configuracion")
                    .font(.system(size: 32, weight: .medium))
                Text("Galeria")
                    .font(.system(size: 32, weight: .medium))
                
            }
        }
    }
}

#Preview {
    MainMenu()
}
