//
//  LinkViewModel.swift
//  HttpRequest
//
//  Created by Kadek Edwin on 15/10/23.
//

import Foundation
import SwiftUI
import UIKit
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
            print("Failed to fetch web")
            return nil
        }
    }
    
    func test() {
//        let task = URLSession.shared.dataTask(with: URL(string: "https://youtube.com")!) {(data, response, error) in
//            guard let data = data else { return }
//            print(String(data: data, encoding: .utf8)!)
//        }
//        task.resume()
        
//        if let url = URL(string: "https://www.youtube.com") {
//            do {
//                let contents = try String(contentsOf: url)
//                print(contents)
//            } catch {
//                print("in catch")
//            }
//        } else {
//            print("bad url")
//        }
        
        
    }
    
    func addLink(urlString: String) async {
        let url = URL(string: urlString)
        var webTitle: String?
        var webDescription: String?
        var webThumbnail: Data?
        
        let webData = await fetchWeb(url: url!)
        
        if(webData == nil) {
            print("invalid link!")
            return
        }
        
        do {
            let html: Document = try SwiftSoup.parse(webData!)
            
            let htmlMetaTitle: Element? = try html.head()!.select("meta[property=og:title]").first() ?? html.head()!.select("meta[name=twitter:title]").first() ?? html.head()!.select("meta[property=twitter:title]").first()
            let htmlMetaDescription: Element? = try html.head()!.select("meta[name=og:description]").first() ?? html.head()!.select("meta[name=twitter:description]").first() ?? html.head()!.select("meta[property=twitter:description]").first() ?? html.head()!.select("meta[name=description]").first() ?? html.head()!.select("meta[itemprop=description]").first()
//            separate htmlmetathumbnail to 2 because its error if its to long
            var htmlMetaThumbnail: Element? = try html.head()!.select("meta[property=og:image:secure_url]").first() ?? html.head()!.select("meta[property=og:image:url]").first() ?? html.head()!.select("meta[property=og:image]").first() ?? html.head()!.select("meta[name=twitter:image:src]").first()
            if(htmlMetaThumbnail == nil) {
                htmlMetaThumbnail = try html.head()!.select("meta[property=twitter:image:src]").first() ?? html.head()!.select("meta[name=twitter:image]").first() ?? html.head()!.select("meta[property=twitter:image]").first() ?? html.head()!.select("meta[itemprop=image]").first() ?? html.head()!.select("meta[property=og:logo]").first() ?? html.head()!.select("meta[itemprop=logo]").first() ?? html.head()!.select("img[itemprop=logo]").first()
            }
            
            test()
            print(htmlMetaThumbnail)
            
            if(htmlMetaTitle == nil) {
                print("htmlMetaTitle nil")
            }
            if(htmlMetaDescription == nil) {
                print("htmlMetaDescription nil")
            }
            if(htmlMetaThumbnail == nil) {
                print("htmlMetaThumbnail nil")
            }
            
            if(htmlMetaTitle != nil) {
                webTitle = try htmlMetaTitle!.attr("content")
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
                var webThumbnailUrlString = try htmlMetaThumbnail!.attr("content")
                if(webThumbnailUrlString.hasPrefix("/") || !webThumbnailUrlString.hasPrefix("http")) {
                    webThumbnailUrlString = "\(urlString)\(webThumbnailUrlString)"
                }
                
                if let webThumbnailUrl = URL(string: webThumbnailUrlString) {
                    print(webThumbnailUrl)
                    webThumbnail = try? Data(contentsOf: webThumbnailUrl)
                }
            } else {
                webThumbnail = nil
            }
            
            saveLink(url: url!, title: webTitle, description: webDescription, thumbnail: webThumbnail)
            
        } catch Exception.Error(let type, let message) {
            print(message)
        } catch {
            print("error")
        }
        
    }
    
}
