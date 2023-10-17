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
    
    func saveLink(url: URL, title: String?, description: String?, thumbnail: Data?) {
        let newLink = Links(context: viewContext)
        newLink.timestamp = Date()
        newLink.url = url
        newLink.title = title
        newLink.desc = description
        newLink.thumbnail = thumbnail
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
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
    
    func addLink(stringUrl: String) async {
        let url = URL(string: stringUrl)
        let webData = await fetchWeb(url: url!)
        
        if(webData == nil) {
            print("invalid link!")
            return
        }
        
        var webTitle: String?
        var webDescription: String?
        var webThumbnail: Data?
        
        do {
            let html: Document = try SwiftSoup.parse(webData!)
            
            let htmlMetaTitle = try html.head()!.select("meta[property=og:title]").first() ?? html.head()!.select("meta[name=twitter:title]").first() ?? html.head()!.select("meta[property=twitter:title]").first() ?? nil
            let htmlMetaDescription = try html.head()!.select("meta[name=og:description]").first() ?? html.head()!.select("meta[name=twitter:description]").first() ?? html.head()!.select("meta[property=twitter:description]").first() ?? html.head()!.select("meta[name=description]").first() ?? html.head()!.select("meta[itemprop=description]").first() ?? nil
            let htmlMetaThumbnail = try /*html.head()!.select("meta[property=og:image:secure_url]").first() ?? html.head()!.select("meta[property=og:image:url]").first() ?? html.head()!.select("meta[property=og:image]").first() ?? html.head()!.select("meta[name=twitter:image:src]").first() ?? html.head()!.select("meta[property=twitter:image:src]").first() ?? html.head()!.select("meta[name=twitter:image]").first() ?? html.head()!.select("meta[property=twitter:image]").first() ?? */html.head()!.select("meta[itemprop=image]").first() ?? html.head()!.select("meta[property=og:logo]").first() ?? html.head()!.select("meta[itemprop=logo]").first() ?? html.head()!.select("img[itemprop=logo]").first() ?? nil
            
            if(htmlMetaTitle != nil) {
                webTitle = try htmlMetaDescription!.attr("content")
            } else if (try html.title() != ""){
                webTitle = try html.title()
            } else {
                webTitle = nil
            }
            
            if(htmlMetaDescription != nil) {
                webDescription = try htmlMetaDescription!.attr("content")
            } else {
                webDescription = nil
            }
            
            if(htmlMetaThumbnail != nil) {
                var webThumbnailLink = try htmlMetaThumbnail!.attr("content")
                
                if(webThumbnailLink.hasPrefix("/") || webThumbnailLink.hasPrefix("/") || !webThumbnailLink.hasPrefix("http")) {
                    webThumbnailLink = "\(stringUrl)\(webThumbnailLink)"
                }
                
                if let data = try? Data(contentsOf: URL(string: webThumbnailLink)!) {
                    webThumbnail = data
                    saveLink(url: url!, title: webTitle, description: webDescription, thumbnail: webThumbnail)
                }
                
            } else {
                webThumbnail = nil
            }
            
        } catch Exception.Error(let type, let message) {
            print(message)
        } catch {
            print("error")
        }
        
    }
    
}
