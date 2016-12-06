//
//  AppConfiguration.h
//  GeekNavi
//
//  Created by GeekNavi on 2/27/16.
//
//

// 1. Set your Backend URL (Optional, only required after purchase)
#define __kBasePath @"http://www.example.com/ws/"

// 1a. Don't forget to set your webhost URL in GeekNavi-Info.plist! This is a new requirement from Apple (More info here: http://stackoverflow.com/questions/31216758/how-can-i-add-nsapptransportsecurity-to-my-info-plist-file)

// 2. Set your Stripe Key (Found under: https://dashboard.stripe.com/account/apikeys)
#define __STRIPE_API_KEY @"pk_test_*"

// 3. Set your Google Maps Geocoding API Key (Optional)
#define __GOOGLE_API_KEY @"API_KEY"

// 4. Set the Main Theme Color (Primary background color)
#define __MAIN_THEME_COLOR [UIColor whiteColor]

// 5. Set the Sub Theme Color (Primary text/button color)
#define __SUB_THEME_COLOR [UIColor colorWithRed:22.0/255.0f green:156.0/255.0f blue:229.0/255.0 alpha:1.0f]

// 6. Set the Invitation Text:
#define __INVITE_TEXT @"I.. Love... GeekNavi!"

// 7. Set your GeekNavi API Key: (Don't have one? Request one by contacting us at support@geeknavi.com)
#define __GEEK_API_KEY @"API_KEY"

