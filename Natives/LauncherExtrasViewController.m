#import "LauncherExtrasViewController.h"
#import <objc/runtime.h>

@interface LauncherExtrasViewController ()
@property(nonatomic) UISegmentedControl *seg;
@property(nonatomic) UIScrollView *cheatsView;
@property(nonatomic) UIScrollView *shieldView;
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

    self.seg = [[UISegmentedControl alloc] initWithItems:@[@"⚡ Cheats", @"🛡 Shield"]];
    self.seg.selectedSegmentIndex = 0;
    self.seg.selectedSegmentTintColor = kGrass();
    self.seg.translatesAutoresizingMaskIntoConstraints = NO;
    [self.seg addTarget:self action:@selector(switchTab) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.seg];

    self.cheatsView = [self buildCheats];
    self.shieldView = [self buildShield];
    self.shieldView.hidden = YES;
    for (UIScrollView *sv in @[self.cheatsView, self.shieldView]) {
        sv.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:sv];
    }
    UILayoutGuide *g = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.seg.topAnchor constraintEqualToAnchor:g.topAnchor constant:12],
        [self.seg.leadingAnchor constraintEqualToAnchor:g.leadingAnchor constant:16],
        [self.seg.trailingAnchor constraintEqualToAnchor:g.trailingAnchor constant:-16],
    ]];
    for (UIScrollView *sv in @[self.cheatsView, self.shieldView]) {
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
    BOOL cheats = self.seg.selectedSegmentIndex == 0;
    self.cheatsView.hidden = !cheats;
    self.shieldView.hidden = cheats;
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
