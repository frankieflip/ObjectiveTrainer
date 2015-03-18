//
//  ResultView.h
//  ObjectiveTrainerApp
//
//  Created by Frank on 12/03/2015.
//  Copyright (c) 2015 CodeWithChris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Question.h"

@protocol ResultViewProtocol <NSObject>

- (void)resultViewDismissed;

@end

@interface ResultView : UIView

@property (nonatomic, weak) id<ResultViewProtocol> delegate;

//Label to display correct or incorrect
@property (nonatomic,strong) UILabel *resultLabel;

//Label to display correct answer for text based questions
@property (nonatomic,strong) UILabel *correctAnswerLabel;

//Label to display user answer
@property (nonatomic,strong) UILabel *userAnswerLabel;

//Imageview to display the correct answer for image for image based questions
@property (nonatomic, strong) UIImageView *correctAnswerImageView;

//Button to continue
@property (nonatomic,strong) UIButton *continueButton;

//Make method public needs to know about Question Class blank and mc questions
- (void)showResultForTextQuestion:(BOOL)wasCorrect userAnswer:(NSString*)useranswer forQuestion:(Question*)question;

//Make method public needs to know about Question Class for image Question
- (void)showResultForImageQuestion:(BOOL)wasCorrect forQuestion:(Question*)question;

@end
