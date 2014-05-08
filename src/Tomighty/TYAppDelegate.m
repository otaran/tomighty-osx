//
//  Tomighty - http://www.tomighty.org
//
//  This software is licensed under the Apache License Version 2.0:
//  http://www.apache.org/licenses/LICENSE-2.0.txt
//

#import "TYAppDelegate.h"

#import "TYTomightyProtocol.h"
#import "TYSoundAgent.h"
#import "TYSyntheticEventPublisher.h"
#import "TYUserInterfaceAgent.h"

#import "TYAppUIProtocol.h"
#import "TYEventBusProtocol.h"
#import "TYImageLoader.h"
#import "TYPreferences.h"
#import "TYSoundPlayerProtocol.h"
#import "TYStatusIconProtocol.h"
#import "TYStatusMenuProtocol.h"
#import "TYSystemTimerProtocol.h"
#import "TYTimerProtocol.h"

#import "TYDefaultAppUI.h"
#import "TYDefaultEventBus.h"
#import "TYDefaultSoundPlayer.h"
#import "TYDefaultStatusIcon.h"
#import "TYDefaultSystemTimer.h"
#import "TYDefaultTimer.h"
#import "TYDefaultTomighty.h"
#import "TYUserDefaultsPreferences.h"

#import "TYPreferencesWindowController.h"

@implementation TYAppDelegate
{
    id <TYTomighty> tomighty;
    id <TYPreferences> preferences;
    TYSoundAgent *soundAgent;
    TYSyntheticEventPublisher *syntheticEventPublisher;
    TYUserInterfaceAgent *userInterfaceAgent;
    TYPreferencesWindowController *preferencesWindow;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    TYImageLoader *imageLoader = [[TYImageLoader alloc] init];
    
    id <TYEventBus> eventBus = [[TYDefaultEventBus alloc] init];
    id <TYSystemTimer> systemTimer = [[TYDefaultSystemTimer alloc] init];
    id <TYTimer> timer = [TYDefaultTimer timerWithEventBus:eventBus systemTimer:systemTimer];
    id <TYSoundPlayer> soundPlayer = [[TYDefaultSoundPlayer alloc] init];
    id <TYStatusIcon> statusIcon = [[TYDefaultStatusIcon alloc] initWithMenu:self.statusMenu imageLoader:imageLoader];
    id <TYStatusMenu> statusMenu = self;
    id <TYAppUI> appUi = [[TYDefaultAppUI alloc] initWithStatusMenu:statusMenu statusIcon:statusIcon];
    
    preferences = [[TYUserDefaultsPreferences alloc] initWithEventBus:eventBus];
    soundAgent = [[TYSoundAgent alloc] initWithSoundPlayer:soundPlayer preferences:preferences];
    syntheticEventPublisher = [[TYSyntheticEventPublisher alloc] init];
    userInterfaceAgent = [[TYUserInterfaceAgent alloc] initWithApplicationUI:appUi];
    tomighty = [[TYDefaultTomighty alloc] initWithTimer:timer preferences:preferences eventBus:eventBus];
    
    [syntheticEventPublisher publishSyntheticEventsInResponseToOtherEventsFrom:eventBus];
    [soundAgent playSoundsInResponseToEventsFrom:eventBus];
    [userInterfaceAgent updateAppUiInResponseToEventsFromEventBus:eventBus];
    
    [self prepareMenuItemsUsingImageLoader:imageLoader];
    
    [eventBus publishEventWithType:TYEventTypeApplicationInit data:nil];
}

- (void)prepareMenuItemsUsingImageLoader:(TYImageLoader *)imageLoader
{
    [self.remainingTimeMenuItem setImage:[imageLoader iconNamed:@"icon-clock"]];
    [self.stopTimerMenuItem setImage:[imageLoader iconNamed:@"icon-stop-timer"]];
    [self.startPomodoroMenuItem setImage:[imageLoader iconNamed:@"icon-start-pomodoro"]];
    [self.startShortBreakMenuItem setImage:[imageLoader iconNamed:@"icon-start-short-break"]];
    [self.startLongBreakMenuItem setImage:[imageLoader iconNamed:@"icon-start-long-break"]];
}

- (IBAction)startPomodoro:(id)sender
{
    [tomighty startPomodoro];
}

- (IBAction)startShortBreak:(id)sender
{
    [tomighty startShortBreak];
}

- (IBAction)startLongBreak:(id)sender
{
    [tomighty startLongBreak];
}

- (IBAction)stopTimer:(id)sender
{
    [tomighty stopTimer];
}

- (IBAction)resetPomodoroCount:(id)sender
{
    [tomighty resetPomodoroCount];
}

- (IBAction)showPreferences:(id)sender
{
    if (!preferencesWindow)
    {
        preferencesWindow = [[TYPreferencesWindowController alloc] initWithPreferences:preferences];
    }
    [preferencesWindow showWindow:nil];
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)enableStopTimerItem:(BOOL)enable
{
    [self.stopTimerMenuItem setEnabled:enable];
}

- (void)enableTimerMenuItem:(NSMenuItem *)menuItem enable:(BOOL)enable
{
    [menuItem setEnabled:enable];
    [menuItem setState:enable ? NSOffState : NSOnState];
}

- (void)enableStartPomodoroItem:(BOOL)enable
{
    [self enableTimerMenuItem:self.startPomodoroMenuItem enable:enable];
}

- (void)enableStartShortBreakItem:(BOOL)enable
{
    [self enableTimerMenuItem:self.startShortBreakMenuItem enable:enable];
}

- (void)enableStartLongBreakItem:(BOOL)enable
{
    [self enableTimerMenuItem:self.startLongBreakMenuItem enable:enable];
}

- (void)enableResetPomodoroCountItem:(BOOL)enable
{
    [self.resetPomodoroCountMenuItem setEnabled:enable];
}

- (void)setRemainingTimeText:(NSString *)text
{
    [self.remainingTimeMenuItem setTitle:text];
}

- (void)setPomodoroCountText:(NSString *)text
{
    [self.pomodoroCountMenuItem setTitle:text];
}

@end