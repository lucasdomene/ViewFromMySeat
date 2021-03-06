//
//  FeaturedPhotosStore.m
//  ViewFromMySeat
//
//  Created by Lucas Domene Firmo on 9/23/16.
//  Copyright © 2016 Domene. All rights reserved.
//

#import "FeaturedPhotosStore.h"
#import "ViewFromMySeatAPI.h"
#import "ImageStore.h"

@interface FeaturedPhotosStore()

@property (nonatomic) ImageStore * imageStore;

@end

@implementation FeaturedPhotosStore

#pragma mark - Inits

- (instancetype)init {
    self = [super init];
    if (self) {
        _imageStore = [ImageStore new];
    }
    return self;
}

#pragma mark - Data Fetchers

- (void)fetchFeaturedPhotosInPage:(NSString *)page withCompletion:(void(^)(NSArray * featuredPhotos, NSError * error))completion {
    NSURL * url = [ViewFromMySeatAPI featuredPhotosURLWithPage:page];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    
    [self makeRequest:request withCompletion:^(NSData * data, NSError * error) {
        if (data) {
            NSError * jsonError;
            NSArray * featuredPhotos = [ViewFromMySeatAPI featuredPhotosFromJSONData:data error:&jsonError];
            
            if (!jsonError) {
                completion(featuredPhotos, nil);
            } else {
                completion(nil, [NSError new]);
            }
        } else {
            completion(nil, error);
        }
    }];
}

- (void)fetchImageForFeaturedPhoto:(FeaturedPhoto *)featuredPhoto withCompletion:(void(^)(UIImage * image, NSError * error))completion {
    UIImage * cachedImage = [_imageStore imageForKey:featuredPhoto.featuredPhotoID];
    if (cachedImage) {
        featuredPhoto.image = cachedImage;
        completion(cachedImage, nil);
        return;
    }
    
    NSURL * url = [ViewFromMySeatAPI featuredPhotoImageURLWithImageName:featuredPhoto.imagePath];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    
    [self makeRequest:request withCompletion:^(NSData * data, NSError * error) {
        if (data) {
            UIImage * image = [UIImage imageWithData:data];
            featuredPhoto.image = image;
            [_imageStore cacheImage:image forKey:featuredPhoto.featuredPhotoID];
            completion(image, nil);
        } else {
            completion(nil, error);
        }
    }];
}

#pragma mark - Data Fetchers

- (void)cleanCache {
    [_imageStore cleanCache];
}


@end


