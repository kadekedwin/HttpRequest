//
//  LinkViewModel.swift
//  HttpRequest
//
//  Created by Kadek Edwin on 15/10/23.
//

import Foundation
import CoreData

class LinkViewModel: ObservableObject {
    private var viewContext: NSManagedObjectContext
    @Published var links: [Links] = []

    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        fetchLinks()
    }
    
    func fetchLinks() {
        let fetchRequest: NSFetchRequest<Links> = Links.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        do {
            links = try viewContext.fetch(fetchRequest)
        } catch {
            print("Fetching spaces failed: \(error.localizedDescription)")
        }
    }
    
    func addLink(linkURL: String) {
        
        
        
        let newLink = Links(context: viewContext)
        newLink.timestamp = Date()
        newLink.url = URL(string: linkURL)
//        newLink.title = "test"
//        newLink.desc = "test two gaf ag gnaeo agwiera wog awg awgawg w agriogahg aweorhawgerihoghaweo a owg awaw oghi"
//        newLink.thumbnail = UIImage(named: "test2")?.pngData()
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
