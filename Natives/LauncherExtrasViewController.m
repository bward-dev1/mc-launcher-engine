#import "LauncherExtrasViewController.h"
#import "LauncherPreferences.h"
#import "utils.h"
#import <objc/runtime.h>
#import <sys/sysctl.h>
#include <stdlib.h>

@interface LauncherExtrasViewController ()
@property(nonatomic) UISegmentedControl *seg;
@property(nonatomic) UIScrollView *cheatsView;
@property(nonatomic) UIScrollView *shieldView;
@property(nonatomic) UIScrollView *doctorView;
@property(nonatomic) UIStackView *doctorResults;
@end

@implementation LauncherExtrasViewController

static UIColor *kGrass(void){ return [UIColor colorWithRed:0.498 green:0.698 blue:0.220 alpha:1.0]; }
static UIColor *kEmerald(void){ return [UIColor colorWithRed:0.239 green:0.863 blue:0.518 alpha:1.0]; }
static UIColor *kBG(void){ return [UIColor colorWithRed:0.055 green:0.067 blue:0.031 alpha:1.0]; }

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Extras";
    self.view.backgroundColor = kBG();
    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                      target:self action:@selector(done)];

    self.seg = [[UISegmentedControl alloc] initWithItems:@[@"⚡ Cheats", @"🛡 Shield", @"🩺 Doctor"]];
    self.seg.selectedSegmentIndex = 0;
    self.seg.selectedSegmentTintColor = kGrass();
    self.seg.translatesAutoresizingMaskIntoConstraints = NO;
    [self.seg addTarget:self action:@selector(switchTab) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.seg];

    self.cheatsView = [self buildCheats];
    self.shieldView = [self buildShield];
    self.doctorView = [self buildDoctor];
    self.shieldView.hidden = YES;
    self.doctorView.hidden = YES;
    for (UIScrollView *sv in @[self.cheatsView, self.shieldView, self.doctorView]) {
        sv.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:sv];
    }
    UILayoutGuide *g = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.seg.topAnchor constraintEqualToAnchor:g.topAnchor constant:12],
        [self.seg.leadingAnchor constraintEqualToAnchor:g.leadingAnchor constant:16],
        [self.seg.trailingAnchor constraintEqualToAnchor:g.trailingAnchor constant:-16],
    ]];
    for (UIScrollView *sv in @[self.cheatsView, self.shieldView, self.doctorView]) {
        [NSLayoutConstraint activateConstraints:@[
            [sv.topAnchor constraintEqualToAnchor:self.seg.bottomAnchor constant:12],
            [sv.leadingAnchor constraintEqualToAnchor:g.leadingAnchor],
            [sv.trailingAnchor constraintEqualToAnchor:g.trailingAnchor],
            [sv.bottomAnchor constraintEqualToAnchor:g.bottomAnchor],
        ]];
    }
}

- (void)done { [self dismissViewControllerAnimated:YES completion:nil]; }
- (void)switchTab {
    NSInteger i = self.seg.selectedSegmentIndex;
    self.cheatsView.hidden = (i != 0);
    self.shieldView.hidden = (i != 1);
    self.doctorView.hidden = (i != 2);
}

#pragma mark - Cheats

- (UIScrollView *)buildCheats {
    UIScrollView *sv = [UIScrollView new];
    UIStackView *stack = [self vstack];
    [sv addSubview:stack];
    [self pin:stack in:sv];

    NSArray *groups = @[
        @[@"Game Mode", @[@[@"Creative",@"/gamemode creative"], @[@"Survival",@"/gamemode survival"], @[@"Spectator",@"/gamemode spectator"]]],
        @[@"Time & Weather", @[@[@"Day",@"/time set day"], @[@"Night",@"/time set night"], @[@"Clear",@"/weather clear"], @[@"Rain",@"/weather rain"]]],
        @[@"Give", @[@[@"Diamonds x64",@"/give @s minecraft:diamond 64"], @[@"Netherite Sword",@"/give @s minecraft:netherite_sword"], @[@"Elytra",@"/give @s minecraft:elytra"], @[@"Totem",@"/give @s minecraft:totem_of_undying"]]],
        @[@"Effects", @[@[@"Night Vision",@"/effect give @s night_vision 99999 1 true"], @[@"Strength II",@"/effect give @s strength 600 1"], @[@"Heal",@"/effect give @s instant_health 1 4"]]],
        @[@"World", @[@[@"Keep Inventory",@"/gamerule keepInventory true"], @[@"No Mob Griefing",@"/gamerule mobGriefing false"], @[@"Always Day",@"/gamerule doDaylightCycle false"]]],
    ];
    [stack addArrangedSubview:[self caption:@"Official single-player commands. Tap to copy → paste in chat (cheats-enabled worlds)."]];
    for (NSArray *grp in groups) {
        [stack addArrangedSubview:[self header:grp[0]]];
        for (NSArray *cmd in grp[1]) {
            [stack addArrangedSubview:[self cmdButton:cmd[0] command:cmd[1]]];
        }
    }
    return sv;
}

- (UIButton *)cmdButton:(NSString *)label command:(NSString *)cmd {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    [b setTitle:[NSString stringWithFormat:@"  %@", label] forState:UIControlStateNormal];
    [b setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    b.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    b.backgroundColor = [UIColor colorWithWhite:1 alpha:0.06];
    b.layer.cornerRadius = 10;
    b.layer.borderWidth = 1; b.layer.borderColor = [kGrass() colorWithAlphaComponent:0.4].CGColor;
    [b.heightAnchor constraintEqualToConstant:46].active = YES;
    objc_setAssociatedObject(b, "cmd", cmd, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [b addTarget:self action:@selector(copyCmd:) forControlEvents:UIControlEventPrimaryActionTriggered];
    return b;
}

- (void)copyCmd:(UIButton *)sender {
    NSString *cmd = objc_getAssociatedObject(sender, "cmd");
    UIPasteboard.generalPasteboard.string = cmd;
    [self toast:[NSString stringWithFormat:@"Copied: %@", cmd]];
}

#pragma mark - Shield

- (UIScrollView *)buildShield {
    UIScrollView *sv = [UIScrollView new];
    UIStackView *stack = [self vstack];
    [sv addSubview:stack];
    [self pin:stack in:sv];
    [stack addArrangedSubview:[self caption:@"Optional protection from mean people, griefing, and explicit content. Saved to your device."]];
    [stack addArrangedSubview:[self header:@"Chat protection"]];
    [stack addArrangedSubview:[self toggleRow:@"Filter profanity" key:@"shield.filterProfanity"]];
    [stack addArrangedSubview:[self toggleRow:@"Hide mean / bullying messages" key:@"shield.hideMean"]];
    [stack addArrangedSubview:[self toggleRow:@"Filter explicit content" key:@"shield.filterExplicit"]];
    [stack addArrangedSubview:[self header:@"Build protection"]];
    [stack addArrangedSubview:[self toggleRow:@"Anti-grief in your worlds" key:@"shield.antiGrief"]];
    [stack addArrangedSubview:[self caption:@"Tip: install a chat-filter mod (e.g. AdvancedChatFilters) from the Mods screen to enforce filtering in-game."]];
    return sv;
}

- (UIView *)toggleRow:(NSString *)label key:(NSString *)key {
    UIView *row = [UIView new];
    UILabel *l = [UILabel new]; l.text = label; l.textColor = UIColor.whiteColor;
    l.translatesAutoresizingMaskIntoConstraints = NO;
    UISwitch *sw = [UISwitch new]; sw.onTintColor = kGrass();
    sw.on = [NSUserDefaults.standardUserDefaults boolForKey:key];
    sw.translatesAutoresizingMaskIntoConstraints = NO;
    objc_setAssociatedObject(sw, "key", key, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [sw addTarget:self action:@selector(toggleChanged:) forControlEvents:UIControlEventValueChanged];
    [row addSubview:l]; [row addSubview:sw];
    [NSLayoutConstraint activateConstraints:@[
        [l.leadingAnchor constraintEqualToAnchor:row.leadingAnchor],
        [l.centerYAnchor constraintEqualToAnchor:row.centerYAnchor],
        [sw.trailingAnchor constraintEqualToAnchor:row.trailingAnchor],
        [sw.centerYAnchor constraintEqualToAnchor:row.centerYAnchor],
        [row.heightAnchor constraintEqualToConstant:44],
    ]];
    return row;
}

- (void)toggleChanged:(UISwitch *)sw {
    NSString *key = objc_getAssociatedObject(sw, "key");
    [NSUserDefaults.standardUserDefaults setBool:sw.on forKey:key];
}

#pragma mark - Doctor + Auto-Tune

- (UIScrollView *)buildDoctor {
    UIScrollView *sv = [UIScrollView new];
    UIStackView *stack = [self vstack];
    [sv addSubview:stack];
    [self pin:stack in:sv];

    [stack addArrangedSubview:[self caption:@"Emerald tunes itself to your iPad and diagnoses problems. Everything runs on-device — nothing is uploaded."]];

    [stack addArrangedSubview:[self header:@"Auto-Tune"]];
    [stack addArrangedSubview:[self caption:[self deviceSummary]]];
    [stack addArrangedSubview:[self actionButton:@"⚡ Optimize for my iPad" action:@selector(runAutoTune)]];

    [stack addArrangedSubview:[self header:@"Doctor"]];
    [stack addArrangedSubview:[self caption:@"Scans your last session's log for known problems and offers one-tap fixes."]];
    [stack addArrangedSubview:[self actionButton:@"🩺 Diagnose last session" action:@selector(runDoctor)]];

    self.doctorResults = [UIStackView new];
    self.doctorResults.axis = UILayoutConstraintAxisVertical;
    self.doctorResults.spacing = 8;
    [stack addArrangedSubview:self.doctorResults];

    return sv;
}

// Device fingerprint -> recommended settings. RAM is the most reliable tier signal
// on iOS (no extra frameworks needed): 2GB=A9/A10-class, 3-4GB=A11/A12, 6GB+=A12X/Z & up.
- (NSDictionary *)deviceProfile {
    int ramMB = (int)(NSProcessInfo.processInfo.physicalMemory >> 20);
    char m[256]; size_t l = sizeof(m); NSString *machine = @"iPad";
    if (sysctlbyname("hw.machine", m, &l, NULL, 0) == 0) machine = @(m);
    NSString *tier, *renderer; int resolution;
    if (ramMB >= 3500)      { tier = @"High";   renderer = @"auto";              resolution = 100; }
    else if (ramMB >= 2800) { tier = @"Medium"; renderer = @"auto";              resolution = 85;  }
    else                    { tier = @"Low";    renderer = @ RENDERER_NAME_GL4ES; resolution = 65;  }
    int alloc = (int)(ramMB * 0.35);
    if (alloc < 512)  alloc = 512;
    if (alloc > 3500) alloc = 3500;
    int fps = (int)UIScreen.mainScreen.maximumFramesPerSecond;
    if (fps < 60) fps = 60;
    return @{@"ramMB":@(ramMB), @"machine":machine, @"tier":tier, @"renderer":renderer,
             @"resolution":@(resolution), @"alloc":@(alloc), @"fps":@(fps)};
}

- (NSString *)deviceSummary {
    NSDictionary *d = [self deviceProfile];
    NSString *rname = [d[@"renderer"] isEqual:@"auto"] ? @"Auto (Smart → Zink)" : @"GL4ES";
    return [NSString stringWithFormat:
        @"Detected: %@ · %d MB RAM · %@ tier.\nWill set: %@ · %d%% resolution · %d MB RAM · %d FPS cap.",
        d[@"machine"], [d[@"ramMB"] intValue], d[@"tier"], rname,
        [d[@"resolution"] intValue], [d[@"alloc"] intValue], [d[@"fps"] intValue]];
}

- (void)runAutoTune {
    NSDictionary *d = [self deviceProfile];
    setPrefObject(@"video.renderer", d[@"renderer"]);
    setPrefInt(@"video.resolution", [d[@"resolution"] intValue]);
    setPrefInt(@"video.max_framerate", [d[@"fps"] intValue]);
    setPrefBool(@"java.auto_ram", NO);
    setPrefInt(@"java.allocated_memory", [d[@"alloc"] intValue]);
    [self toast:@"✓ Optimized for your iPad — restart Minecraft"];
}

- (void)runDoctor {
    for (UIView *v in self.doctorResults.arrangedSubviews.copy) { [v removeFromSuperview]; }
    NSString *path = [NSString stringWithFormat:@"%s/latestlog.txt", getenv("POJAV_HOME")];
    NSString *log = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (log.length == 0) {
        [self.doctorResults addArrangedSubview:[self resultCardTitle:@"ℹ️ No log yet"
            detail:@"Launch a world once, then come back and run Doctor." fixKey:nil fixValue:nil]];
        return;
    }
    NSArray *issues = [self diagnose:log];
    if (issues.count == 0) {
        [self.doctorResults addArrangedSubview:[self resultCardTitle:@"✅ No known problems found"
            detail:@"Your last session's log looks clean. If something still seems off, try Auto-Tune or switch the renderer to Zink."
            fixKey:nil fixValue:nil]];
        return;
    }
    for (NSDictionary *it in issues) {
        id fk = it[@"fixKey"], fv = it[@"fixValue"];
        [self.doctorResults addArrangedSubview:[self resultCardTitle:it[@"title"] detail:it[@"detail"]
            fixKey:(fk == [NSNull null] ? nil : fk) fixValue:(fv == [NSNull null] ? nil : fv)]];
    }
}

// Pattern-match the log against known failure signatures. Each match becomes a card,
// optionally carrying a one-tap pref fix. Output is a clean structured list — an
// on-device SLM can later consume the same digest for novel errors.
- (NSArray *)diagnose:(NSString *)log {
    NSMutableArray *out = [NSMutableArray new];
    BOOL (^has)(NSString *) = ^BOOL(NSString *pat){
        return [log rangeOfString:pat options:NSRegularExpressionSearch|NSCaseInsensitiveSearch].location != NSNotFound;
    };
    if (has(@"Failed to create.*context") || has(@"GLFW error") || has(@"EGL_BAD") ||
        has(@"libmobileglues") || has(@"Couldn't create.*GL") || has(@"No OpenGL context") ||
        has(@"Pixel format") || has(@"shader.*(fail|error)")) {
        [out addObject:@{@"title":@"🟥 Black screen / renderer failure",
            @"detail":@"The 3D world couldn't render — almost always the wrong renderer for your Minecraft version. Zink (Vulkan) is the most compatible for 1.17+.",
            @"fixKey":@"video.renderer", @"fixValue":@ RENDERER_NAME_VK_ZINK}];
    }
    if (has(@"OutOfMemoryError") || has(@"Out of memory") || has(@"Could not allocate") ||
        has(@"Native memory allocation")) {
        [out addObject:@{@"title":@"🟧 Ran out of memory",
            @"detail":@"Minecraft needed more RAM than was free. Lowering render resolution cuts GPU memory pressure right away.",
            @"fixKey":@"video.resolution", @"fixValue":@(70)}];
    }
    if (has(@"NOT_FOUND") || has(@"doesn't own") || has(@"does not own") || has(@"Couldn't fetch profile")) {
        [out addObject:@{@"title":@"🟨 Account may not own Java Edition",
            @"detail":@"This Microsoft account has no Minecraft: Java profile. Sign in with the account that owns Java (yours: blwgamerkid).",
            @"fixKey":[NSNull null], @"fixValue":[NSNull null]}];
    }
    if (has(@"missing_runtime") || has(@"JLI lib = NULL") || has(@"no Java runtime")) {
        [out addObject:@{@"title":@"🟨 Java runtime missing",
            @"detail":@"The required Java version isn't installed. Open that version's settings and let Emerald download the matching runtime.",
            @"fixKey":[NSNull null], @"fixValue":[NSNull null]}];
    }
    if (has(@"Incompatible mod set") || has(@"Mixin apply.*failed") || has(@"requires.*Fabric") ||
        has(@"LoaderExceptionModCrash")) {
        [out addObject:@{@"title":@"🟧 A mod failed to load",
            @"detail":@"A mod is incompatible with this Minecraft/Fabric version. Remove the most recently added mod, or match mod versions to the game.",
            @"fixKey":[NSNull null], @"fixValue":[NSNull null]}];
    }
    if (out.count == 0 && (has(@"Exception in thread \"main\"") || has(@"A fatal error") ||
        has(@"SIGSEGV") || has(@"fatal error has been detected"))) {
        [out addObject:@{@"title":@"🟥 Crash detected",
            @"detail":@"Minecraft crashed, but the cause isn't a known pattern. Try Auto-Tune and the Zink renderer; you can share the full log from the in-game log screen.",
            @"fixKey":@"video.renderer", @"fixValue":@ RENDERER_NAME_VK_ZINK}];
    }
    return out;
}

- (UIView *)resultCardTitle:(NSString *)title detail:(NSString *)detail fixKey:(id)fixKey fixValue:(id)fixValue {
    UIStackView *card = [UIStackView new];
    card.axis = UILayoutConstraintAxisVertical; card.spacing = 6;
    card.layoutMargins = UIEdgeInsetsMake(12,12,12,12); card.layoutMarginsRelativeArrangement = YES;
    card.backgroundColor = [UIColor colorWithWhite:1 alpha:0.06];
    card.layer.cornerRadius = 12;
    card.layer.borderWidth = 1; card.layer.borderColor = [kEmerald() colorWithAlphaComponent:0.35].CGColor;
    UILabel *t = [UILabel new]; t.text = title; t.textColor = UIColor.whiteColor;
    t.font = [UIFont boldSystemFontOfSize:15]; t.numberOfLines = 0;
    UILabel *d = [UILabel new]; d.text = detail; d.textColor = [UIColor colorWithWhite:0.78 alpha:1];
    d.font = [UIFont systemFontOfSize:13]; d.numberOfLines = 0;
    [card addArrangedSubview:t]; [card addArrangedSubview:d];
    if (fixKey && fixValue) {
        UIButton *fb = [UIButton buttonWithType:UIButtonTypeSystem];
        [fb setTitle:@"  ✓ Apply fix" forState:UIControlStateNormal];
        [fb setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        fb.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        fb.backgroundColor = kGrass();
        fb.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        fb.layer.cornerRadius = 10;
        [fb.heightAnchor constraintEqualToConstant:40].active = YES;
        objc_setAssociatedObject(fb, "fkey", fixKey, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(fb, "fval", fixValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [fb addTarget:self action:@selector(applyFix:) forControlEvents:UIControlEventPrimaryActionTriggered];
        [card addArrangedSubview:fb];
    }
    return card;
}

- (void)applyFix:(UIButton *)b {
    id key = objc_getAssociatedObject(b, "fkey");
    id val = objc_getAssociatedObject(b, "fval");
    setPrefObject(key, val);
    b.enabled = NO;
    [b setTitle:@"  ✓ Applied — restart the world" forState:UIControlStateNormal];
    [self toast:@"✓ Fix applied"];
}

- (UIButton *)actionButton:(NSString *)label action:(SEL)sel {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    [b setTitle:label forState:UIControlStateNormal];
    [b setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    b.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    b.backgroundColor = kEmerald();
    b.layer.cornerRadius = 14;
    b.layer.shadowColor = kEmerald().CGColor; b.layer.shadowOpacity = 0.5;
    b.layer.shadowRadius = 10; b.layer.shadowOffset = CGSizeZero; b.layer.masksToBounds = NO;
    [b.heightAnchor constraintEqualToConstant:50].active = YES;
    [b addTarget:self action:sel forControlEvents:UIControlEventPrimaryActionTriggered];
    return b;
}

#pragma mark - helpers

- (UIStackView *)vstack {
    UIStackView *s = [UIStackView new];
    s.axis = UILayoutConstraintAxisVertical; s.spacing = 8;
    s.translatesAutoresizingMaskIntoConstraints = NO;
    s.layoutMargins = UIEdgeInsetsMake(16,16,16,16); s.layoutMarginsRelativeArrangement = YES;
    return s;
}
- (void)pin:(UIView *)v in:(UIScrollView *)sv {
    [NSLayoutConstraint activateConstraints:@[
        [v.topAnchor constraintEqualToAnchor:sv.topAnchor],
        [v.bottomAnchor constraintEqualToAnchor:sv.bottomAnchor],
        [v.leadingAnchor constraintEqualToAnchor:sv.leadingAnchor],
        [v.trailingAnchor constraintEqualToAnchor:sv.trailingAnchor],
        [v.widthAnchor constraintEqualToAnchor:sv.widthAnchor],
    ]];
}
- (UILabel *)header:(NSString *)t {
    UILabel *l = [UILabel new]; l.text = t;
    l.textColor = kEmerald(); l.font = [UIFont boldSystemFontOfSize:17];
    return l;
}
- (UILabel *)caption:(NSString *)t {
    UILabel *l = [UILabel new]; l.text = t; l.numberOfLines = 0;
    l.textColor = [UIColor colorWithWhite:0.7 alpha:1]; l.font = [UIFont systemFontOfSize:12];
    return l;
}
- (void)toast:(NSString *)msg {
    UILabel *t = [UILabel new]; t.text = msg; t.textColor = UIColor.blackColor;
    t.backgroundColor = kEmerald(); t.textAlignment = NSTextAlignmentCenter;
    t.font = [UIFont boldSystemFontOfSize:13]; t.layer.cornerRadius = 14; t.clipsToBounds = YES;
    t.translatesAutoresizingMaskIntoConstraints = NO; t.alpha = 0;
    [self.view addSubview:t];
    [NSLayoutConstraint activateConstraints:@[
        [t.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [t.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-24],
        [t.heightAnchor constraintEqualToConstant:34],
        [t.widthAnchor constraintLessThanOrEqualToAnchor:self.view.widthAnchor constant:-32],
        [t.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.view.leadingAnchor constant:16],
        [t.trailingAnchor constraintLessThanOrEqualToAnchor:self.view.trailingAnchor constant:-16],
    ]];
    UIEdgeInsets pad = UIEdgeInsetsMake(0,12,0,12);
    (void)pad;
    [UIView animateWithDuration:0.2 animations:^{ t.alpha = 1; } completion:^(BOOL f){
        [UIView animateWithDuration:0.3 delay:1.2 options:0 animations:^{ t.alpha = 0; }
                         completion:^(BOOL f2){ [t removeFromSuperview]; }];
    }];
}
@end
