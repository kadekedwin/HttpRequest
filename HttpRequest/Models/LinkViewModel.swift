//
//  LinkViewModel.swift
//  HttpRequest
//
//  Created by Kadek Edwin on 15/10/23.
//

import Foundation
import CoreData
import SwiftSoup

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
    
    func saveLink(url: URL, title: String, description: String) {
        let newLink = Links(context: viewContext)
        newLink.timestamp = Date()
        newLink.url = url
        newLink.title = title
        newLink.desc = description
//        newLink.thumbnail = UIImage(named: "test2")?.pngData()
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
    }
    
    func addLink(stringUrl: String) async {
        let url = URL(string: stringUrl)
        let webData = await fetchWeb(url: url!)
        
        if(webData == nil) {
            print("invalid link!")
            return
        }
        
        var webTitle: String?
        var webDescription: String?
//        var webThumbnail: UIImage
        
        do {
            let html: Document = try SwiftSoup.parse(webData!)
            let htmlMetaDescription = try html.head()!.select("meta[name=og:description]").first() ?? html.head()!.select("meta[name=twitter:description]").first() ?? html.head()!.select("meta[property=twitter:description]").first() ?? html.head()!.select("meta[name=description]").first() ?? html.head()!.select("meta[itemprop=description]").first() ?? nil
            
            webTitle = try html.title()
            if(htmlMetaDescription != nil) {
                webDescription = try htmlMetaDescription!.attr("content")
            } else {
                webDescription = "no description!"
            }
            
        } catch Exception.Error(let type, let message) {
            print(message)
        } catch {
            print("error")
        }
        
        saveLink(url: url!, title: webTitle!, description: webDescription!)
    }
    
    func fetchWeb(url: URL) async -> String? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return String(data: data, encoding: .utf8)!
        } catch {
            print("Failed to fetch data")
            return nil
        }
    }
    
//    func fetchWebb(linkUrl: String, result: ((String) -> (Void))?) {
//        let url = URL(string: linkUrl)
//
//        let task = URLSession.shared.dataTask(with: url!) {
//            (data, response, error) in
//
//            if let error = error {
//                print("Error: \(error)")
//                return
//            }
//
//            if let data = data {
//                result!(String(data: data, encoding: .utf8)!)
//            }
//        }
//        task.resume()
//    }
    
}
