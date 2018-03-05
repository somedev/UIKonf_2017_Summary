import PlaygroundSupport
import Foundation
URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)

let reposURL = URL(string:"https://api.github.com/users/somedev/repos")!
let userURL = URL(string:"https://api.github.com/repos/somedev")!

//Model
struct GithubRepo {
    let name:String
    let url:URL
    
    init?(JSON: [String:AnyObject]){
        guard let urlString = JSON["url"] as? String,
            let url = URL(string: urlString),
            let name = JSON["name"] as? String
            else {
                return nil
        }
        self.url = url
        self.name = name
    }
    
    
    let reposResource = Resource<[GithubRepo]>(url: reposURL, parse: { json in
        guard let repos = json as? [[String:AnyObject]] else { return nil }
        return repos.flatMap(GithubRepo.init)
    })
    
    func repoResource(for name:String) -> Resource<GithubRepo> {
        let URL = userURL.appendingPathComponent(name)
        return Resource<GithubRepo>(url:URL){ json  in
            guard let repo = json as? [String:AnyObject] else { return nil }
            return GithubRepo(JSON: repo)
        }
    }
}

struct Resource<A> {
    let url:URL
    let parse:(Any)->A?
}




//Service


final class WebService {
    func load<A>(resource:Resource<A>, completion: @escaping (A?) -> ()) {
        let task = URLSession.shared.dataTask(with: resource.url) { data, _, _ in
            guard let data = data,
                let json = try? JSONSerialization.jsonObject(with: data)
                else {
                    completion(nil)
                    return
            }
            
            let result = resource.parse(json)
            completion(result)
        }
        
        task.resume()
    }
    
}



















PlaygroundPage.current.needsIndefiniteExecution = true

let service = WebService()

//service.loadRepos { print("\n\($0!)") }

//service.loadRepo(name: "DribbbleAPI") { print("\n\($0!)") }

//service.load(resource: reposResource) { print("\n\($0!)") }

//service.load(resource:repoResource(for: "DribbbleAPI")) { print("\n\($0!)") }
