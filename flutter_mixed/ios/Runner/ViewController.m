//
//  ViewController.m
//  flutterMixed
//
//  Created by 王珏 on 2018/10/9.
//  Copyright © 2018年 王珏. All rights reserved.
//

#import "ViewController.h"
#import <Flutter/Flutter.h>

@interface ViewController ()<FlutterStreamHandler>
@property (weak, nonatomic) IBOutlet UIButton *methodChannelButton;
@property (weak, nonatomic) IBOutlet UIButton *eventChannelButton;
@property (nonatomic, strong) FlutterViewController *flutterVC;
@property (nonatomic, strong) FlutterMethodChannel *methodChannel;

@property (nonatomic, strong) FlutterEventChannel *eventChannel;
@property (nonatomic, strong) FlutterEventSink eventSink;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 粗略设置一下导航栏的风格
    self.navigationController.navigationBar.barTintColor = UIColor.redColor;
    self.navigationItem.title = @"iOS Native Home";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:18],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    self.flutterVC = [[FlutterViewController alloc] initWithProject:nil nibName:nil bundle:nil];
    
    [self setupMethodChannel];
    [self setupEventChannel];
}

- (void)viewWillAppear:(BOOL)animated
{
    // 这里是为了显示导航栏，flutter页面的时候隐藏了
    [self.navigationController setNavigationBarHidden:NO];
}


/**
 配置方法通道，flutter需要使用native的方法
 */
- (void)setupMethodChannel
{
    [self.methodChannelButton setTitle:@"1. Method Channel: Flutter -> iOS" forState:UIControlStateNormal];
    [self.methodChannelButton addTarget:self action:@selector(switchToFlutter) forControlEvents:UIControlEventTouchUpInside];
    
    self.methodChannel = [FlutterMethodChannel methodChannelWithName:@"samples.flutter.io/battery" binaryMessenger:self.flutterVC];
    
    __weak typeof(self) weakSelf = self;
    [self.methodChannel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
        if ([call.method isEqualToString:@"getBatteryLevel"]) {
            // flutter从native里面调用电池信息
            int batteryLevel = [weakSelf batteryLevel];
            if (batteryLevel == -1) {
                result([FlutterError errorWithCode:@"UNAVAILABLE" message:@"Can't get battery level information" details:nil]);
            } else {
                result(@(batteryLevel));
            }
        } else if ([call.method isEqualToString:@"informNavigatorPopFlutter"]) {
            // flutter请求native把自己pop掉
            [weakSelf popToNative];
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];
}


/**
 配置事件通道，native需要主动发送事件给flutter
 */
- (void)setupEventChannel
{
    [self.eventChannelButton setTitle:@"2. Event Channel: iOS -> Flutter" forState:UIControlStateNormal];
    [self.eventChannelButton addTarget:self action:@selector(popUpInputField) forControlEvents:UIControlEventTouchUpInside];
    // To do: add target
    self.eventChannel = [FlutterEventChannel eventChannelWithName:@"samples.flutter.io/receiver" binaryMessenger:self.flutterVC];
    // iOS主动发送消息给flutter
    [self.eventChannel setStreamHandler:self];
}


/**
 获取电池信息
 
 @return 返回剩余电量的百分比，-1则获取失败
 */
- (int)batteryLevel
{
    UIDevice* device = UIDevice.currentDevice;
    device.batteryMonitoringEnabled = YES;
    if (device.batteryState == UIDeviceBatteryStateUnknown) {
        return -1;
    } else {
        return (int)(device.batteryLevel * 100);
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

# pragma mark - Actions


/**
 跳转到flutter页面
 */
- (void)switchToFlutter
{
    [self.navigationController pushViewController:self.flutterVC animated:YES];
    // flutter vc自己有导航栏，原生的就隐藏了
    [self.navigationController setNavigationBarHidden:YES];
}


/**
 flutter通知native导航栈,需要从flutter返回到native
 */
- (void)popToNative
{
    if ([self.navigationController topViewController] == self.flutterVC) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

/**
 弹出alert,允许用户输入flutter页面的新标题
 */
- (void)popUpInputField
{
    __weak typeof(self) weakSelf = self;
    // 先跳转到flutter页面，保证页面已经加载过了
    [self switchToFlutter];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Change flutter's title"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         // 如果已经开始监听，则可以发送事件
                                                         if (weakSelf.eventSink) {
                                                             weakSelf.eventSink(alert.textFields.firstObject.text);
                                                        }
                                                     }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                         }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Please input flutter view's new title";
    }];
    
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    // 利用导航栏把这个alert置顶，trick的方式让flutter vc弹出原生alert vc
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}

# pragma mark - EventChannel delegate

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    self.eventSink = nil;
    return nil;
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    // 保存eventSink
    self.eventSink = events;
    return nil;
}

@end
