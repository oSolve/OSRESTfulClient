# OSRESTfulClient

<!-- [![CI Status](http://img.shields.io/travis/TC94615/OSRESTfulClient.svg?style=flat)](https://travis-ci.org/TC94615/OSRESTfulClient)
[![Version](https://img.shields.io/cocoapods/v/OSRESTfulClient.svg?style=flat)](http://cocoapods.org/pods/OSRESTfulClient)
[![License](https://img.shields.io/cocoapods/l/OSRESTfulClient.svg?style=flat)](http://cocoapods.org/pods/OSRESTfulClient)
[![Platform](https://img.shields.io/cocoapods/p/OSRESTfulClient.svg?style=flat)](http://cocoapods.org/pods/OSRESTfulClient) -->

### Making a http request has never been easier.
OSRESTfulClient is a light-weight RESTful client for iOS APP. Inspired by [Retrofit](https://github.com/square/retrofit) and [Masonry](https://github.com/SnapKit/Masonry). Support Http/2.
## Usage

### Making a request
Making a request is very easy, just use the builder pattern:

```objc
OSRESTfulEndpoint *endpoint = [[OSRESTfulEndpoint alloc] initWithBaseURLString:@"https://api.github.com"];
OSRESTfulClient *client = [[OSRESTfulClient alloc] initWithEndpoint:endpoint
                                                          configuration:[NSURLSessionConfiguration defaultSessionConfiguration]];
BFTask *request = client.builder
						.setPath(@"/repos")
						.withGet
						.buildArrayWithModel([OSRepo class])
						.request;
```

Or path with parameters:

```objc
OSRESTfulEndpoint *endpoint = [[OSRESTfulEndpoint alloc] initWithBaseURLString:@"https://api.github.com"];
OSRESTfulClient *client = [[OSRESTfulClient alloc] initWithEndpoint:endpoint
                                                          configuration:[NSURLSessionConfiguration defaultSessionConfiguration]];
BFTask *request = client.builder
						.setPathAndParams(@"/users/{user_id}/repos", @{@"user_id" : userId})
						.withGet
						.buildArrayWithModel([OSRepo class])
						.request;
```  

And get the result:  

```objc
[request continueWithSuccessBlock:^id(BFTask *task) {
	 OSRepo *repo = task.result;
	 /* do something... */
    return nil;
}];
```

You can take full advantage of Bolts: chaining task together, error handling, tasks in series, tasks in parallel, ...etc.

## Requirements
* > iOS7

## Dependency
* [Bolts Framework](https://github.com/BoltsFramework/Bolts-iOS) (1.7.0)
* [AFNetworking](https://github.com/AFNetworking/AFNetworking) (3.1.0)
* [Mantle](https://github.com/Mantle/Mantle) (Default json decoder) (2.0.7)

## Installation

OSRESTfulClient is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "OSRESTfulClient"
```

## Author

Kros Huang, kros@osolve.com

## License

OSRESTfulClient is available under the MIT license. See the LICENSE file for more info.
