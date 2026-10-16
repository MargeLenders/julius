#import "ios.h"

#import "GameDataPickerController.h"
#import "SDL.h"
#import "SDL_messagebox.h"
#import "SDL_system.h"
#import "SDL_syswm.h"
#import "SDL_video.h"

#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

#define GAME_PATH_MAX 300
static int has_directory;
static char path[GAME_PATH_MAX];
static UIWindow *window = nil;
static UIWindow *alertwindow = nil;
static GameDataPickerController *pickerController = nil;

void c3_path_chosen(char *new_path) {
    snprintf(path, GAME_PATH_MAX, "%s", new_path);
    has_directory = 1;
}

const char *ios_get_base_path(void) {
    NSURL *documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *c3Directory = [documentsDirectory URLByAppendingPathComponent:@"C3" isDirectory:YES];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:c3Directory.path]) {
        [c3Directory.path getFileSystemRepresentation:path maxLength:GAME_PATH_MAX];
    } else {
        [documentsDirectory.path getFileSystemRepresentation:path maxLength:GAME_PATH_MAX];
    }
    
    return path;
}

const char *ios_show_c3_path_dialog(int again)
{
    if (window == nil) {
        UIWindowScene *activeScene = nil;
        for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if ([scene isKindOfClass:[UIWindowScene class]] && scene.activationState == UISceneActivationStateForegroundActive) {
                activeScene = (UIWindowScene *)scene;
                break;
            }
        }
        if (!activeScene) {
            for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
                if ([scene isKindOfClass:[UIWindowScene class]]) {
                    activeScene = (UIWindowScene *)scene;
                    break;
                }
            }
        }
        if (activeScene) {
            window = [[UIWindow alloc] initWithWindowScene:activeScene];
        } else {
            window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        }
        window.rootViewController = [UIViewController new];
        window.windowLevel = UIWindowLevelAlert;

        [window makeKeyAndVisible];
    }
    
    pickerController = [[GameDataPickerController alloc] initWithWindow: window];
    [pickerController showInstructions];
    
    while (!has_directory) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:5.0]];
    }

    if (window) {
        window.hidden = YES;
    }
    
    return path;
}

#import <objc/runtime.h>

@interface JuliusSceneDelegate : UIResponder <UIWindowSceneDelegate>
@property (strong, nonatomic) UIWindow *window;
@end

static JuliusSceneDelegate *g_activeSceneDelegate = nil;
static UIWindowScene *g_activeWindowScene = nil;
static UIWindow *g_sdlUIWindow = nil;

@implementation JuliusSceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    if ([scene isKindOfClass:[UIWindowScene class]]) {
        UIWindowScene *windowScene = (UIWindowScene *)scene;
        g_activeWindowScene = windowScene;
        g_activeSceneDelegate = self;
        NSLog(@"[JULIUS] JuliusSceneDelegate willConnectToSession: %@", g_activeWindowScene);

        if (@available(iOS 16.0, *)) {
            UIWindowSceneGeometryPreferencesIOS *preferences = [[UIWindowSceneGeometryPreferencesIOS alloc] initWithInterfaceOrientations:UIInterfaceOrientationMaskLandscape];
            [windowScene requestGeometryUpdateWithPreferences:preferences errorHandler:^(NSError * _Nonnull error) {
                NSLog(@"[JULIUS] Error requesting landscape orientation: %@", error);
            }];
        }

        if (g_sdlUIWindow) {
            NSLog(@"[JULIUS] Attaching saved g_sdlUIWindow %p to windowScene %p", g_sdlUIWindow, g_activeWindowScene);
            g_sdlUIWindow.windowScene = g_activeWindowScene;
            CGRect bounds = g_activeWindowScene.coordinateSpace.bounds;
            if (bounds.size.width < bounds.size.height) {
                CGFloat t = bounds.size.width;
                bounds.size.width = bounds.size.height;
                bounds.size.height = t;
            }
            g_sdlUIWindow.frame = bounds;
            self.window = g_sdlUIWindow;
            [g_sdlUIWindow makeKeyAndVisible];
            if (g_sdlUIWindow.rootViewController) {
                [g_sdlUIWindow.rootViewController setNeedsUpdateOfSupportedInterfaceOrientations];
            }
        }
    }
}

- (void)sceneDidBecomeActive:(UIScene *)scene {
    if ([scene isKindOfClass:[UIWindowScene class]]) {
        UIWindowScene *windowScene = (UIWindowScene *)scene;
        g_activeWindowScene = windowScene;
        g_activeSceneDelegate = self;
        if (@available(iOS 16.0, *)) {
            UIWindowSceneGeometryPreferencesIOS *preferences = [[UIWindowSceneGeometryPreferencesIOS alloc] initWithInterfaceOrientations:UIInterfaceOrientationMaskLandscape];
            [windowScene requestGeometryUpdateWithPreferences:preferences errorHandler:nil];
        }
        if (g_sdlUIWindow) {
            if (g_sdlUIWindow.windowScene == nil) {
                NSLog(@"[JULIUS] sceneDidBecomeActive attaching g_sdlUIWindow %p to windowScene %p", g_sdlUIWindow, g_activeWindowScene);
                g_sdlUIWindow.windowScene = g_activeWindowScene;
            }
            CGRect bounds = g_activeWindowScene.coordinateSpace.bounds;
            if (bounds.size.width < bounds.size.height) {
                CGFloat t = bounds.size.width;
                bounds.size.width = bounds.size.height;
                bounds.size.height = t;
            }
            g_sdlUIWindow.frame = bounds;
            self.window = g_sdlUIWindow;
            [g_sdlUIWindow makeKeyAndVisible];
            if (g_sdlUIWindow.rootViewController) {
                [g_sdlUIWindow.rootViewController setNeedsUpdateOfSupportedInterfaceOrientations];
            }
        }
    }
}

@end

@interface SDLUIKitDelegate : UIResponder <UIApplicationDelegate>
@end

@implementation SDLUIKitDelegate (JuliusSceneSupport)

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    UISceneConfiguration *config = [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
    config.delegateClass = [JuliusSceneDelegate class];
    return config;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskLandscape;
}

@end

static BOOL g_isInSceneInit = NO;

@interface UIWindow (JuliusSceneFix)
@end

@implementation UIWindow (JuliusSceneFix)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [UIWindow class];

        SEL origInitWithFrame = @selector(initWithFrame:);
        SEL swizInitWithFrame = @selector(julius_initWithFrame:);
        Method m1 = class_getInstanceMethod(class, origInitWithFrame);
        Method m2 = class_getInstanceMethod(class, swizInitWithFrame);
        method_exchangeImplementations(m1, m2);

        SEL origMakeKey = @selector(makeKeyAndVisible);
        SEL swizMakeKey = @selector(julius_makeKeyAndVisible);
        Method m3 = class_getInstanceMethod(class, origMakeKey);
        Method m4 = class_getInstanceMethod(class, swizMakeKey);
        method_exchangeImplementations(m3, m4);
    });
}

- (instancetype)julius_initWithFrame:(CGRect)frame {
    if (g_activeWindowScene && !g_isInSceneInit) {
        g_isInSceneInit = YES;
        NSLog(@"[JULIUS] Initializing UIWindow with windowScene for frame: %@", NSStringFromCGRect(frame));
        self = [self initWithWindowScene:g_activeWindowScene];
        g_isInSceneInit = NO;
        if (self) {
            CGRect bounds = g_activeWindowScene.coordinateSpace.bounds;
            if (bounds.size.width > 0 && bounds.size.height > 0) {
                if (bounds.size.width < bounds.size.height) {
                    CGFloat t = bounds.size.width;
                    bounds.size.width = bounds.size.height;
                    bounds.size.height = t;
                }
                self.frame = bounds;
            } else {
                if (frame.size.width < frame.size.height) {
                    CGFloat t = frame.size.width;
                    frame.size.width = frame.size.height;
                    frame.size.height = t;
                }
                self.frame = frame;
            }
        }
        return self;
    }
    if (frame.size.width < frame.size.height) {
        CGFloat t = frame.size.width;
        frame.size.width = frame.size.height;
        frame.size.height = t;
    }
    return [self julius_initWithFrame:frame];
}

- (void)julius_makeKeyAndVisible {
    if (self.windowScene == nil && g_activeWindowScene != nil) {
        NSLog(@"[JULIUS] Attaching windowScene to window in makeKeyAndVisible: %@", self);
        self.windowScene = g_activeWindowScene;
    }
    if (g_activeSceneDelegate && g_activeSceneDelegate.window == nil) {
        g_activeSceneDelegate.window = self;
    }
    [self julius_makeKeyAndVisible];
}

@end

void ios_attach_window_to_scene(SDL_Window *sdlWindow) {
    if (!sdlWindow) return;
    SDL_SysWMinfo wmInfo;
    SDL_VERSION(&wmInfo.version);
    if (SDL_GetWindowWMInfo(sdlWindow, &wmInfo)) {
        UIWindow *uiwin = wmInfo.info.uikit.window;
        if (uiwin) {
            g_sdlUIWindow = uiwin;
            if (!g_activeWindowScene) {
                for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
                    if ([scene isKindOfClass:[UIWindowScene class]]) {
                        g_activeWindowScene = (UIWindowScene *)scene;
                        break;
                    }
                }
            }
            NSLog(@"[JULIUS] ios_attach_window_to_scene: uiwin=%p, scene=%p", uiwin, g_activeWindowScene);
            if (g_activeWindowScene) {
                uiwin.windowScene = g_activeWindowScene;
                CGRect bounds = g_activeWindowScene.coordinateSpace.bounds;
                if (bounds.size.width < bounds.size.height) {
                    CGFloat t = bounds.size.width;
                    bounds.size.width = bounds.size.height;
                    bounds.size.height = t;
                }
                uiwin.frame = bounds;

                if (@available(iOS 16.0, *)) {
                    UIWindowSceneGeometryPreferencesIOS *preferences = [[UIWindowSceneGeometryPreferencesIOS alloc] initWithInterfaceOrientations:UIInterfaceOrientationMaskLandscape];
                    [g_activeWindowScene requestGeometryUpdateWithPreferences:preferences errorHandler:^(NSError * _Nonnull error) {
                        NSLog(@"[JULIUS] ios_attach_window_to_scene geometry error: %@", error);
                    }];
                }
            }
            if (g_activeSceneDelegate) {
                g_activeSceneDelegate.window = uiwin;
            }
            [uiwin makeKeyAndVisible];
            if (uiwin.rootViewController) {
                [uiwin.rootViewController setNeedsUpdateOfSupportedInterfaceOrientations];
                [uiwin.rootViewController.view setNeedsLayout];
                [uiwin.rootViewController.view layoutIfNeeded];
            }
            NSLog(@"[JULIUS] Attached! isKeyWindow=%d, isHidden=%d, bounds=%@", uiwin.isKeyWindow, uiwin.isHidden, NSStringFromCGRect(uiwin.bounds));
        }
    }
}


