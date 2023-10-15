//
//  LinkView.swift
//  HttpRequest
//
//  Created by Kadek Edwin on 15/10/23.
//

import SwiftUI

struct LinkView: View {
    @EnvironmentObject var linkViewModel: LinkViewModel
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                ForEach(linkViewModel.links, id: \.self) { link in
                    HStack{
                        Image(uiImage: UIImage(data: link.thumbnail!)!)
                            .resizable()
                            .scaledToFill()
                            .clipped()
                            .frame(width: 120)
                        
                        VStack(alignment: .leading) {
                            Text(link.title!)
                                .font(.subheadline)
                            Text(link.desc!)
                                .font(.caption)
                                .foregroundStyle(.gray)
                            Text(link.url!.absoluteString)
                                .font(.caption)
                                .foregroundStyle(.blue)
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: 80)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
            }
            
        }
        .overlay {
            ZStack {
                Button {
                    
                } label: {
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(.gray)
                        .frame(height: 60)
                        .overlay {
                            Image(systemName: "plus")
                                .foregroundStyle(.white)
                                .font(.system(size: 24))
                                .bold()
                        }
                        .padding()
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }
}

#Preview {
    LinkView()
}



//private func addItem() {
//    withAnimation {
//        let newItem = Item(context: viewContext)
//        newItem.timestamp = Date()
//
//        do {
//            try viewContext.save()
//        } catch {
//            // Replace this implementation with code to handle the error appropriately.
//            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            let nsError = error as NSError
//            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//        }
//    }
//}
//
//private func deleteItems(offsets: IndexSet) {
//    withAnimation {
//        offsets.map { items[$0] }.forEach(viewContext.delete)
//
//        do {
//            try viewContext.save()
//        } catch {
//            // Replace this implementation with code to handle the error appropriately.
//            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            let nsError = error as NSError
//            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//        }
//    }
//}
//
//private let itemFormatter: DateFormatter = {
//    let formatter = DateFormatter()
//    formatter.dateStyle = .short
//    formatter.timeStyle = .medium
//    return formatter
//}()
