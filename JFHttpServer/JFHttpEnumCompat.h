//
//  JFHttpEnumCompat.h
//  JFHttpServer
//
//  Created by Jonathan Fischer on 12/29/13.
//  Copyright (c) 2013 Jonathan Fischer. All rights reserved.
//

#ifndef JFHttpServer_JFHttpEnumCompat_h
#define JFHttpServer_JFHttpEnumCompat_h

#ifndef NS_ENUM
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#endif

#endif
