import UIKit

struct Person: Codable {
    let name: String
    let age: Int
    let isDeveloper: Bool
}

protocol Parser {
    var next: Parser? { get set }
    
    func parse(file json: String) -> [Person]
}

extension Parser {
    func data(from file: String) -> Data {
        let path1 = Bundle.main.path(forResource: file, ofType: "json")!
        let url = URL(fileURLWithPath: path1)
        let data = try! Data(contentsOf: url)
        return data
    }
}

class RootParser: Parser {
    var next: Parser?
    
    func parse(file json: String) -> [Person] {
        let data = data(from: json)
        do {
            let persons = try JSONDecoder().decode([Person].self, from: data)
            return persons
        } catch {
            return next?.parse(file: json) ?? []
        }
    }
}

class DataParser: Parser {
    private struct WrappedPersons: Codable {
        var data: [Person]
    }
    
    var next: Parser?
    
    func parse(file json: String) -> [Person] {
        let data = data(from: json)
        do {
            let persons = try JSONDecoder().decode(WrappedPersons.self, from: data)
            return persons.data
        } catch {
            return next?.parse(file: json) ?? []
        }
    }
}

class ResultParser: Parser {
    private struct WrappedPersons: Codable {
        var result: [Person]
    }
    
    var next: Parser?
    
    func parse(file json: String) -> [Person] {
        let data = data(from: json)
        do {
            let persons = try JSONDecoder().decode(WrappedPersons.self, from: data)
            return persons.result
        } catch {
            return next?.parse(file: json) ?? []
        }
    }
}

func getPersons(from file: String) -> [Person] {
    let rootParser = RootParser()
    let dataParser = DataParser()
    let resultParser = ResultParser()
    let parser: Parser = rootParser

    rootParser.next = dataParser
    dataParser.next = resultParser
    
    return parser.parse(file: file)
}

print(getPersons(from: "1"))
print(getPersons(from: "2"))
print(getPersons(from: "3"))
