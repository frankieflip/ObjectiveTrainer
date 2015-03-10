//
//  QuestionViewController.m
//  ObjectiveTrainerApp
//
//  Created by Christopher Ching on 2014-03-29.
//  Copyright (c) 2014 CodeWithChris. All rights reserved.
//

#import "QuestionViewController.h"
#import "SWRevealViewController.h"

@interface QuestionViewController ()
{
    Question *_currentQuestion;
    
    UIView *_tappablePortionOfImageQuestion;
    UITapGestureRecognizer *_tapRecognizer;
    UITapGestureRecognizer *_scrollViewTapGestureRecognizer;
}
@end

@implementation QuestionViewController

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
    
    //Add tap gesture recognizer to scrollview
    _scrollViewTapGestureRecognizer = [[UIGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTapped)];
    [self.questionScrollView addGestureRecognizer:_scrollViewTapGestureRecognizer];
    
    //Add pan gesture recognizer for menu reveal
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    //Hide Everything
    [self hideAllQuestionElements];
    
    //Create quiz model
    self.model = [[QuestionModel alloc] init];
    
    //Check difficulty level and retrieve questions for desired level
    self.questions = [self.model getQuestions:self.questionDifficulty];
    
    //Display a random question
    [self randomizeQuestionForDisplay];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideAllQuestionElements
{
    self.questionText.hidden = YES;
    self.questionMCAnswer1.hidden = YES;
    self.questionMCAnswer2.hidden = YES;
    self.questionMCAnswer3.hidden = YES;
    self.submitAnswerForBlankButton.hidden = YES;
    self.blankTextField.hidden = YES;
    self.instructionLavelForBlank.hidden = YES;
    self.imageQuestionImageView.hidden= YES;
    
    //Remove the tappable uiview for the image questions
    if (_tappablePortionOfImageQuestion.superview != nil)
    {
        [_tappablePortionOfImageQuestion removeFromSuperview];
    }
}

#pragma mark Question Methods

- (void)displayCurrentQuestion
{
    switch (_currentQuestion.questionType) {
        case QuestionTypeMC:
            [self displayMCQuestion];
            break;
        case QuestionTypeBlank:
            [self displayBlankQuestion];
            break;
        case QuestionTypeImage:
            [self displayImageQuestion];
            break;
        default:
            break;
    }
}

- (void)displayMCQuestion
{
    //Hide all elements
    [self hideAllQuestionElements];
    
    //Set question elements
    self.questionText.text = _currentQuestion.questionText;
    [self.questionMCAnswer1 setTitle:_currentQuestion.questionAnswer1 forState:UIControlStateNormal];
    [self.questionMCAnswer2 setTitle:_currentQuestion.questionAnswer2 forState:UIControlStateNormal];
    [self.questionMCAnswer3 setTitle:_currentQuestion.questionAnswer3 forState:UIControlStateNormal];
    
    //Adjust scrollview
    self.questionScrollView.contentSize = CGSizeMake(self.questionScrollView.frame.size.width, self.skipButton.frame.origin.y + self.skipButton.frame.size.height + 30);
    
    //Reveal objects for MC Questions
    self.questionText.hidden = NO;
    self.questionMCAnswer1.hidden = NO;
    self.questionMCAnswer2.hidden = NO;
    self.questionMCAnswer3.hidden = NO;
}

- (void)displayImageQuestion
{
    //Hide all elements
    [self hideAllQuestionElements];
    
    //Set question elements
    
    //TODO: Set Image
    self.imageQuestionImageView.backgroundColor = [UIColor greenColor];
    
    int tappable_x = self.imageQuestionImageView.frame.origin.x + _currentQuestion.offset_x - 10;
    int tappable_y = self.imageQuestionImageView.frame.origin.y + _currentQuestion.offset_y - 10;
    _tappablePortionOfImageQuestion = [[UIView alloc] initWithFrame:CGRectMake(tappable_x, tappable_y, 20, 20)];
    _tappablePortionOfImageQuestion.backgroundColor = [UIColor redColor];
    
    //Create and attach gesture regonizer
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageQuestionAnswered)];
    [_tappablePortionOfImageQuestion addGestureRecognizer:_tapRecognizer];
    
    //Add tappable part
    [self.questionScrollView addSubview:_tappablePortionOfImageQuestion];
    
    //Reveal question elements
    self.imageQuestionImageView.hidden= NO;
}

- (void)displayBlankQuestion
{
    //Hide all elements
    [self hideAllQuestionElements];
    
    //Set question elements
    self.questionText.text =_currentQuestion.questionText;
    
    //Adjust for scrollview
    self.questionScrollView.contentSize = CGSizeMake(self.questionScrollView.frame.size.width, self.skipButton.frame.origin.y + self.skipButton.frame.size.height + 30);
    
    //Revel object for Blank Questions
    self.questionText.hidden = NO;
    self.submitAnswerForBlankButton.hidden = NO;
    self.blankTextField.hidden = NO;
    self.instructionLavelForBlank.hidden = NO;
}


-(void)randomizeQuestionForDisplay
{
    //Randomize a question
    int randomQuestionIndex = arc4random() % self.questions.count;
    _currentQuestion = self.questions[randomQuestionIndex];
    
    //Display the question
    [self displayCurrentQuestion];
}


#pragma mark Question Answer handlers

-(IBAction)skipButtonClicked:(id)sender
{
    //Randomize and display another question
    [self randomizeQuestionForDisplay];
}

-(IBAction)questionMCAnswer:(id)sender
{
    UIButton *selectedButton = (UIButton *)sender;
    BOOL isCorrect = NO;
    
    if (selectedButton.tag == _currentQuestion.correctMCQuestionIndex)
    {
        //User got it right
        isCorrect = YES;
        
        //TODO: display message for correct answer
    
    }
    else
    {
        //User got it wrong
    }
    
    //Save the question data
    [self saveQuestionData:_currentQuestion.questionType withDifficulty:_currentQuestion.questionDifficulty isCorrect:isCorrect];
    
    //Randomize and go to next question
    [self randomizeQuestionForDisplay];
    
}

-(void)imageQuestionAnswered
{
    //TODO: display message for correct answer
    
    [self saveQuestionData:_currentQuestion.questionType withDifficulty:_currentQuestion.questionDifficulty isCorrect:YES];
    
    //Randomize and go to next question
    [self randomizeQuestionForDisplay];
}

- (IBAction)blankSubmitted:(id)sender
{
    NSString *answer = self.blankTextField.text;
    BOOL isCorrect = NO;
    
    
    if ([answer isEqualToString:_currentQuestion.correctAnswerForBlank]) {
        //User got it right
        isCorrect = YES;
    }
    else
    {
        //User got it wrong
    }

    //Record Question Data
    [self saveQuestionData:_currentQuestion.questionType withDifficulty:_currentQuestion.questionDifficulty isCorrect:isCorrect];
    
    //Randomize and go to next question
    [self randomizeQuestionForDisplay];
}

- (void)saveQuestionData:(QuizQuestionType)type withDifficulty:(QuizQuestionDifficulty)difficulty isCorrect:(BOOL)correct
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    //Saved data based on type
    NSString *keyToSaveForType = @"";
    
    if (type == QuestionTypeBlank)
    {
        keyToSaveForType = @"Blank";
    }
    else if (type == QuestionTypeMC)
    {
        keyToSaveForType = @"MC";
    }
    else if (type == QuestionTypeImage)
    {
        keyToSaveForType = @"Image";
    }
    
    //Record that they answered a question type
    int questionsAnsweredByType = [userDefaults integerForKey:[NSString stringWithFormat:@"%@QuestionsAnswered", keyToSaveForType]];
    questionsAnsweredByType++;
    [userDefaults setInteger:questionsAnsweredByType forKey:[NSString stringWithFormat:@"%@QuestionsAnswered", keyToSaveForType]];
    
    //Record that they answered a question type
    int imageQuestionsAnsweredCorrectlyByType = [userDefaults integerForKey:[NSString stringWithFormat:@"%@QuestionsAnsweredCorrectly", keyToSaveForType]];
    imageQuestionsAnsweredCorrectlyByType++;
    [userDefaults setInteger:imageQuestionsAnsweredCorrectlyByType forKey:[NSString stringWithFormat:@"%@QuestionsAnsweredCorrectly", keyToSaveForType]];
    
    
    //Save data based on Difficulty
    NSString *keyToSaveForDifficulty = @"";
    
    if (difficulty == QuestionDifficultyEasy)
    {
        keyToSaveForDifficulty = @"Easy";
    }
    else if (difficulty == QuestionDifficultyMedium)
    {
        keyToSaveForDifficulty = @"Medium";
    }
    else if (difficulty == QuestionDifficultyHard)
    {
        keyToSaveForDifficulty = @"Hard";
        
    }
    
    
    int questionAnsweredWithDifficulty = [userDefaults integerForKey:[NSString stringWithFormat:@"%@QuestionsAnswered", keyToSaveForDifficulty]];
    questionAnsweredWithDifficulty++;
    [userDefaults setInteger:questionAnsweredWithDifficulty forKey:[NSString stringWithFormat:@"%@QuestionsAnswered", keyToSaveForDifficulty]];
    
    if (correct)
    {
        int questionAnsweredCorrectlyWithDifficulty = [userDefaults integerForKey:[NSString stringWithFormat:@"%@QuestionsAnsweredCorrectly", keyToSaveForDifficulty]];
        questionAnsweredCorrectlyWithDifficulty++;
        [userDefaults setInteger:questionAnsweredCorrectlyWithDifficulty forKey:[NSString stringWithFormat:@"%@QuestionsAnsweredCorrectly", keyToSaveForDifficulty]];
    }
    
    
    //Update UserDefaults stored in system
    [userDefaults synchronize];
}


- (void)scrollViewTapped
{
    [self.blankTextField resignFirstResponder];
}

@end
