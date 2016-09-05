# ObjectStorage

[![CocoaPods](https://img.shields.io/cocoapods/v/LiObjectStorage.svg)](https://github.com/tonyli508/ObjectStorage.git)
[![Build Status](https://travis-ci.org/tonyli508/ObjectStorage.svg?branch=master)](https://travis-ci.org/tonyli508/ObjectStorage)

ObjectStorage is a framework that make CRUD works on your model entities, you may choose what storage you want e.g. Sqlite, CoreData, plist...

## Current Support
- [x] CoreData
- [ ] Sqlite
- [ ] UserDefaults
- [ ] Keychains 
- [ ] File

## How to use 

Best thing to do is have a look at ObjectStorageTests.

1. Make your model conform to Model protocol, I suggest you create a base class for that, take a look at MappableModel in ObjectStorageTests folder.
```swift
class UserProfile: Model
```
Most import for CoreData is set up your ModelIdentifier in your model.
```swift
public typealias ModelIdentifier = (modelName: String, keys: [String], values: [String?])
```
modelName is the CoreData model name, keys and values will use for CoreData queries.
2. Create StorageProviderService instance
```swift
let storageProvider = StorageProviderService(coreDataModelFileName: "Model")
```
3. Then CRUD your model
```swift
let profile = UserProfile(firstName: 'Jiantang', lastName: 'Li')
storageProvider.create(profile)
storageProvider.update(profile)
let read = storageProvider.read(profile)
storageProvider.delete(profile)
``` 

## CocoaPods

ObjectStorage's already taken, so I use 'LiObjectStorage' instead.

```ruby
pod 'LiObjectStorage', '~> 0.1.1'
```

## Carthage

```ruby
github "tonyli508/ObjectStorage", "~> 0.1.1"
```

## TODOs
- Simplify Model Protocol.
- More storage support.
- Add more complex testings.
- Carthage support.
