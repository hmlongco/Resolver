//
//  Resolver+MultiParams.swift
//  Resolver
//
//  Created by Ahmad Mahmoud on 1/4/20.
//

extension Resolver {
    public func resolve<Service>(_ type: Service.Type = Service.self,
                                 name: String? = nil,
                                 arg0: Any? = nil,
                                 arg1: Any? = nil,
                                 arg2: Any? = nil,
                                 arg3: Any? = nil,
                                 arg4: Any? = nil,
                                 arg5: Any? = nil) -> Service {
        var args: Any? = nil
        var argsDict: [String : Any] = [:]
        if (arg0 != nil) { argsDict["arg0"] = arg0 }
        if (arg1 != nil) { argsDict["arg1"] = arg1 }
        if (arg2 != nil) { argsDict["arg2"] = arg2 }
        if (arg3 != nil) { argsDict["arg3"] = arg3 }
        if (arg4 != nil) { argsDict["arg4"] = arg4 }
        if (arg5 != nil) { argsDict["arg5"] = arg5 }
        if (!argsDict.isEmpty) {
            args = argsDict as Any
        }
        return resolve(type, name: name, args: args)
    }
    
    public func resolve<Service>(_ type: Service.Type = Service.self,
                                 name: String? = nil,
                                 params: Any...) -> Service {
        let args: Any? = params as Any
        return resolve(type, name: name, args: args)
    }
    
    public func resolveArguments(from args: Any) -> [Any]  {
        var argumentsArray: [Any] = []
        if let argsArray = args as? [Any] {
            argumentsArray = argsArray
        }
        else if let argsDict = args as? [String : Any] {
            for (_, arg) in argsDict {
                argumentsArray.append(arg)
            }
        }
        return argumentsArray
    }
    
    func firstArgument<T>(from args: Any) -> T? {
        if let arg = resolveArguments(from: args)[exist: 0] {
            return arg as? T
        }
        else {
            return nil
        }
    }
    
    func secondArgument<T>(from args: Any) -> T? {
        if let arg = resolveArguments(from: args)[exist: 1] {
            return arg as? T
        }
        else {
            return nil
        }
    }
    
    func thirdArgument<T>(from args: Any) -> T? {
        if let arg = resolveArguments(from: args)[exist: 2] {
            return arg as? T
        }
        else {
            return nil
        }
    }
    
    func argument<T>(from args: Any, argumentNo: Int) -> T? {
        if let arg = resolveArguments(from: args)[exist: argumentNo] {
            return arg as? T
        }
        else {
            return nil
        }
    }
}

extension Collection where Indices.Iterator.Element == Index {
    subscript (exist index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
