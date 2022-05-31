import UIKit

struct PersonResult: Codable {
    let result: [Person]
}

struct PersonData: Codable {
    let data: [Person]
}

struct Person: Codable {
    let name: String
    let age: Int
    let isDeveloper: Bool
}

protocol DataHandler {
    var next: DataHandler? { get set }
    func processData(_ data: Data) -> [Person]
}

class FirstDataHandler: DataHandler {
    var next: DataHandler?
    func processData(_ data: Data) -> [Person] {
        var persons: [Person] = []
        let decoder = JSONDecoder()
        do {
            let json = try decoder.decode(PersonData.self, from: data)
            persons = json.data
        } catch {
            if let next = next {
                persons = next.processData(data)
            }
        }
        return persons
    }
}

class SecondDataHandler: DataHandler {
    var next: DataHandler?
    func processData(_ data: Data) -> [Person] {
        var persons: [Person] = []
        let decoder = JSONDecoder()
        do {
            let json = try decoder.decode(PersonResult.self, from: data)
            persons = json.result
        } catch {
            if let next = next {
                persons = next.processData(data)
            }
        }
        return persons
    }
}

class ThirdDataHandler: DataHandler {
    var next: DataHandler?
    func processData(_ data: Data) -> [Person] {
        var persons: [Person] = []
        let decoder = JSONDecoder()
        do {
            let json = try decoder.decode([Person].self, from: data)
            persons = json
        } catch {
            if let next = next {
                persons = next.processData(data)
            }
        }
        return persons
    }
}

func data(from file: String) -> [Person] {
    let path1 = Bundle.main.path(forResource: file, ofType: "json")!
    let url = URL(fileURLWithPath: path1)
    let data = try! Data(contentsOf: url)
    var persons: [Person] = []
    
    do {
        let firstDataHandler = FirstDataHandler()
        let secondDataHandler = SecondDataHandler()
        let thirdDataHandler = ThirdDataHandler()
        firstDataHandler.next = secondDataHandler
        secondDataHandler.next = thirdDataHandler
        thirdDataHandler.next = nil
        persons = firstDataHandler.processData(data)
    }
    return persons
}

let data1 = data(from: "1")
let data2 = data(from: "2")
let data3 = data(from: "3")
