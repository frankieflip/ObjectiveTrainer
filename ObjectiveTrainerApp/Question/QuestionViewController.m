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
    
    ResultView *_resultView;
    UIView *_dimmedBackground;
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
    _scrollViewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTapped)];
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
    
    //Add background behind status bar
    UIView *statusBarBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    statusBarBg.backgroundColor = [UIColor colorWithRed:11/255.0 green:187/255.0 blue:115/255.0 alpha:1.0];
    [self.view addSubview:statusBarBg];
    
    //Set Button styles
    UIColor *buttonBorderColor = [UIColor colorWithRed:232/255.0 green:232/255.0 blue:232/255.0 alpha:1.0];
    
    [self.questionMCAnswer1.layer setBorderWidth:1.0];
    [self.questionMCAnswer2.layer setBorderWidth:1.0];
    [self.questionMCAnswer3.layer setBorderWidth:1.0];
    [self.questionMCAnswer1.layer setBorderColor:buttonBorderColor.CGColor];
    [self.questionMCAnswer2.layer setBorderColor:buttonBorderColor.CGColor];
    [self.questionMCAnswer3.layer setBorderColor:buttonBorderColor.CGColor];
    
     
    
}

-(void)viewDidAppear:(BOOL)animated
{
    //call super implementation
    [super viewDidAppear:animated];
    
    //Create result view
    _resultView = [[ResultView alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, self.view.frame.size.height - 20)];
    //_resultView = [[ResultView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _resultView.delegate = self;
    
    //Created dimmed bg
    _dimmedBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _dimmedBackground.backgroundColor = [UIColor blackColor];
    _dimmedBackground.alpha = 0.3;
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

- (IBAction)menuButtonTapped:(id)sender
{
    [self.revealViewController revealToggleAnimated:YES];
    
}

- (void)displayImageQuestion
{
    //Hide all elements
    [self hideAllQuestionElements];
    
    //Set question elements
    
    //Set Image
    UIImage *tempImage =[UIImage imageNamed:_currentQuestion.questionImageName];
    self.imageQuestionImageView.image = tempImage;
   
    //Resize imageview
    CGRect imageViewFrame = self.imageQuestionImageView.frame;
    imageViewFrame.size.height = tempImage.size.height;
    imageViewFrame.size.width = tempImage.size.width;
    self.imageQuestionImageView.frame = imageViewFrame;
    
    
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
    
    //Set question image for fill in the blank question
    //Set Image
    UIImage *tempImage =[UIImage imageNamed:_currentQuestion.questionImageName];
    self.imageQuestionImageView.image = tempImage;
    
    //resize image view
    CGRect imageViewFrame = self.imageQuestionImageView.frame;
    imageViewFrame.size.height = tempImage.size.height;
    imageViewFrame.size.width = tempImage.size.width;
    self.imageQuestionImageView.frame = imageViewFrame;
    
    
    //Adjust for scrollview
    self.questionScrollView.contentSize = CGSizeMake(self.questionScrollView.frame.size.width, self.skipButton.frame.origin.y + self.skipButton.frame.size.height + 30);
    
    //Revel object for Blank Questions
    self.imageQuestionImageView.hidden = NO;
    self.submitAnswerForBlankButton.hidden = NO;
    self.blankTextField.hidden = NO;
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
    
    NSString *userAnswer = @"";
    switch (selectedButton.tag) {
        case 1:
            userAnswer = _currentQuestion.questionAnswer1;
            break;
        case 2:
            userAnswer = _currentQuestion.questionAnswer2;
            break;
        case 3:
            userAnswer = _currentQuestion.questionAnswer3;
            break;
        default:
            break;
    }
    
    if (selectedButton.tag == _currentQuestion.correctMCQuestionIndex)
    {
        //User got it right
        isCorrect = YES;
    }
    else
    {
        //User got it wrong
    }
    
    
    //display message for correct answer
    [_resultView showResultForTextQuestion:isCorrect userAnswer:userAnswer forQuestion:_currentQuestion];
    [self.view addSubview:_dimmedBackground];
    [self.view addSubview:_resultView];
    
    
    //Save the question data
    [self saveQuestionData:_currentQuestion.questionType withDifficulty:_currentQuestion.questionDifficulty isCorrect:isCorrect];
    
    //Randomize and go to next question
    [self randomizeQuestionForDisplay];
    
}

-(void)imageQuestionAnswered
{
    // display message for correct answer
    [_resultView showResultForImageQuestion:YES forQuestion:_currentQuestion];
    [self.view addSubview:_dimmedBackground];
    [self.view addSubview:_resultView];
    
    
    [self saveQuestionData:_currentQuestion.questionType withDifficulty:_currentQuestion.questionDifficulty isCorrect:YES];
    
    //Randomize and go to next question
    [self randomizeQuestionForDisplay];
}

- (IBAction)blankSubmitted:(id)sender
{
    //Retract keyboard
    [self.blankTextField resignFirstResponder];
    
    //Get answer
    NSString *answer = self.blankTextField.text;
    BOOL isCorrect = NO;
    
    //Check if answer is right
    if ([answer isEqualToString:_currentQuestion.correctAnswerForBlank])
    {
        //User got it right
        isCorrect = YES;
        
        
        
    }
    else
    {
        //User got it wrong
    }
    
    //Clear the text field
    self.blankTextField.text = @"";
    
    //Display messsage for answer
    [_resultView showResultForImageQuestion:YES forQuestion:_currentQuestion];
    [self.view addSubview:_dimmedBackground];
    [self.view addSubview:_resultView];
    
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
    //Retract keyboard
    [self.blankTextField resignFirstResponder];
}

#pragma mark Result View Delegate Methods

-(void)resultViewDismissed
{
    [_dimmedBackground removeFromSuperview];
    [_resultView removeFromSuperview];
}

@end
