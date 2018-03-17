//
//  KIMFileInfoController.h
//  Self-examination
//
//  Created by milk on 2017/6/29.
//  Copyright © 2017年 milk. All rights reserved.
//

#import "KIMBaseRootController.h"
#import "KIMReadFileModel.h"

@interface KIMFileInfoController : KIMBaseRootController

@property (nonatomic, strong) KIMReadFileModel *directoryModel;
@property (nonatomic, strong) NSURL *url;

@end
