//
//  GeekDestinationPin.h
//  GeekNavi
//
//  Created by GeekNavi on 7/17/16.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface GeekDestinationPin : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign) NSString *locationType;

- (id)initWithLocation:(CLLocationCoordinate2D)coord;
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;


@end
