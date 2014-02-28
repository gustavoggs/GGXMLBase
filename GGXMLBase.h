//
//  Created by Gustavo Graña on 27/02/14.
//

#import <Foundation/Foundation.h>
#import <RaptureXML/RXMLElement.h>

@interface GGXMLBase : NSObject

@property (nonatomic,strong) NSString* xmlRoot;
@property (nonatomic,strong) NSString* xmlNamespace;
@property (nonatomic,strong) NSString* xmlPrefix;
@property (nonatomic,strong) NSDictionary* xmlElements;
@property (nonatomic,strong) NSDictionary* xmlArraysClass;
@property (nonatomic,strong) NSDictionary* propertiesClass;

- (NSString*) objectXMLHeader;
- (NSString*) objectXMLHeaderClose;
- (NSString*) objectXMLElements;
- (NSString*) body;

- (void) populateWithNode:(RXMLElement*)xmlNode;

@end
