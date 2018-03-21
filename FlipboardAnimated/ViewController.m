//
//  ViewController.m
//  FlipboardAnimated
//
//  Created by 贺超 on 2018/3/20.
//  Copyright © 2018年 贺超. All rights reserved.
//

#import "ViewController.h"
#import <FLAnimatedImage/FLAnimatedImage.h>
#import <Masonry/Masonry.h>

#import <SAMKeychain/SAMKeychain.h>

@interface ViewController ()

@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIView *contentView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"didload");
    
//    self.view.backgroundColor = [UIColor lightGrayColor];
    
    FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://img.soogif.com/gpOcXPcY6CWmdkoXXe5ruLTKESRxqTk4.gif_s400x0"]]];
    FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
    imageView.backgroundColor = [UIColor yellowColor];
    imageView.animatedImage = image;
    imageView.frame = CGRectMake(0.0, 0.0, 300.0, 300.0);
    [self.view addSubview:imageView];
    
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(40, 40, 100, 20);
    label.text = @"www.helloworld.com";
    label.textColor = [UIColor blackColor];
    [imageView addSubview:label];

    
    
    [self crateScrollView];
}

- (void)crateScrollView {
    
    UIScrollView *scrollView = UIScrollView.new;
    self.scrollView = scrollView;
    scrollView.backgroundColor = [UIColor brownColor];
    [self.view addSubview:scrollView];
    
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view);
        make.bottom.mas_equalTo(-100);
        make.right.mas_equalTo(self.view);
        make.height.mas_equalTo(100);
    }];
    
    
    UIView *contentView = UIView.new;
    [self.scrollView addSubview:contentView];
    
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.scrollView);
        make.height.mas_equalTo(self.scrollView);
//        make.right.mas_equalTo(self.scrollView).offset(-500);
    }];
    
    UIView *lastView;
    CGFloat width = 25;
    
    for (int i = 0; i < 10; i++) {
        UIView *view = UIView.new;
        view.backgroundColor = [self randomColor];
        [contentView addSubview:view];
        
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(lastView ? lastView.mas_right : @0);
            make.top.mas_equalTo(@0);
            make.height.mas_equalTo(contentView.mas_height);
            make.width.mas_equalTo(@(width));
        }];
        
        width += 25;
        lastView = view;
    }
    
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(lastView.mas_right);
    }];
    
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (UIColor *)randomColor {
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}




#pragma mark Keychain



- (IBAction)saveKeyChain:(id)sender {
    NSLog(@"%d",[SAMKeychain setPassword:@"123456" forService:@"com.kapbook" account:@"lisi"]);
//    [SAMKeychain setPassword:@"1234" forService:@"com.kapbook" account:@"lisi"];
}
- (IBAction)readKeyChain:(id)sender {
    
    NSLog(@"%@",[SAMKeychain passwordForService:@"com.kapbook" account:@"lisi"]);
//    [SAMKeychain passwordForService:@"com.kapbook" account:@"lisi"];
}
- (IBAction)deleteKeyChain:(id)sender {
    NSLog(@"%d",[SAMKeychain deletePasswordForService:@"com.kapbook" account:@"lisi"]);
//    [SAMKeychain deletePasswordForService:@"com.kapbook" account:@"lisi"];
}








@end
