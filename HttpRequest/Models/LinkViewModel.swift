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
import Alamofire

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
    
    
//    func fetchWeb(url: URL) async -> String? {
//        do {
//            let (data, _) = try await URLSession.shared.data(from: url)
//            return String(data: data, encoding: .utf8)!
//        } catch {
//            print("Failed to fetch web")
//            return nil
//        }
//    }
    
    func fetchWeb(url: URL) async throws -> String? {
        try await withUnsafeThrowingContinuation { continuation in
            AF.request(url).responseData { response in
                if let data = response.data {
                    continuation.resume(returning: String(data: data, encoding: .utf8)!)
                    return
                }
                if let err = response.error {
                    continuation.resume(returning: nil)
                    return
                }
                fatalError("Error while doing url request")
            }
        }
    }
    
    func addLink(urlString: String) async {
        let url = URL(string: urlString)
        var webTitle: String?
        var webDescription: String?
        var webThumbnail: Data?
        
//        let webData = await fetchWeb(url: url!)
//        if(webData == nil) {
//            print("invalid link!")
//            return
//        }
        
        var webData: String?
        do {
            webData = try await fetchWeb(url: url!)
        } catch {
            print("Failed to fetch web")
            print(error)
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




enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case put = "PUT"
}

protocol URLRequestProtocol {
    var url: URL { get }
    var body: Data? { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var urlRequest: URLRequest { get }
}

extension URLRequestProtocol {
    var urlRequest: URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if let body = body {
            request.httpBody = body
        }
        
        headers?.forEach { (key, value) in
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        return request
    }
}
