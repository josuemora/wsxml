//
//  ViewController.h
//  wsxml
//
//  Created by Joshua on 28/08/14.
//  Copyright (c) 2014 Joshua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <NSXMLParserDelegate>

@property (strong, nonatomic) IBOutlet UITextField *campo_correo;

@property (strong, nonatomic) IBOutlet UITextField *campo_nombre;

- (IBAction)btn_buscar:(id)sender;

@property (strong, nonatomic) IBOutlet UITextView *txt_raw;

@property (strong, nonatomic) IBOutlet UITextView *txt_finales;



@end
