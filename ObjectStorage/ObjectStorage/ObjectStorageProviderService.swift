/*
* Core data service protocol. (Currently, injected protocols require the @objc annotation).
*/
public protocol ObjectStorageProviderService {
    
    // create new model data
    func create(model: Model) -> Bool
    
    // read model data
    func read<T: Model>(model: T) -> T?
    
    // udapte existing model data
    func update(model: Model) -> Bool
    
    // update existing model data but ignore empty values like empty string
    func updateIgnoreEmptyValues(model: Model) -> Bool
    
    // delete model data
    func delete(model: Model) -> Bool
    
    // clear all model datas
    func clear()
    
}