//
//  StatsViewController.m
//  ObjectiveTrainerApp
//
//  Created by Christopher Ching on 2014-03-29.
//  Copyright (c) 2014 CodeWithChris. All rights reserved.
//

#import "StatsViewController.h"
#import "SWRevealViewController.h"

@interface StatsViewController ()

@end

@implementation StatsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    //Load and display stats
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    //Easy Stats
    int easyQuestionsAnswered = [userDefaults integerForKey:@"EasyQuestionsAnswered"];
    int easyQuestionsAnsweredCorrectly = [userDefaults integerForKey:@"EasyQuestionsAnsweredCorrectly"];
    self.easyQuestionsStats.text =[NSString stringWithFormat:@"Easy Questions %i / %i", easyQuestionsAnsweredCorrectly, easyQuestionsAnswered];
    
    //Medium Stats
    int mediumQuestionsAnswered = [userDefaults integerForKey:@"MediumQuestionsAnswered"];
    int mediumQuestionsAnsweredCorrectly = [userDefaults integerForKey:@"MediumQuestionsAnsweredCorrectly"];
    self.mediumQuestionsStats.text =[NSString stringWithFormat:@"Medium Questions %i / %i", mediumQuestionsAnsweredCorrectly, mediumQuestionsAnswered];
    
    //Hard Stats
    int hardQuestionsAnswered = [userDefaults integerForKey:@"HardQuestionsAnswered"];
    int hardQuestionsAnsweredCorrectly = [userDefaults integerForKey:@"HardQuestionsAnsweredCorrectly"];
    self.hardQuestionsStats.text =[NSString stringWithFormat:@"Hard Questions %i / %i", hardQuestionsAnsweredCorrectly, hardQuestionsAnswered];
    
    //Total Stats
    self.totalQuestionsLabel.text = [NSString stringWithFormat:@"Total Questions Answered: %i", easyQuestionsAnswered + mediumQuestionsAnswered + hardQuestionsAnswered];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
