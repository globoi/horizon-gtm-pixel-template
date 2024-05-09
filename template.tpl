___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "displayName": "GPixel",
  "categories": [
    "ADVERTISING",
    "ANALYTICS"
  ],
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "brand": {
    "id": "brand_dummy",
    "displayName": ""
  },
  "description": "Tag para envio de eventos para o Pixel da Globo",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "clientId",
    "displayName": "Pixel Id",
    "simpleValueType": true
  },
  {
    "type": "SELECT",
    "name": "eventType",
    "displayName": "Trigger Event",
    "macrosInSelect": true,
    "selectItems": [
      {
        "value": "PageView",
        "displayValue": "PageView"
      },
      {
        "value": "Click",
        "displayValue": "Click"
      },
      {
        "value": "AddPaymentInfo",
        "displayValue": "AddPaymentInfo"
      },
      {
        "value": "AddToCart",
        "displayValue": "AddToCart"
      },
      {
        "value": "AddToWishlist",
        "displayValue": "AddToWishlist"
      },
      {
        "value": "Search",
        "displayValue": "Search"
      },
      {
        "value": "Subscribe",
        "displayValue": "Subscribe"
      },
      {
        "value": "CompletePayment",
        "displayValue": "CompletePayment"
      },
      {
        "value": "SubmitForm",
        "displayValue": "SubmitForm"
      },
      {
        "value": "InitiateCheckout",
        "displayValue": "InitiateCheckout"
      }
    ],
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "pixelURL",
    "displayName": "Pixel URL",
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "eventValue",
    "displayName": "Event Value",
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "orderId",
    "displayName": "orderId",
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "gadvId",
    "displayName": "gadvId",
    "simpleValueType": true
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

const log = require('logToConsole');
const encodeUriComponent = require('encodeUriComponent');
const getUrl = require('getUrl');
const getReferrerUrl = require('getReferrerUrl');
const sendPixel = require('sendPixel');
const getTimestampMillis = require('getTimestampMillis');
const generateRandom = require('generateRandom');
const setCookie = require('setCookie');
const getCookieValues = require('getCookieValues');
const getQueryParameters = require('getQueryParameters');


log('data =', data);

// UUID Function
function generateUUID() {
    var uuid = "";
    for (var i = 0; i < 36; i++) {
        if (i === 8 || i === 13 || i === 18 || i === 23) {
            uuid += "-";
        } else if (i === 14) {
            uuid += "4";
        } else if (i === 19) {
            uuid += "89ab"[generateRandom(0, 3)];
        } else {
            uuid += "0123456789abcdef"[generateRandom(0, 15)];
        }
    }
    return uuid;
}

function _(v) {
  return encodeUriComponent(v);
}

// Config
const schemaId = 'globopixel-event';
const version = '0.2';
const GBIDCookieExpires = 'Thu, 31 Dec 2099 23:59:59 GMT';

const url = getUrl();

// Generating browserId
const browserIds = getCookieValues("GBID");

log(browserIds);

let browserId;

if(browserIds.length == 0) {
  log('Cookie not set');
  const newBrowserId = "GBID." + getTimestampMillis() + "." + generateUUID();
  
   setCookie("GBID", newBrowserId, {path: "/", domain:"auto", 'expires': GBIDCookieExpires});

  browserId = newBrowserId;
  
} else {
  log('Cookie set');
  browserId = browserIds[0];
}

log(browserId);


let secondsIn90Days = 7776000;
let gadvId = getQueryParameters("gadv_id");
let gadvIdCookie = getCookieValues("gadvId");


if (gadvId){
  if (gadvIdCookie.length == 0 || gadvIdCookie[0] != gadvId){
    log('Setting new gadvId Cookie');
    setCookie("gadvId", gadvId , {path: "/", domain:"auto", 'max-age': secondsIn90Days});
  }
}

// Verifies if data.pixelURL is empty
if (!data.pixelURL) {
  log('Error: pixelURL is empty');
  if (data && typeof data.gtmOnFailure === 'function') {
    data.gtmOnFailure('pixelURL is empty');
  }
} else {
  // Base
  let pixelURL = data.pixelURL;

  // Event Configuration
  pixelURL = pixelURL + '?environment=web';
  pixelURL = pixelURL + '&contentType=globopixel';
  pixelURL = pixelURL + '&id=' + _(schemaId);
  pixelURL = pixelURL + '&version=' + _(version);

  // Schema Properties
  pixelURL = pixelURL + '&properties.eventType=' + data.eventType;
  pixelURL = pixelURL + '&properties.pixelClientId=' + data.clientId;
  pixelURL = pixelURL + '&properties.browserId=' + _(browserId);
  if(data.eventValue){
    pixelURL = pixelURL + '&properties.eventValue=' + data.eventValue;
  }
  if(data.orderId){
    pixelURL = pixelURL + '&properties.orderId=' + data.orderId;
  }
 if (gadvId){
   pixelURL = pixelURL + '&properties.gadvId=' + gadvId;
  }
 
  // Essential Fields
  pixelURL = pixelURL + '&horizonClientReferer=' + _(getReferrerUrl());
  pixelURL = pixelURL + '&referer=' + _(getReferrerUrl());
  pixelURL = pixelURL + '&url=' + _(url);
  pixelURL = pixelURL + '&horizonClientVersion=0.1.1';
  pixelURL = pixelURL + '&clientTs=' + _(getTimestampMillis());
  pixelURL = pixelURL + '&clientUUID=' + _(generateUUID());
  pixelURL = pixelURL + '&horizonActionUUID=' + _(generateUUID());
  pixelURL = pixelURL + '&horizonRelationId=' + _(browserId);
  log(pixelURL);
  sendPixel(pixelURL, data.gtmOnSuccess, data.gtmOnFailure);

}


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "get_cookies",
        "versionId": "1"
      },
      "param": [
        {
          "key": "cookieAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "cookieNames",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "GBID"
              },
              {
                "type": 1,
                "string": "hsid"
              },
              {
                "type": 1,
                "string": "GLOBO_ID"
              },
              {
                "type": 1,
                "string": "glb_uid"
              },
              {
                "type": 1,
                "string": "gpixel_uid"
              },
              {
                "type": 1,
                "string": "gadvId"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "get_referrer",
        "versionId": "1"
      },
      "param": [
        {
          "key": "urlParts",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "queriesAllowed",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "send_pixel",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedUrls",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://*.globo.com/*"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "set_cookies",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedCookies",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "name"
                  },
                  {
                    "type": 1,
                    "string": "domain"
                  },
                  {
                    "type": 1,
                    "string": "path"
                  },
                  {
                    "type": 1,
                    "string": "secure"
                  },
                  {
                    "type": 1,
                    "string": "session"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "GBID"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "name"
                  },
                  {
                    "type": 1,
                    "string": "domain"
                  },
                  {
                    "type": 1,
                    "string": "path"
                  },
                  {
                    "type": 1,
                    "string": "secure"
                  },
                  {
                    "type": 1,
                    "string": "session"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "hsid"
                  },
                  {
                    "type": 1,
                    "string": "globo.com"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "name"
                  },
                  {
                    "type": 1,
                    "string": "domain"
                  },
                  {
                    "type": 1,
                    "string": "path"
                  },
                  {
                    "type": 1,
                    "string": "secure"
                  },
                  {
                    "type": 1,
                    "string": "session"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "GLOBO_ID"
                  },
                  {
                    "type": 1,
                    "string": ".globo.com"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "name"
                  },
                  {
                    "type": 1,
                    "string": "domain"
                  },
                  {
                    "type": 1,
                    "string": "path"
                  },
                  {
                    "type": 1,
                    "string": "secure"
                  },
                  {
                    "type": 1,
                    "string": "session"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "glb_uid"
                  },
                  {
                    "type": 1,
                    "string": "globo.com"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "name"
                  },
                  {
                    "type": 1,
                    "string": "domain"
                  },
                  {
                    "type": 1,
                    "string": "path"
                  },
                  {
                    "type": 1,
                    "string": "secure"
                  },
                  {
                    "type": 1,
                    "string": "session"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "gpixel_uid"
                  },
                  {
                    "type": 1,
                    "string": "globo.com"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  }
                ]
              },
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "name"
                  },
                  {
                    "type": 1,
                    "string": "domain"
                  },
                  {
                    "type": 1,
                    "string": "path"
                  },
                  {
                    "type": 1,
                    "string": "secure"
                  },
                  {
                    "type": 1,
                    "string": "session"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "gadvId"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "get_url",
        "versionId": "1"
      },
      "param": [
        {
          "key": "urlParts",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "queriesAllowed",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: Untitled test 1
  code: |-
    const mockData = {
      // Mocked field values
      "url": "https://gpixel.globo.com/pixel-event?"+ "properties.gadv_id=teste1234",
      "eventType":"PageView","gtmTagId":2147483646,"gtmEventId":1,"pixelURL": "https://gpixel.globo.com/pixel-event?"
    };

    // Call runCode to run the template's code.
    runCode(mockData);

    // Verify that the tag finished successfully.
    assertApi('gtmOnSuccess').wasCalled();


___NOTES___

Created on 02/02/2024, 10:45:57


