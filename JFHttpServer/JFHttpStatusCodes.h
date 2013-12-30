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
    HTTPStatusMovedTemporarily   = 302,
    HTTPStatusSeeOther           = 303,
    HTTPStatusNotModified        = 304,
    HTTPStatusUseProxy           = 305,
    HTTPStatusSwitchProxy        = 306,
    HTTPStatusTemporaryRedirect  = 307,
    HTTPStatusPermanentRedirect  = 308,

    HTTPStatusBadRequest         = 400,
    HTTPStatusUnauthorized       = 401,
    HTTPStatusPaymentRequired    = 402,
    HTTPStatusForbidden          = 403,
    HTTPStatusNotFound           = 404,
    HTTPStatusMethodNotAllowed   = 405,
    HTTPStatusNotAcceptable      = 406,
    HTTPStatusProxyAuthenticationRequired = 407,
    HTTPStatusRequestTimeout     = 408,
    HTTPStatusConflict           = 409,
    HTTPStatusGone               = 410,
    HTTPStatusLengthRequired     = 411,
    HTTPStatusPreconditionFailed = 412,
    HTTPStatusRequestEntityTooLarge = 413,
    HTTPStatusRequestUriTooLong  = 414,
    HTTPStatusUnsupportedMediaType = 415,
    HTTPStatusRequestedRangeNotSatisfiable = 416,
    HTTPStatusExpectationFailed  = 417,
    HTTPStatusImATeapot          = 418,

    HTTPStatusInternalServerError = 500,
    HTTPStatusNotImplemented     = 501,
    HTTPStatusBadGateway         = 502,
    HTTPStatusServiceUnavailable = 503,
    HTTPStatusGatewayTimeout     = 504,    
};


#endif
