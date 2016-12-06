//
//  GeekDriverPin.h
//  GeekNavi
//
//  Created By GeekNavi on 7/19/16.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface GeekDriverPin : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign) NSString *locationType;

- (id)initWithLocation:(CLLocationCoordinate2D)coord;
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;


@end


