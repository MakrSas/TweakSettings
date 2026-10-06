//
//  TSSceneDelegate.m
//  TweakSettings
//
//  UIScene life cycle (required by UIKit starting with iOS 27)
//

#import <CoreSpotlight/CoreSpotlight.h>
#import "TSSceneDelegate.h"
#import "TSAppDelegate.h"
#import "TSRootListController.h"
#import "TSRootNavigationManager.h"

@implementation TSSceneDelegate

#pragma mark - UISceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {

    if (![scene isKindOfClass:UIWindowScene.class]) return;

    TSAppDelegate *appDelegate = APP_DELEGATE;
    TSRootNavigationManager *navigationManager = appDelegate.navigationManager;

    self.window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
    self.window.rootViewController = (id)navigationManager.splitController;
    appDelegate.window = self.window;
    [self.window makeKeyAndVisible];

    if (connectionOptions.shortcutItem) {

        [appDelegate handleActionForType:connectionOptions.shortcutItem.type];
        return;
    }

    NSURL *launchURL = connectionOptions.URLContexts.allObjects.firstObject.URL;

    if (!launchURL) {

        for (NSUserActivity *activity in connectionOptions.userActivities) {

            launchURL = [self _URLForUserActivity:activity];
            if (launchURL) break;
        }
    }

    if (launchURL) {

        [navigationManager.rootListController setShowOnLoad:NO];
        [navigationManager setDeferredLoadURL:launchURL];
    }
}

- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {

    TSRootNavigationManager *navigationManager = APP_DELEGATE.navigationManager;

    for (UIOpenURLContext *context in URLContexts) {

        if (![context.URL.scheme isEqualToString:@"tweaks"]) continue;

        if (navigationManager.rootListController.rootListLoaded) {

            [navigationManager processURL:context.URL animated:YES];
        } else {

            [navigationManager setDeferredLoadURL:context.URL];
        }

        break;
    }
}

- (void)scene:(UIScene *)scene continueUserActivity:(NSUserActivity *)userActivity {

    NSURL *url = [self _URLForUserActivity:userActivity];

    if (url) {

        [APP_DELEGATE.navigationManager processURL:url animated:NO];
    }
}

#pragma mark - UIWindowSceneDelegate

- (void)windowScene:(UIWindowScene *)windowScene performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {

    [APP_DELEGATE handleActionForType:shortcutItem.type];
    completionHandler(YES);
}

#pragma mark - Private Methods

- (NSURL *)_URLForUserActivity:(NSUserActivity *)activity {

    if (![activity.activityType isEqualToString:CSSearchableItemActionType]) return nil;

    NSString *identifier = activity.userInfo[CSSearchableItemActivityIdentifier];
    return identifier ? [NSURL URLWithString:identifier] : nil;
}

@end
