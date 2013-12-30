//
//  JFHttpStatusCodes.h
//  JFHttpServer
//
//  Created by Jonathan Fischer on 12/29/13.
//  Copyright (c) 2013 Jonathan Fischer. All rights reserved.
//

#ifndef JFHttpServer_JFHttpStatusCodes_h
#define JFHttpServer_JFHttpStatusCodes_h

#include "JFHttpEnumCompat.h"

typedef NS_ENUM(NSInteger, HTTPStatus) {
    HTTPStatusContinue           = 100,
    HTTPSTatusSwitchingProtocols = 101,
    HTTPStatusProcessing         = 102,

    HTTPStatusOk                 = 200,
    HTTPStatusCreated            = 201,
    HTTPStatusAccepted           = 202,
    HTTPStatusNonAuthoritative   = 203,
    HTTPStatusNoContent          = 204,
    HTTPStatusResetContent       = 205,
    HTTPStatusPartialContent     = 206,
    HTTPStatusMultiStatus        = 207,
    HTTPStatusAlreadyReported    = 208,
    HTTPStatusIMUsed             = 226,

    HTTPStatusMultipleChoices    = 300,
    HTTPStatusMovedPermanently   = 301,
    HTTPStatusFound              = 302,
    HTTPStatusSeeOther           = 303,
    HTTPStatusNotModified        = 304,
    HTTPStatusUseProxy           = 305,
    HTTPStatusSwitchProxy        = 306,
    HTTPStatusTemporaryRedirect  = 307,
    HTTPStatusPermanentRedirect  = 308,

    HTTPStatusBadRequest         = 400,
    HTTPStatusUnauthorized       = 401,
};


#endif
