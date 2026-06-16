#import "SceneDelegate.h"
#import "ios_uikit_bridge.h"
#import "utils.h"

extern UIWindow *mainWindow;

@interface SceneDelegate ()

@end

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
    self.window.frame = windowScene.coordinateSpace.bounds;
    mainWindow = self.window;
    // MC Launcher theme: global Minecraft-green tint + dark mode
    self.window.tintColor = [UIColor colorWithRed:0.498 green:0.698 blue:0.220 alpha:1.0];
    self.window.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
    // Emerald global chrome: dark green-tinted nav bars + toolbars
    UIColor *emeraldDark = [UIColor colorWithRed:0.055 green:0.082 blue:0.047 alpha:1.0];
    UIColor *emeraldText = [UIColor colorWithRed:0.918 green:0.953 blue:0.863 alpha:1.0];
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *navA = [[UINavigationBarAppearance alloc] init];
        [navA configureWithOpaqueBackground];
        navA.backgroundColor = emeraldDark;
        navA.titleTextAttributes = @{NSForegroundColorAttributeName: emeraldText};
        navA.largeTitleTextAttributes = @{NSForegroundColorAttributeName: emeraldText};
        UINavigationBar.appearance.standardAppearance = navA;
        UINavigationBar.appearance.scrollEdgeAppearance = navA;
        UINavigationBar.appearance.compactAppearance = navA;
        UIToolbarAppearance *tbA = [[UIToolbarAppearance alloc] init];
        [tbA configureWithOpaqueBackground];
        tbA.backgroundColor = emeraldDark;
        UIToolbar.appearance.standardAppearance = tbA;
        UIToolbar.appearance.scrollEdgeAppearance = tbA;
        UITableView.appearance.backgroundColor = emeraldDark;
    }
    launchInitialViewController(self.window);
    [self.window makeKeyAndVisible];
}


- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
}


- (void)sceneWillResignActive:(UIScene *)scene {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
    CallbackBridge_pauseGameIfNeed();
}

@end



