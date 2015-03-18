//
//  Question.h
//  ObjectiveTrainerApp
//
//  Created by Frank on 7/03/2015.
//  Copyright (c) 2015 CodeWithChris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Question : NSObject

@property (strong, nonatomic) NSString *questionText;

@property (nonatomic) QuizQuestionType questionType;
@property (nonatomic) QuizQuestionDifficulty questionDifficulty;

//Properties for MC=Multiple Choice
@property (strong, nonatomic) NSString *questionAnswer1;
@property (strong, nonatomic) NSString *questionAnswer2;
@property (strong, nonatomic) NSString *questionAnswer3;
@property (nonatomic) int correctMCQuestionIndex;

//Properties for fill in the blank
@property (strong, nonatomic) NSString *correctAnswerForBlank;

//Properties for find within image
@property (nonatomic) int offset_x;
@property (nonatomic) int offset_y;
@property (nonatomic, strong) NSString *questionImageName;
@property (nonatomic, strong) NSString *answerImageName;


@end
