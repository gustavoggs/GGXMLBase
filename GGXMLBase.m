
//
//  Created by Gustavo Graña on 27/02/14.
//

#import "GGXMLBase.h"
#import <objc/runtime.h>

@implementation GGXMLBase

- (id)init {
    self = [super init];
    if (self) {
        self.propertiesClass = [GGXMLBase classPropsFor:[self class]];
    }
    return self;
}


- (NSString*) objectXMLHeader {
    NSMutableString* str;
    str = [NSMutableString stringWithFormat:@"<"];
    if (self.xmlPrefix && [self.xmlPrefix length] > 0) {
        [str appendString:self.xmlPrefix];
        [str appendString:@":"];
    }
    [str appendString:self.xmlRoot];
    if (self.xmlPrefix && [self.xmlPrefix length] > 0 && self.xmlNamespace) {
        [str appendString:@" xmlns:"];
        [str appendString:self.xmlPrefix];
        [str appendString:@"=\""];
        [str appendString:self.xmlNamespace];
        [str appendString:@"\">"];
    } else {
        [str appendString:@"\">"];
    }

    return str;
}

- (NSString*) objectXMLHeaderClose {
    NSMutableString* str;
    str = [NSMutableString stringWithFormat:@"</"];
    if (self.xmlPrefix && [self.xmlPrefix length] > 0) {
        [str appendString:self.xmlPrefix];
        [str appendString:@":"];
    }
    [str appendString:self.xmlRoot];
    [str appendString:@">"];
    return str;
}

- (NSString*) objectXMLElements {
    NSMutableString* xmlElements = [NSMutableString string];
    for (NSString* element in [self.xmlElements allKeys]) {
        id value = [self valueForKey:[self.xmlElements objectForKey:element]];
        NSMutableString* xmlElement = [NSMutableString string];
        if (value) {
            if ([value isKindOfClass:[NSString class]]) {
                [xmlElement appendString:@"<"];
                if (self.xmlPrefix && [self.xmlPrefix length] > 0) {
                    [xmlElement appendString:self.xmlPrefix];
                    [xmlElement appendString:@":"];
                }
                [xmlElement appendString:element];
                [xmlElement appendString:@">"];
                [xmlElement appendString:value];
                [xmlElement appendString:@"</"];
                if (self.xmlPrefix && [self.xmlPrefix length] > 0) {
                    [xmlElement appendString:self.xmlPrefix];
                    [xmlElement appendString:@":"];
                }
                [xmlElement appendString:element];
                [xmlElement appendString:@">"];
            } else {
                [xmlElement appendString:[value body]];
            }
        }
        [xmlElements appendString:xmlElement];
        
    }
    return xmlElements;
}


- (NSString*) body {
    NSMutableString* body = [NSMutableString stringWithString:[self objectXMLHeader]];
    [body appendString:[self objectXMLElements]];
    [body appendString:[self objectXMLHeaderClose]];
    return body;
}

- (void) populateWithNode:(RXMLElement*)xmlNode {
        for (NSString* element in [self.xmlElements allKeys]) {
            NSString* varName = [self.xmlElements objectForKey:element];
            
            NSArray* nodes = [xmlNode children:element];
            for (RXMLElement* xmlValue in nodes) {
                
                __block BOOL isObject = false;
                if (xmlValue) {
                    [xmlValue iterate:@"*" usingBlock:^(RXMLElement *e) {
                        isObject = true;
                    }];
                }
            
                if (isObject) {
                    NSString* className = [self.propertiesClass objectForKey:varName];
                    Class c = NSClassFromString(className);
                    if (c == [NSMutableArray class]) {
                        NSMutableArray* array = [self valueForKey:varName];
                        if (!array) {
                            array = [[NSMutableArray alloc] init];
                            [self setValue:array forKey:varName];
                        }
                        NSString* classNameArray = [self.xmlArraysClass objectForKey:varName];
                        Class cArray = NSClassFromString(classNameArray);
                        GGXMLBase* newValue = [[cArray alloc] init];
                        
                        [newValue populateWithNode:xmlValue];
                        [array addObject:newValue];

                    } else {
                        GGXMLBase* newValue = [[c alloc] init];
                    
                        [newValue populateWithNode:xmlValue];
                        [self setValue:newValue forKey:varName];
                    }
                } else {
                    [self setValue:xmlValue forKey:varName];
                }
            }
        }
    }
}

+ (NSDictionary *)classPropsFor:(Class)klass {
    NSLog(@"Properties for class:%@", klass);
    if (klass == NULL || klass == [NSObject class]) {
        return nil;
    }
    
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(klass, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        
        NSString* propertyAttributes = [NSString stringWithUTF8String:property_getAttributes(property)];
        NSArray* splitPropertyAttributes = [propertyAttributes componentsSeparatedByString:@"\""];
        if ([splitPropertyAttributes count] >= 2 && propName) {
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            [results setObject:[splitPropertyAttributes objectAtIndex:1] forKey:propertyName];
        }
        
    }
    free(properties);
    
    return results;
}

@end
