import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'YearFlow';

  @override
  String get welcomeBack => 'Welcome Back!';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'Enter your email address';

  @override
  String get emailRequired => 'Email address is required';

  @override
  String get emailInvalid => 'Please enter a valid email address';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get signIn => 'Sign In';

  @override
  String get or => 'or';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get googleAuthFailed => 'Could not complete Google sign in / sign up.';

  @override
  String get googleAuthCancelled => 'Google sign in was cancelled.';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get signUp => 'Sign Up';

  @override
  String get register => 'Register';

  @override
  String get name => 'Name';

  @override
  String get nameHint => 'Enter your first and last name';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get nameMinLength => 'Name must be at least 2 characters';

  @override
  String get createPassword => 'Create your password';

  @override
  String get welcome => 'Welcome! 🎉';

  @override
  String get signInSuccess => 'Sign in successful! Welcome 👋';

  @override
  String get home => 'Home';

  @override
  String get goals => 'Goals';

  @override
  String get reports => 'Reports';

  @override
  String get settings => 'Settings';

  @override
  String get settingsSubtitle => 'Account and app settings';

  @override
  String get user => 'User';

  @override
  String get skip => 'Skip';

  @override
  String get continueButton => 'Continue';

  @override
  String get getStarted => 'Get Started';

  @override
  String get later => 'Later';

  @override
  String get save => 'Save';

  @override
  String get nameSaved => 'Name saved';

  @override
  String get setYourName => 'Let\'s set your name';

  @override
  String get setYourNameDescription => 'We\'ll address you by your name on screen. You can always change this from your profile if you don\'t want to.';

  @override
  String get yearlyPerformanceSummary => 'Your yearly performance summary';

  @override
  String get downloadReport => 'Download report';

  @override
  String get yourYearlyReport2025 => 'Your 2025 Yearly Report';

  @override
  String get letsTakeOverview => 'Let\'s take an overview of your journey';

  @override
  String get openReport => 'Open Report';

  @override
  String get createReport => 'Create Report';

  @override
  String get greatYear => 'You had a great year 🎉';

  @override
  String get goodProgress => 'You made good progress! 💪';

  @override
  String get continueJourney => 'Continue your journey! 🌱';

  @override
  String errorLoadingData(String error) {
    return 'An error occurred while loading data: $error';
  }

  @override
  String get overview => 'Overview';

  @override
  String get totalGoals => 'Total Goals';

  @override
  String get completionRate => 'Completion Rate';

  @override
  String get checkIn => 'Check-in';

  @override
  String get averageProgress => 'Average Progress';

  @override
  String get yearlyProgress => 'Yearly Progress';

  @override
  String get noCategoryData => 'No category-based data yet';

  @override
  String get categoryBasedDevelopment => 'Category-Based Development';

  @override
  String get noAchievementData => 'Not enough data to create achievement stories yet. You\'ll see your progress here as you add goals and check in.';

  @override
  String get language => 'Language';

  @override
  String get turkish => 'Turkish';

  @override
  String get english => 'English';

  @override
  String yourYearlyReport(int year) {
    return 'Your $year Yearly Report';
  }

  @override
  String get achievements => 'Achievements';

  @override
  String thisYearWorkedOnGoals(int totalGoals, int completedGoals, int completionRate) {
    return 'This year you worked on a total of $totalGoals goals and completed $completedGoals goals (completion rate approximately $completionRate%).';
  }

  @override
  String averageProgressLevel(int progress) {
    return 'Your average progress level across all goals is around $progress%; this shows that you took steps consistently throughout the year.';
  }

  @override
  String strongestProgressInCategory(String category, int value) {
    return 'You showed the strongest progress in the \"$category\" category with approximately $value%';
  }

  @override
  String reachedLevelInCategory(int value, String category) {
    return ', and reached approximately $value% level in the \"$category\" category.';
  }

  @override
  String get aiSuggestions => 'AI Suggestions';

  @override
  String get aiSuggestionExample => 'Your progress in personal development goals is great! Next year, you can increase the completion rate by breaking down large career goals into smaller, manageable steps. Also, adding a goal on financial literacy can support your overall success.';

  @override
  String get loginRequired => 'You need to sign in';

  @override
  String get reportExportedSuccessfully => 'Report exported successfully';

  @override
  String get exportReport => 'Export Report';

  @override
  String get selectFormat => 'Select format:';

  @override
  String get json => 'JSON';

  @override
  String get csv => 'CSV';

  @override
  String get atLeastOneGoalRequired => 'At least one goal is required to create a report';

  @override
  String errorCreatingReport(String error) {
    return 'Error creating report: $error';
  }

  @override
  String get selectReportType => 'Select report type:';

  @override
  String get thisWeekSummary => 'This week\'s summary';

  @override
  String get thisMonthSummary => 'This month\'s summary';

  @override
  String get thisYearSummary => 'This year\'s summary';

  @override
  String get challengesAndSolutions => 'Challenges and solutions:';

  @override
  String challengeLowProgress(String category, int value) {
    return 'Challenge: Progress in \"$category\" category is relatively low (approx. $value%).';
  }

  @override
  String get solutionAddActions => 'Solution: You could try adding 1-2 small, clear actions in this area next week and increasing the frequency of check-ins.';

  @override
  String challengeFocusDifficulty(String category, int value) {
    return 'Challenge: You may be having difficulty focusing on \"$category\" goals (approximately $value%).';
  }

  @override
  String get solutionBreakDownGoals => 'Solution: Breaking these goals into smaller steps and reviewing them weekly can increase focus.';

  @override
  String get generalStatusHealthy => 'General status: There is healthy progress in all categories.';

  @override
  String get solutionReviewPriorities => 'Solution: Still, reviewing your priorities weekly can be a good idea to maintain your motivation.';

  @override
  String get goalAndCheckInDataNeeded => 'As your goal and check-in data grows, areas where you struggle and improvement suggestions will appear here.';

  @override
  String get january => 'January';

  @override
  String get february => 'February';

  @override
  String get march => 'March';

  @override
  String get april => 'April';

  @override
  String get may => 'May';

  @override
  String get june => 'June';

  @override
  String get july => 'July';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'October';

  @override
  String get november => 'November';

  @override
  String get december => 'December';

  @override
  String get active => 'Active';

  @override
  String get completed => 'Completed:';

  @override
  String get myGoals => 'My Goals';

  @override
  String get yourSuccessJourney => 'Your success journey';

  @override
  String get sort => 'Sort';

  @override
  String get filter => 'Filter';

  @override
  String get newest => 'Newest';

  @override
  String get oldest => 'Oldest';

  @override
  String get progressHigh => 'Progress (High)';

  @override
  String get progressLow => 'Progress (Low)';

  @override
  String get titleAsc => 'Title (A-Z)';

  @override
  String get titleDesc => 'Title (Z-A)';

  @override
  String get all => 'All';

  @override
  String get health => 'Health';

  @override
  String get mentalHealth => 'Mental Health';

  @override
  String get finance => 'Finance';

  @override
  String get career => 'Career';

  @override
  String get relationships => 'Relationships';

  @override
  String get learning => 'Learning';

  @override
  String get creativity => 'Creativity';

  @override
  String get hobby => 'Hobby';

  @override
  String get personalGrowth => 'Personal Growth';

  @override
  String get noCompletedGoals => 'No completed goals yet';

  @override
  String get completedGoalsWillAppear => 'Your completed goals will appear here as you complete them';

  @override
  String get goalsLoadingError => 'An error occurred while loading goals.';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get reactivateGoal => 'Reactivate Goal';

  @override
  String reactivateGoalDescription(String goalTitle) {
    return 'Do you want to remove the \"$goalTitle\" goal from completed goals and add it back to the active goals list?';
  }

  @override
  String get moveToActive => 'Move to Active';

  @override
  String get cancel => 'Cancel';

  @override
  String get moveToActiveTooltip => 'Move back to active goals';

  @override
  String get mustSignInToPerformAction => 'You must sign in to perform this action.';

  @override
  String get notificationsComingSoon => 'Notifications coming soon';

  @override
  String get yourGoals => 'Your Goals';

  @override
  String get goodMorning => 'Good Morning';

  @override
  String get hello => 'Hello';

  @override
  String get goodEvening => 'Good Evening';

  @override
  String get weeklySummary => 'Weekly Summary';

  @override
  String thisWeekCheckIns(int checkInCount, int goalsWithProgress) {
    return 'This week you made a total of $checkInCount check-ins and made progress on $goalsWithProgress different goals.';
  }

  @override
  String get weeklySummaryError => 'This week\'s summary could not be loaded right now. Try again later.';

  @override
  String get howIsTodayGoing => 'How is today going?';

  @override
  String get targetDateNotSpecified => 'Target date not specified';

  @override
  String daysOverdue(int days) {
    return '$days days overdue';
  }

  @override
  String get oneDayOverdue => '1 day overdue';

  @override
  String get today => 'Today';

  @override
  String get oneDayLeft => '1 day left';

  @override
  String daysLeft(int days) {
    return '$days days left';
  }

  @override
  String reportsLoadingError(String error) {
    return 'An error occurred while loading reports: $error';
  }

  @override
  String get noReportsYet => 'No reports created yet';

  @override
  String get createFirstReport => 'You can create your first report by clicking the \"Create Report\" button above.';

  @override
  String get pastReports => 'Past Reports';

  @override
  String get goalMovedToActive => 'Goal moved back to active list.';

  @override
  String errorUpdatingGoal(String error) {
    return 'An error occurred while updating goal: $error';
  }

  @override
  String get noCheckInYet => 'No check-in yet';

  @override
  String get yesterday => 'Yesterday';

  @override
  String daysAgo(int days) {
    return '$days days ago';
  }

  @override
  String weeksAgo(int weeks) {
    return '$weeks weeks ago';
  }

  @override
  String get loading => 'Loading...';

  @override
  String lastCheckIn(String date) {
    return 'Last Check-in: $date';
  }

  @override
  String get noGoalsYet => 'You haven\'t added any goals yet';

  @override
  String get startJourneyWithGoal => 'Start your success journey by adding a new goal';

  @override
  String get addNewGoal => 'Add New Goal';

  @override
  String get noGoalCreatedYet => 'You haven\'t created any goals yet';

  @override
  String get createFirstGoal => 'Create your first goal and make your year more planned, focused and meaningful.';

  @override
  String get createGoal => 'Create Goal';

  @override
  String get doCheckIn => 'Do Check-in';

  @override
  String tasksRemaining(int count) {
    return '$count tasks remaining';
  }

  @override
  String checkInCount(int count) {
    return '$count check-in';
  }

  @override
  String reportTypeLabel(String type, String period) {
    return '$type Report - $period';
  }

  @override
  String get onboardingSlide1Title => 'Make your goals concrete this year.';

  @override
  String get onboardingSlide1Description => 'Turn your dreams into reality with YearFlow. Progress towards your big goals with achievable steps.';

  @override
  String get onboardingSlide2Title => 'Track your journey with regular progress.';

  @override
  String get onboardingSlide2Description => 'Record your progress on goals with monthly check-ins, maintain your motivation and celebrate your achievements.';

  @override
  String get onboardingSlide3Title => 'Get your personal development report at the end of the year.';

  @override
  String get onboardingSlide3Description => 'See the progress you\'ve made throughout the year with AI-powered reports, understand your development with concrete data and get inspired for new goals.';

  @override
  String get onboardingWelcomeTitle => 'Make your goals real.';

  @override
  String get onboardingWelcomeSubtitle => 'Turn your dreams into reality, one step at a time.';

  @override
  String get onboardingFeature1Title => 'Track your journey';

  @override
  String get onboardingFeature1Subtitle => 'Monthly check-ins help you stay on track and see how far you\'ve come.';

  @override
  String get onboardingFeature2Title => 'Celebrate every win';

  @override
  String get onboardingFeature2Subtitle => 'Visual progress and milestones keep you motivated along the way.';

  @override
  String get onboardingFeature3Title => 'See your growth with AI-powered reports.';

  @override
  String get onboardingFeature3Subtitle => 'Yearly snapshots & data-driven insights.';

  @override
  String get onboardingEndTitle => 'Ready to start your journey?';

  @override
  String get onboardingEndSubtitle => 'Let\'s turn your goals into achievements.';

  @override
  String get letsStart => 'Let\'s start';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get continueWithGoogleRegister => 'Sign up with Google';

  @override
  String get forgotPasswordTitle => 'Forgot your password?';

  @override
  String get forgotPasswordDescription => 'Enter your registered email address to reset your password.';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get emailAddressHint => 'Your Email Address';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get emailSent => 'Email sent!';

  @override
  String resetLinkSent(String email) {
    return 'Password reset link has been sent to $email.';
  }

  @override
  String get newGoal => 'New Goal';

  @override
  String get editGoal => 'Edit Goal';

  @override
  String get goalCreatedSuccess => 'Goal created successfully! 🎉';

  @override
  String get goalUpdatedSuccess => 'Goal updated! ✅';

  @override
  String get goalOptimizedSuccess => 'Goal optimized! ✨';

  @override
  String get optimizeWithAI => 'Optimize with AI';

  @override
  String get update => 'Update';

  @override
  String get goalNotFound => 'Goal not found';

  @override
  String errorCreatingGoal(String error) {
    return 'An error occurred while creating goal: $error';
  }

  @override
  String get pleaseFillAllFields => 'Please fill in all fields in the form';

  @override
  String get pleaseSelectCategory => 'Please select a category';

  @override
  String get pleaseSelectCompletionDate => 'Please select completion date';

  @override
  String get pleaseExplainWhy => 'Please explain why you want this goal';

  @override
  String get goalCreated => 'Goal Created';

  @override
  String checkInCompleted(int score) {
    return 'Check-in Completed: Score $score/10';
  }

  @override
  String get notSpecified => 'Not specified';

  @override
  String get expired => 'Expired';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String errorLoadingGoal(String error) {
    return 'Error loading goal: $error';
  }

  @override
  String errorLoadingCheckIns(String error) {
    return 'Error loading check-ins: $error';
  }

  @override
  String get checkInSaved => 'Check-in saved! ✅';

  @override
  String get goalCompleted => 'Goal completed! 🎉';

  @override
  String errorCompletingGoal(String error) {
    return 'An error occurred while completing goal: $error';
  }

  @override
  String get completeGoal => 'Complete Goal';

  @override
  String get goalDeletedSuccess => 'Goal deleted successfully';

  @override
  String errorDeletingGoal(String error) {
    return 'An error occurred while deleting goal: $error';
  }

  @override
  String get deleteGoal => 'Delete Goal';

  @override
  String get goalCompletedTitle => 'Goal Completed 🎉';

  @override
  String get progressRecorded => 'Progress Recorded';

  @override
  String nextCheckIn(String date) {
    return 'Next Check-in: $date';
  }

  @override
  String get timeline => 'Timeline';

  @override
  String get notes => 'Notes';

  @override
  String get subTasks => 'Sub Tasks';

  @override
  String get creatingIndex => 'Creating Index';

  @override
  String get errorLoadingNotes => 'Error Loading Notes';

  @override
  String get firestoreIndexNotReady => 'Firestore index is not ready yet. Please wait a few minutes and try again.';

  @override
  String tasksLeft(int count) {
    return '$count tasks left';
  }

  @override
  String get todayCheckIn => 'Today';

  @override
  String get yesterdayCheckIn => 'Yesterday';

  @override
  String daysAgoCheckIn(int days) {
    return '$days days ago';
  }

  @override
  String weeksAgoCheckIn(int weeks) {
    return '$weeks weeks ago';
  }

  @override
  String get reportSummaryThisWeek => 'Summary for this week';

  @override
  String get reportSummaryThisMonth => 'Summary for this month';

  @override
  String get reportSummaryThisYear => 'Summary for this year';

  @override
  String reportErrorLoading(String error) {
    return 'Error loading reports: $error';
  }

  @override
  String get createYourFirstReport => 'You can create your first report by clicking the \"Create Report\" button above.';

  @override
  String get reportTypeWeekly => 'Weekly Report';

  @override
  String get reportTypeMonthly => 'Monthly Report';

  @override
  String get reportTypeYearly => 'Yearly Report';

  @override
  String get solutionIncreaseCheckIns => 'Solution: Try adding 1-2 small, clear actions in this area next week and increase check-in frequency.';

  @override
  String challengeDifficultyFocusing(String category, int value) {
    return 'Challenge: You might be struggling to focus on \"$category\" goals (approx. $value%).';
  }

  @override
  String get generalStatusHealthyProgress => 'General status: Healthy progress in all categories.';

  @override
  String reportTitle(String reportType, String period) {
    return '$reportType Report - $period';
  }

  @override
  String get applicationSettings => 'Application Settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get upcomingCheckIns => 'Upcoming Check-ins';

  @override
  String get noUpcomingCheckIns => 'No upcoming check-ins for this week.';

  @override
  String get allGoalsCompleted => 'All goals completed! 🎉';

  @override
  String get allGoalsCompletedDescription => 'You\'ve completed all your goals for this week. Time to set new ones or enjoy your progress!';

  @override
  String get viewAllGoals => 'View All Goals';

  @override
  String get weeklySummaryTitle => 'Weekly Summary';

  @override
  String get weeklySummaryDescription => 'Your progress for this week';

  @override
  String get weeklySummaryNoData => 'No data for this week yet. Start adding goals and checking in to see your progress!';

  @override
  String get namePromptTitle => 'Let\'s set your name';

  @override
  String get namePromptDescription => 'We\'ll address you by your name on screen. You can always change this from your profile if you don\'t want to.';

  @override
  String get namePromptSave => 'Save';

  @override
  String get namePromptLater => 'Later';

  @override
  String get namePromptNameSaved => 'Name saved';

  @override
  String get profile => 'Profile';

  @override
  String get annualReport => 'Annual Report';

  @override
  String get accountInformation => 'Account Information';

  @override
  String get edit => 'Edit';

  @override
  String get fullName => 'Full Name';

  @override
  String get upcomingCheckInsDescription => 'Do check-ins for goals with less than 7 days remaining';

  @override
  String get questionOfTheDay => 'QUESTION OF THE DAY';

  @override
  String get questionOfTheDayText => 'What was the biggest thing that motivated you to reach your goals today?';

  @override
  String get writeYourAnswer => 'Write Your Answer';

  @override
  String get monthly => 'Monthly';

  @override
  String get weekly => 'Weekly';

  @override
  String get yearly => 'Yearly';

  @override
  String get data => 'Data';

  @override
  String get downloadAllMyData => 'Download all my data';

  @override
  String get restoreFromBackup => 'Restore from backup';

  @override
  String get securityAndSupport => 'Security and Support';

  @override
  String get privacyAndSecurity => 'Privacy & Security';

  @override
  String get logOut => 'Log Out';

  @override
  String get logOutTitle => 'Log Out';

  @override
  String get logOutConfirmation => 'Are you sure you want to log out of your account?';

  @override
  String get restoreFromBackupTitle => 'Restore from Backup';

  @override
  String get restoreFromBackupWarning => 'The backup file you selected will delete all current goal and report data and replace them with the backup data.\n\nThis action cannot be undone. Are you sure you want to continue?';

  @override
  String get yesContinue => 'Yes, continue';

  @override
  String get changePassword => 'Change Password';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get newPasswordRepeat => 'New Password (Repeat)';

  @override
  String get passwordsDoNotMatch => 'New passwords do not match';

  @override
  String get passwordChangedSuccess => 'Password changed successfully';

  @override
  String get wrongPassword => 'Current password is incorrect';

  @override
  String get exportAllData => 'Export All Data';

  @override
  String get exportDataFormatQuestion => 'In which format would you like to save your data?';

  @override
  String get tableCsv => 'Table (CSV)';

  @override
  String get advancedJson => 'Advanced (JSON)';

  @override
  String get enterCurrentPassword => 'Enter your current password';

  @override
  String get enterNewPassword => 'Enter your new password';

  @override
  String get reEnterNewPassword => 'Re-enter your new password';

  @override
  String get passwordsMismatch => 'Passwords do not match';

  @override
  String get backupImportedSuccess => 'Backup imported successfully. You can check by refreshing the Goals screen.';

  @override
  String get exportCompleted => 'Export completed. You can access the files from the Downloads folder.';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get emailCannotBeChanged => 'Email address cannot be changed';

  @override
  String get profileUpdatedSuccess => 'Profile information updated';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountConfirmation => 'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.';

  @override
  String get accountDeletedSuccess => 'Your account has been successfully deleted';

  @override
  String get errorDeletingAccount => 'An error occurred while deleting account';

  @override
  String get goalTitle => 'Goal Title';

  @override
  String get goalTitleHint => 'e.g., Learn a new language';

  @override
  String get goalTitleRequired => 'Please enter a goal title';

  @override
  String get goalTitleMinLength => 'Goal title must be at least 3 characters';

  @override
  String get selectCategory => 'Select Category';

  @override
  String get categoryRequired => 'Please select a category';

  @override
  String get whyThisGoal => 'Why do you want this goal?';

  @override
  String get motivationHint => 'Write your motivation and purpose...';

  @override
  String get motivationRequired => 'Please explain why you want this goal';

  @override
  String get completionDate => 'Completion Date';

  @override
  String get selectDate => 'Select Date';

  @override
  String get dateRequired => 'Please select a completion date';

  @override
  String get categoryExample => 'e.g., Career, Health';

  @override
  String get noteDeleted => 'Note deleted';

  @override
  String get noteAdded => 'Note added';

  @override
  String get pleaseEnterNoteContent => 'Please enter note content';

  @override
  String errorDeletingNote(String error) {
    return 'An error occurred while deleting note: $error';
  }

  @override
  String errorAddingNote(String error) {
    return 'An error occurred while adding note: $error';
  }

  @override
  String get addNote => 'Add Note';

  @override
  String get editNote => 'Edit Note';

  @override
  String get noteContent => 'Note Content';

  @override
  String get noteContentHint => 'Write your note here...';

  @override
  String get monthlyCheckIn => 'Monthly Check-in';

  @override
  String get takeAMomentToReflect => 'Take a moment to reflect';

  @override
  String get howDoYouEvaluateThisMonth => 'How do you evaluate your progress this month?';

  @override
  String get scoreDescription => '1 means very low progress, 10 means excellent progress.';

  @override
  String score(int score) {
    return 'Score: $score / 10';
  }

  @override
  String get saveCheckIn => 'Save Check-in';

  @override
  String errorSavingCheckIn(String error) {
    return 'An error occurred while saving check-in: $error';
  }

  @override
  String get whatDidYouDoThisMonth => 'What did you do for this goal this month?';

  @override
  String get smallStepsCount => 'Small steps count too. A short answer is enough.';

  @override
  String get progressExample => 'e.g., I worked out 3 times a week, read two chapters, practiced vocabulary…';

  @override
  String get whatChallengedYouMost => 'What challenged you most during this process? How did you deal with it?';

  @override
  String get youCanWriteOnlyChallenges => 'You can also write only the part that challenged you.';

  @override
  String get challengeExample => 'e.g., Workload disrupted my routine; I started making weekly plans to get back on track…';

  @override
  String get leaveNoteForFutureSelf => 'Would you like to leave a small note for your future self?';

  @override
  String get noteExample => 'e.g., You\'re doing great. Stay consistent and trust the process.';

  @override
  String get optional => 'Optional';

  @override
  String get note => 'Note:';

  @override
  String get whichGoalForCheckIn => 'Which goal would you like to check in for?';

  @override
  String get selectGoalFromBelow => 'Select a goal from below; we\'ll take you directly to the check-in screen.';

  @override
  String get goalsLoading => 'Loading goals...';

  @override
  String errorLoadingGoals(String error) {
    return 'An error occurred while loading goals: $error';
  }

  @override
  String get noGoalsYetCreateFirst => 'You don\'t have any goals yet. You need to create a goal first.';

  @override
  String get delete => 'Delete';

  @override
  String get complete => 'Complete';

  @override
  String get deleteSubtask => 'Delete Subtask';

  @override
  String get deleteSubtaskConfirmation => 'Are you sure you want to delete this subtask?';

  @override
  String get deleteReport => 'Delete Report';

  @override
  String pageNotFound(String path) {
    return 'Page not found: $path';
  }

  @override
  String get optimizationResultNotFound => 'Optimization result not found';

  @override
  String get createFirstReportInstruction => 'You can create your first report by clicking the \"Create Report\" button above.';

  @override
  String get remove => 'Remove';

  @override
  String get close => 'Close';

  @override
  String get errorEmailAlreadyInUse => 'The email address is already in use by another account.';

  @override
  String get errorWeakPassword => 'The password is too weak. Please choose a stronger password.';

  @override
  String get errorInvalidEmail => 'The email address is invalid. Please enter a valid email address.';

  @override
  String get errorUserNotFound => 'No account found with this email address. Please check your email or sign up.';

  @override
  String get errorWrongPassword => 'The password is incorrect. Please try again.';

  @override
  String get errorInvalidCredential => 'The email or password is incorrect. Please try again.';

  @override
  String get errorWrongCurrentPassword => 'Current password is incorrect. Please try again.';

  @override
  String get errorUserDisabled => 'This account has been disabled. Please contact support.';

  @override
  String get errorTooManyRequests => 'Too many failed login attempts. Please try again later.';

  @override
  String get errorOperationNotAllowed => 'This sign-in method is not currently available. Please try again later.';

  @override
  String get errorNetworkRequestFailed => 'Please check your internet connection.';

  @override
  String get errorRequiresRecentLogin => 'For security reasons, please sign in again.';

  @override
  String get errorSignInFailed => 'Sign in failed. Please check your email and password, then try again.';

  @override
  String get errorSignUpFailed => 'Registration failed. Please try again.';

  @override
  String get errorPasswordResetFailed => 'Password reset failed. Please try again.';

  @override
  String get errorUnexpectedAuth => 'An unexpected error occurred. Please try again.';
}
