//
//  LinkView.swift
//  HttpRequest
//
//  Created by Kadek Edwin on 15/10/23.
//

import SwiftUI

struct LinkView: View {
    @EnvironmentObject var linkViewModel: LinkViewModel
    
    @State private var inputLink: String = ""
    @FocusState private var inputLinkFocused: Bool?
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                ForEach(linkViewModel.links, id: \.self) { link in
                    HStack{
//                        UIImage(named: "test2")?.pngData())!
                        Image(uiImage: UIImage(data: link.thumbnail!)!)
                            .resizable()
                            .scaledToFill()
                            .clipped()
                            .frame(width: 120)
                        
                        VStack(alignment: .leading) {
                            Text(link.title ?? "title is nil!")
                                .font(.subheadline)
                            Text(link.desc ?? "description is nil!")
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
        .frame(maxWidth: .infinity)
        .overlay {
            ZStack {
                HStack {
                    HStack {
                        TextField("Link", text: $inputLink)
                            .focused($inputLinkFocused, equals: true)
                            .onSubmit {
                                
                            }
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(inputLinkFocused == true ? .primary : .secondary, lineWidth: 2)
                            )
                    }
                    .textFieldStyle(DefaultTextFieldStyle())
                    
                    Button {
                        Task {
                            if(inputLink != "") {
                                await linkViewModel.addLink(stringUrl: inputLink)
                            } else {
                                inputLinkFocused = true
                            }
                        }
                    } label: {
                        Circle()
                            .frame(width: 56)
                            .foregroundStyle(.blue)
                            .overlay {
                                Image(systemName: "plus")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 24))
                                    .bold()
                            }
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding()
        }
    }
}

#Preview {
    LinkView()
}


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
