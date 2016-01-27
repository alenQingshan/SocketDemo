//
//  ViewController.m
//  SocketDemo
//
//  Created by apple on 15/12/7.
//  Copyright © 2015年  . All rights reserved.
//

#import "ViewController.h"
#import "AsyncSocket.h"

@interface ViewController () <AsyncSocketDelegate>
{
    AsyncSocket *_sendSocket;
    AsyncSocket *_severSocket;
}

//建立一个数组 用来存放连接
@property (nonatomic,strong) NSMutableArray *socketArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.socketArray = [[NSMutableArray alloc] init];
    
    UIButton *btn = [self createButtonWithFrame:CGRectMake(60, 120, [UIScreen mainScreen].bounds.size.width - 120, 40) title:@"建立连接" target:self action:@selector(monitorClick) color:[UIColor orangeColor]];
    [self.view addSubview:btn];
    
    [self createSendSocket];
}

- (UIButton *)createButtonWithFrame:(CGRect)frame title:(NSString *)title target:(id)target action:(SEL)action color:(UIColor *)color
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:frame];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = color;
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 10;
    return btn;
}

- (void)monitorClick
{
    //连接至服务端,如果已经连接，则先要断开连接
    if (![_sendSocket isConnected]) {
        //先判断是否连接
        //建立连接，
//        [_sendSocket connectToHost:@"192.168.5.39" onPort:5678 withTimeout:30 error:nil];
        [_sendSocket connectToHost:@"www.xinyusoft.com" onPort:8080 error:nil];
    }
    
    //发送消息
    NSData *data = [@"qiaodongliang" dataUsingEncoding:NSUTF8StringEncoding];
    [_sendSocket writeData:data withTimeout:-1 tag:0];
}

- (void)createSendSocket
{
    if (_sendSocket == nil) {
        //客户端
        _sendSocket = [[AsyncSocket alloc] initWithDelegate:self];
    }
    
    if (_severSocket == nil) {
        //服务端
        _severSocket = [[AsyncSocket alloc] initWithDelegate:self];
    }
    
    //监听客户端
    [_severSocket acceptOnPort:8080 error:nil];
    NSLog(@"_sendSocket:%p,_severSocket:%p",_sendSocket,_severSocket);
}

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
    //接收一个新的连接，这个连接需要保存一下，然后一直保持连接
    [self.socketArray addObject:newSocket];
    //等待客户端发送消息 -1表示持续观察
    [newSocket readDataWithTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    //处理接受到的数据
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"message:%@",message);
    //继续监听 客户端 发来的消息，形成循环监听
    [sock readDataWithTimeout:-1 tag:0];
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    //作为服务器的时候,  有人断开连接 ,会调用此方法
    //最为客户端  断开连接服务器的时候 也会调用此方法
    //断开链接的时候,  别人与你断开连接的时候也会调用
    NSLog(@"断开连接");
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    //作为服务器的时候,  有人连接成功 ,会调用此方法
    //作为客户端  连接成功服务器的时候 也会调用此方法
    //连接成功,  这个客户端 和服务端 都会调用这个方法,  别人链接我的时候 链接成功的时候, 会调用此方法,   我主动链接别人的服务端的时候, 如果连接成功  会调用两次这个方法
    NSLog(@"连接成功%@",host);
    NSLog(@"端口号:%d，%p",port,sock);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
