import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'YearFlow'**
  String get appName;

  /// Login page title
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Email field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get emailHint;

  /// Email validation error
  ///
  /// In en, this message translates to:
  /// **'Email address is required'**
  String get emailRequired;

  /// Email format validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get emailInvalid;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Password field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// Password validation error
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// Password minimum length validation error
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// Forgot password link text
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPassword;

  /// Sign in button text
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Separator text between sign in options
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// Google sign in button text
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @googleAuthFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not complete Google sign in / sign up.'**
  String get googleAuthFailed;

  /// No description provided for @googleAuthCancelled.
  ///
  /// In en, this message translates to:
  /// **'Google sign in was cancelled.'**
  String get googleAuthCancelled;

  /// Register link prefix text
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccount;

  /// Sign up button and link text
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Register page title
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Name field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your first and last name'**
  String get nameHint;

  /// Name validation error
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// Name minimum length validation error
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get nameMinLength;

  /// Password field hint for registration
  ///
  /// In en, this message translates to:
  /// **'Create your password'**
  String get createPassword;

  /// Welcome message for new users
  ///
  /// In en, this message translates to:
  /// **'Welcome! 🎉'**
  String get welcome;

  /// Sign in success message
  ///
  /// In en, this message translates to:
  /// **'Sign in successful! Welcome 👋'**
  String get signInSuccess;

  /// Home page title
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Goals page title
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals;

  /// Reports page title
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// Settings page title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Settings page subtitle
  ///
  /// In en, this message translates to:
  /// **'Account and app settings'**
  String get settingsSubtitle;

  /// Default user name
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// Skip button text
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Continue button text
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Get started button text
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Later button text
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Name saved success message
  ///
  /// In en, this message translates to:
  /// **'Name saved'**
  String get nameSaved;

  /// Name prompt dialog title
  ///
  /// In en, this message translates to:
  /// **'Let\'s set your name'**
  String get setYourName;

  /// Name prompt dialog description
  ///
  /// In en, this message translates to:
  /// **'We\'ll address you by your name on screen. You can always change this from your profile if you don\'t want to.'**
  String get setYourNameDescription;

  /// Reports page subtitle
  ///
  /// In en, this message translates to:
  /// **'Your yearly performance summary'**
  String get yearlyPerformanceSummary;

  /// Download report tooltip
  ///
  /// In en, this message translates to:
  /// **'Download report'**
  String get downloadReport;

  /// Yearly report title
  ///
  /// In en, this message translates to:
  /// **'Your 2025 Yearly Report'**
  String get yourYearlyReport2025;

  /// Yearly report subtitle
  ///
  /// In en, this message translates to:
  /// **'Let\'s take an overview of your journey'**
  String get letsTakeOverview;

  /// Open report button text
  ///
  /// In en, this message translates to:
  /// **'Open Report'**
  String get openReport;

  /// Create report button text
  ///
  /// In en, this message translates to:
  /// **'Create Report'**
  String get createReport;

  /// Great year message
  ///
  /// In en, this message translates to:
  /// **'You had a great year 🎉'**
  String get greatYear;

  /// Good progress message
  ///
  /// In en, this message translates to:
  /// **'You made good progress! 💪'**
  String get goodProgress;

  /// Continue journey message
  ///
  /// In en, this message translates to:
  /// **'Continue your journey! 🌱'**
  String get continueJourney;

  /// Error loading data message
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading data: {error}'**
  String errorLoadingData(String error);

  /// Overview section title
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// Total goals label
  ///
  /// In en, this message translates to:
  /// **'Total Goals'**
  String get totalGoals;

  /// Completion rate label
  ///
  /// In en, this message translates to:
  /// **'Completion Rate'**
  String get completionRate;

  /// Check-in label
  ///
  /// In en, this message translates to:
  /// **'Check-in'**
  String get checkIn;

  /// Average progress label
  ///
  /// In en, this message translates to:
  /// **'Average Progress'**
  String get averageProgress;

  /// Yearly progress section title
  ///
  /// In en, this message translates to:
  /// **'Yearly Progress'**
  String get yearlyProgress;

  /// No category data message
  ///
  /// In en, this message translates to:
  /// **'No category-based data yet'**
  String get noCategoryData;

  /// Category based development section title
  ///
  /// In en, this message translates to:
  /// **'Category-Based Development'**
  String get categoryBasedDevelopment;

  /// No achievement data message
  ///
  /// In en, this message translates to:
  /// **'Not enough data to create achievement stories yet. You\'ll see your progress here as you add goals and check in.'**
  String get noAchievementData;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Turkish language option
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkish;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Yearly report title with year
  ///
  /// In en, this message translates to:
  /// **'Your {year} Yearly Report'**
  String yourYearlyReport(int year);

  /// Achievements section title
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// Achievement text about goals worked on
  ///
  /// In en, this message translates to:
  /// **'This year you worked on a total of {totalGoals} goals and completed {completedGoals} goals (completion rate approximately {completionRate}%).'**
  String thisYearWorkedOnGoals(int totalGoals, int completedGoals, int completionRate);

  /// Achievement text about average progress
  ///
  /// In en, this message translates to:
  /// **'Your average progress level across all goals is around {progress}%; this shows that you took steps consistently throughout the year.'**
  String averageProgressLevel(int progress);

  /// Achievement text about category progress
  ///
  /// In en, this message translates to:
  /// **'You showed the strongest progress in the \"{category}\" category with approximately {value}%'**
  String strongestProgressInCategory(String category, int value);

  /// Achievement text about secondary category
  ///
  /// In en, this message translates to:
  /// **', and reached approximately {value}% level in the \"{category}\" category.'**
  String reachedLevelInCategory(int value, String category);

  /// AI suggestions section title
  ///
  /// In en, this message translates to:
  /// **'AI Suggestions'**
  String get aiSuggestions;

  /// Example AI suggestion text
  ///
  /// In en, this message translates to:
  /// **'Your progress in personal development goals is great! Next year, you can increase the completion rate by breaking down large career goals into smaller, manageable steps. Also, adding a goal on financial literacy can support your overall success.'**
  String get aiSuggestionExample;

  /// Error message when login is required
  ///
  /// In en, this message translates to:
  /// **'You need to sign in'**
  String get loginRequired;

  /// Success message when report is exported
  ///
  /// In en, this message translates to:
  /// **'Report exported successfully'**
  String get reportExportedSuccessfully;

  /// Export report dialog title
  ///
  /// In en, this message translates to:
  /// **'Export Report'**
  String get exportReport;

  /// Format selection label
  ///
  /// In en, this message translates to:
  /// **'Select format:'**
  String get selectFormat;

  /// JSON format label
  ///
  /// In en, this message translates to:
  /// **'JSON'**
  String get json;

  /// CSV format label
  ///
  /// In en, this message translates to:
  /// **'CSV'**
  String get csv;

  /// Error message when no goals exist
  ///
  /// In en, this message translates to:
  /// **'At least one goal is required to create a report'**
  String get atLeastOneGoalRequired;

  /// Error message when report creation fails
  ///
  /// In en, this message translates to:
  /// **'Error creating report: {error}'**
  String errorCreatingReport(String error);

  /// Report type selection label
  ///
  /// In en, this message translates to:
  /// **'Select report type:'**
  String get selectReportType;

  /// Weekly report type label
  ///
  /// In en, this message translates to:
  /// **'This week\'s summary'**
  String get thisWeekSummary;

  /// Monthly report type label
  ///
  /// In en, this message translates to:
  /// **'This month\'s summary'**
  String get thisMonthSummary;

  /// Yearly report type label
  ///
  /// In en, this message translates to:
  /// **'This year\'s summary'**
  String get thisYearSummary;

  /// Challenges label in note
  ///
  /// In en, this message translates to:
  /// **'Challenges and solutions:'**
  String get challengesAndSolutions;

  /// Challenge low progress text
  ///
  /// In en, this message translates to:
  /// **'Challenge: Progress in \"{category}\" category is relatively low (approx. {value}%).'**
  String challengeLowProgress(String category, int value);

  /// Solution text for low progress
  ///
  /// In en, this message translates to:
  /// **'Solution: You could try adding 1-2 small, clear actions in this area next week and increasing the frequency of check-ins.'**
  String get solutionAddActions;

  /// Challenge text about focus difficulty
  ///
  /// In en, this message translates to:
  /// **'Challenge: You may be having difficulty focusing on \"{category}\" goals (approximately {value}%).'**
  String challengeFocusDifficulty(String category, int value);

  /// Solution text for focus difficulty
  ///
  /// In en, this message translates to:
  /// **'Solution: Breaking these goals into smaller steps and reviewing them weekly can increase focus.'**
  String get solutionBreakDownGoals;

  /// General status text when all is good
  ///
  /// In en, this message translates to:
  /// **'General status: There is healthy progress in all categories.'**
  String get generalStatusHealthy;

  /// Solution text for general status
  ///
  /// In en, this message translates to:
  /// **'Solution: Still, reviewing your priorities weekly can be a good idea to maintain your motivation.'**
  String get solutionReviewPriorities;

  /// Message when not enough data for challenges
  ///
  /// In en, this message translates to:
  /// **'As your goal and check-in data grows, areas where you struggle and improvement suggestions will appear here.'**
  String get goalAndCheckInDataNeeded;

  /// January month name
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// February month name
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// March month name
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// April month name
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// May month name
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// June month name
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// July month name
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// August month name
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// September month name
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// October month name
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// November month name
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// December month name
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// Active goals tab label
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Completed items label in note
  ///
  /// In en, this message translates to:
  /// **'Completed:'**
  String get completed;

  /// My goals section title
  ///
  /// In en, this message translates to:
  /// **'My Goals'**
  String get myGoals;

  /// Goals page subtitle
  ///
  /// In en, this message translates to:
  /// **'Your success journey'**
  String get yourSuccessJourney;

  /// Sort button text
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// Filter button label
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// Sort option: newest
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get newest;

  /// Sort option: oldest
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get oldest;

  /// Sort option: progress high
  ///
  /// In en, this message translates to:
  /// **'Progress (High)'**
  String get progressHigh;

  /// Sort option: progress low
  ///
  /// In en, this message translates to:
  /// **'Progress (Low)'**
  String get progressLow;

  /// Sort option: title ascending
  ///
  /// In en, this message translates to:
  /// **'Title (A-Z)'**
  String get titleAsc;

  /// Sort option: title descending
  ///
  /// In en, this message translates to:
  /// **'Title (Z-A)'**
  String get titleDesc;

  /// Filter option: all
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Category: health
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// Category: mental health
  ///
  /// In en, this message translates to:
  /// **'Mental Health'**
  String get mentalHealth;

  /// Category: finance
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get finance;

  /// Category: career
  ///
  /// In en, this message translates to:
  /// **'Career'**
  String get career;

  /// Category: relationships
  ///
  /// In en, this message translates to:
  /// **'Relationships'**
  String get relationships;

  /// Category: learning
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get learning;

  /// Category: creativity
  ///
  /// In en, this message translates to:
  /// **'Creativity'**
  String get creativity;

  /// Category: hobby
  ///
  /// In en, this message translates to:
  /// **'Hobby'**
  String get hobby;

  /// Category: personal growth
  ///
  /// In en, this message translates to:
  /// **'Personal Growth'**
  String get personalGrowth;

  /// Empty state for completed goals
  ///
  /// In en, this message translates to:
  /// **'No completed goals yet'**
  String get noCompletedGoals;

  /// Empty state description for completed goals
  ///
  /// In en, this message translates to:
  /// **'Your completed goals will appear here as you complete them'**
  String get completedGoalsWillAppear;

  /// Error message when goals fail to load
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading goals.'**
  String get goalsLoadingError;

  /// Try again button text
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Reactivate goal dialog title
  ///
  /// In en, this message translates to:
  /// **'Reactivate Goal'**
  String get reactivateGoal;

  /// Reactivate goal dialog description
  ///
  /// In en, this message translates to:
  /// **'Do you want to remove the \"{goalTitle}\" goal from completed goals and add it back to the active goals list?'**
  String reactivateGoalDescription(String goalTitle);

  /// Move to active button text
  ///
  /// In en, this message translates to:
  /// **'Move to Active'**
  String get moveToActive;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Tooltip for move to active button
  ///
  /// In en, this message translates to:
  /// **'Move back to active goals'**
  String get moveToActiveTooltip;

  /// Error message when action requires sign in
  ///
  /// In en, this message translates to:
  /// **'You must sign in to perform this action.'**
  String get mustSignInToPerformAction;

  /// Notifications feature coming soon message
  ///
  /// In en, this message translates to:
  /// **'Notifications coming soon'**
  String get notificationsComingSoon;

  /// Your goals section title
  ///
  /// In en, this message translates to:
  /// **'Your Goals'**
  String get yourGoals;

  /// Morning greeting
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// Afternoon greeting
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// Evening greeting
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// Weekly summary card title
  ///
  /// In en, this message translates to:
  /// **'Weekly Summary'**
  String get weeklySummary;

  /// Weekly summary text
  ///
  /// In en, this message translates to:
  /// **'This week you made a total of {checkInCount} check-ins and made progress on {goalsWithProgress} different goals.'**
  String thisWeekCheckIns(int checkInCount, int goalsWithProgress);

  /// Error message when weekly summary fails to load
  ///
  /// In en, this message translates to:
  /// **'This week\'s summary could not be loaded right now. Try again later.'**
  String get weeklySummaryError;

  /// Check-in prompt text
  ///
  /// In en, this message translates to:
  /// **'How is today going?'**
  String get howIsTodayGoing;

  /// Message when goal has no target date
  ///
  /// In en, this message translates to:
  /// **'Target date not specified'**
  String get targetDateNotSpecified;

  /// Days overdue text
  ///
  /// In en, this message translates to:
  /// **'{days} days overdue'**
  String daysOverdue(int days);

  /// One day overdue text
  ///
  /// In en, this message translates to:
  /// **'1 day overdue'**
  String get oneDayOverdue;

  /// Today text
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// One day left text
  ///
  /// In en, this message translates to:
  /// **'1 day left'**
  String get oneDayLeft;

  /// Days left text
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String daysLeft(int days);

  /// Error message when reports fail to load
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading reports: {error}'**
  String reportsLoadingError(String error);

  /// Empty state when no reports exist
  ///
  /// In en, this message translates to:
  /// **'No reports created yet'**
  String get noReportsYet;

  /// Message to create first report
  ///
  /// In en, this message translates to:
  /// **'You can create your first report by clicking the \"Create Report\" button above.'**
  String get createFirstReport;

  /// Past reports section title
  ///
  /// In en, this message translates to:
  /// **'Past Reports'**
  String get pastReports;

  /// Success message when goal is reactivated
  ///
  /// In en, this message translates to:
  /// **'Goal moved back to active list.'**
  String get goalMovedToActive;

  /// Error updating goal message
  ///
  /// In en, this message translates to:
  /// **'An error occurred while updating goal: {error}'**
  String errorUpdatingGoal(String error);

  /// Message when no check-in exists
  ///
  /// In en, this message translates to:
  /// **'No check-in yet'**
  String get noCheckInYet;

  /// Yesterday text
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Days ago text
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(int days);

  /// Weeks ago text
  ///
  /// In en, this message translates to:
  /// **'{weeks} weeks ago'**
  String weeksAgo(int weeks);

  /// Loading text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Last check-in text
  ///
  /// In en, this message translates to:
  /// **'Last Check-in: {date}'**
  String lastCheckIn(String date);

  /// Empty state when no goals exist
  ///
  /// In en, this message translates to:
  /// **'You haven\'t added any goals yet'**
  String get noGoalsYet;

  /// Message to encourage adding first goal
  ///
  /// In en, this message translates to:
  /// **'Start your success journey by adding a new goal'**
  String get startJourneyWithGoal;

  /// Add new goal button text
  ///
  /// In en, this message translates to:
  /// **'Add New Goal'**
  String get addNewGoal;

  /// Empty state message for goals
  ///
  /// In en, this message translates to:
  /// **'You haven\'t created any goals yet'**
  String get noGoalCreatedYet;

  /// Message to create first goal
  ///
  /// In en, this message translates to:
  /// **'Create your first goal and make your year more planned, focused and meaningful.'**
  String get createFirstGoal;

  /// Create goal button text
  ///
  /// In en, this message translates to:
  /// **'Create Goal'**
  String get createGoal;

  /// Do check-in button text
  ///
  /// In en, this message translates to:
  /// **'Do Check-in'**
  String get doCheckIn;

  /// Tasks remaining text
  ///
  /// In en, this message translates to:
  /// **'{count} tasks remaining'**
  String tasksRemaining(int count);

  /// Check-in count text
  ///
  /// In en, this message translates to:
  /// **'{count} check-in'**
  String checkInCount(int count);

  /// Report type label with period
  ///
  /// In en, this message translates to:
  /// **'{type} Report - {period}'**
  String reportTypeLabel(String type, String period);

  /// Onboarding slide 1 title
  ///
  /// In en, this message translates to:
  /// **'Make your goals concrete this year.'**
  String get onboardingSlide1Title;

  /// Onboarding slide 1 description
  ///
  /// In en, this message translates to:
  /// **'Turn your dreams into reality with YearFlow. Progress towards your big goals with achievable steps.'**
  String get onboardingSlide1Description;

  /// Onboarding slide 2 title
  ///
  /// In en, this message translates to:
  /// **'Track your journey with regular progress.'**
  String get onboardingSlide2Title;

  /// Onboarding slide 2 description
  ///
  /// In en, this message translates to:
  /// **'Record your progress on goals with monthly check-ins, maintain your motivation and celebrate your achievements.'**
  String get onboardingSlide2Description;

  /// Onboarding slide 3 title
  ///
  /// In en, this message translates to:
  /// **'Get your personal development report at the end of the year.'**
  String get onboardingSlide3Title;

  /// Onboarding slide 3 description
  ///
  /// In en, this message translates to:
  /// **'See the progress you\'ve made throughout the year with AI-powered reports, understand your development with concrete data and get inspired for new goals.'**
  String get onboardingSlide3Description;

  /// Welcome screen main headline
  ///
  /// In en, this message translates to:
  /// **'Make your goals real.'**
  String get onboardingWelcomeTitle;

  /// Welcome screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Turn your dreams into reality, one step at a time.'**
  String get onboardingWelcomeSubtitle;

  /// Feature slide 1 title
  ///
  /// In en, this message translates to:
  /// **'Track your journey'**
  String get onboardingFeature1Title;

  /// Feature slide 1 subtitle
  ///
  /// In en, this message translates to:
  /// **'Monthly check-ins help you stay on track and see how far you\'ve come.'**
  String get onboardingFeature1Subtitle;

  /// Feature slide 2 title
  ///
  /// In en, this message translates to:
  /// **'Celebrate every win'**
  String get onboardingFeature2Title;

  /// Feature slide 2 subtitle
  ///
  /// In en, this message translates to:
  /// **'Visual progress and milestones keep you motivated along the way.'**
  String get onboardingFeature2Subtitle;

  /// Feature slide 3 title
  ///
  /// In en, this message translates to:
  /// **'See your growth with AI-powered reports.'**
  String get onboardingFeature3Title;

  /// Feature slide 3 subtitle
  ///
  /// In en, this message translates to:
  /// **'Yearly snapshots & data-driven insights.'**
  String get onboardingFeature3Subtitle;

  /// Onboarding end screen title
  ///
  /// In en, this message translates to:
  /// **'Ready to start your journey?'**
  String get onboardingEndTitle;

  /// Onboarding end screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Let\'s turn your goals into achievements.'**
  String get onboardingEndSubtitle;

  /// Onboarding end screen CTA button
  ///
  /// In en, this message translates to:
  /// **'Let\'s start'**
  String get letsStart;

  /// Login link prefix text
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// Google sign up button text
  ///
  /// In en, this message translates to:
  /// **'Sign up with Google'**
  String get continueWithGoogleRegister;

  /// Forgot password page title
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPasswordTitle;

  /// Forgot password page description
  ///
  /// In en, this message translates to:
  /// **'Enter your registered email address to reset your password.'**
  String get forgotPasswordDescription;

  /// Email address label
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// Email address field hint
  ///
  /// In en, this message translates to:
  /// **'Your Email Address'**
  String get emailAddressHint;

  /// Reset password button text
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// Email sent success message
  ///
  /// In en, this message translates to:
  /// **'Email sent!'**
  String get emailSent;

  /// Reset link sent message
  ///
  /// In en, this message translates to:
  /// **'Password reset link has been sent to {email}.'**
  String resetLinkSent(String email);

  /// New goal page title
  ///
  /// In en, this message translates to:
  /// **'New Goal'**
  String get newGoal;

  /// Edit goal page title
  ///
  /// In en, this message translates to:
  /// **'Edit Goal'**
  String get editGoal;

  /// Goal created success message
  ///
  /// In en, this message translates to:
  /// **'Goal created successfully! 🎉'**
  String get goalCreatedSuccess;

  /// Goal updated success message
  ///
  /// In en, this message translates to:
  /// **'Goal updated! ✅'**
  String get goalUpdatedSuccess;

  /// Goal optimized success message
  ///
  /// In en, this message translates to:
  /// **'Goal optimized! ✨'**
  String get goalOptimizedSuccess;

  /// AI optimize button text
  ///
  /// In en, this message translates to:
  /// **'Optimize with AI'**
  String get optimizeWithAI;

  /// Update button text
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// Goal not found error message
  ///
  /// In en, this message translates to:
  /// **'Goal not found'**
  String get goalNotFound;

  /// Error creating goal message
  ///
  /// In en, this message translates to:
  /// **'An error occurred while creating goal: {error}'**
  String errorCreatingGoal(String error);

  /// Form validation error message
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields in the form'**
  String get pleaseFillAllFields;

  /// Category selection error message
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get pleaseSelectCategory;

  /// Date selection error message
  ///
  /// In en, this message translates to:
  /// **'Please select completion date'**
  String get pleaseSelectCompletionDate;

  /// Reason field validation error
  ///
  /// In en, this message translates to:
  /// **'Please explain why you want this goal'**
  String get pleaseExplainWhy;

  /// Goal created notification title
  ///
  /// In en, this message translates to:
  /// **'Goal Created'**
  String get goalCreated;

  /// Check-in completed notification
  ///
  /// In en, this message translates to:
  /// **'Check-in Completed: Score {score}/10'**
  String checkInCompleted(int score);

  /// Not specified text
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get notSpecified;

  /// Expired text
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// Tomorrow text
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// Error loading goal message
  ///
  /// In en, this message translates to:
  /// **'Error loading goal: {error}'**
  String errorLoadingGoal(String error);

  /// Error loading check-ins message
  ///
  /// In en, this message translates to:
  /// **'Error loading check-ins: {error}'**
  String errorLoadingCheckIns(String error);

  /// Check-in saved success message
  ///
  /// In en, this message translates to:
  /// **'Check-in saved! ✅'**
  String get checkInSaved;

  /// Goal completed success message
  ///
  /// In en, this message translates to:
  /// **'Goal completed! 🎉'**
  String get goalCompleted;

  /// Error completing goal message
  ///
  /// In en, this message translates to:
  /// **'An error occurred while completing goal: {error}'**
  String errorCompletingGoal(String error);

  /// Complete goal button tooltip
  ///
  /// In en, this message translates to:
  /// **'Complete Goal'**
  String get completeGoal;

  /// Goal deleted success message
  ///
  /// In en, this message translates to:
  /// **'Goal deleted successfully'**
  String get goalDeletedSuccess;

  /// Error deleting goal message
  ///
  /// In en, this message translates to:
  /// **'An error occurred while deleting goal: {error}'**
  String errorDeletingGoal(String error);

  /// Delete goal button text
  ///
  /// In en, this message translates to:
  /// **'Delete Goal'**
  String get deleteGoal;

  /// Goal completed title
  ///
  /// In en, this message translates to:
  /// **'Goal Completed 🎉'**
  String get goalCompletedTitle;

  /// Progress recorded title
  ///
  /// In en, this message translates to:
  /// **'Progress Recorded'**
  String get progressRecorded;

  /// Next check-in text
  ///
  /// In en, this message translates to:
  /// **'Next Check-in: {date}'**
  String nextCheckIn(String date);

  /// Timeline tab text
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// Notes tab text
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// Sub tasks tab text
  ///
  /// In en, this message translates to:
  /// **'Sub Tasks'**
  String get subTasks;

  /// Creating index message
  ///
  /// In en, this message translates to:
  /// **'Creating Index'**
  String get creatingIndex;

  /// Error loading notes message
  ///
  /// In en, this message translates to:
  /// **'Error Loading Notes'**
  String get errorLoadingNotes;

  /// Firestore index not ready message
  ///
  /// In en, this message translates to:
  /// **'Firestore index is not ready yet. Please wait a few minutes and try again.'**
  String get firestoreIndexNotReady;

  /// Tasks left text
  ///
  /// In en, this message translates to:
  /// **'{count} tasks left'**
  String tasksLeft(int count);

  /// Today check-in text
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayCheckIn;

  /// Yesterday check-in text
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterdayCheckIn;

  /// Days ago check-in text
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgoCheckIn(int days);

  /// Weeks ago check-in text
  ///
  /// In en, this message translates to:
  /// **'{weeks} weeks ago'**
  String weeksAgoCheckIn(int weeks);

  /// Weekly report summary text
  ///
  /// In en, this message translates to:
  /// **'Summary for this week'**
  String get reportSummaryThisWeek;

  /// Monthly report summary text
  ///
  /// In en, this message translates to:
  /// **'Summary for this month'**
  String get reportSummaryThisMonth;

  /// Yearly report summary text
  ///
  /// In en, this message translates to:
  /// **'Summary for this year'**
  String get reportSummaryThisYear;

  /// Error loading reports message
  ///
  /// In en, this message translates to:
  /// **'Error loading reports: {error}'**
  String reportErrorLoading(String error);

  /// Create first report message
  ///
  /// In en, this message translates to:
  /// **'You can create your first report by clicking the \"Create Report\" button above.'**
  String get createYourFirstReport;

  /// Weekly report type
  ///
  /// In en, this message translates to:
  /// **'Weekly Report'**
  String get reportTypeWeekly;

  /// Monthly report type
  ///
  /// In en, this message translates to:
  /// **'Monthly Report'**
  String get reportTypeMonthly;

  /// Yearly report type
  ///
  /// In en, this message translates to:
  /// **'Yearly Report'**
  String get reportTypeYearly;

  /// Solution increase check-ins text
  ///
  /// In en, this message translates to:
  /// **'Solution: Try adding 1-2 small, clear actions in this area next week and increase check-in frequency.'**
  String get solutionIncreaseCheckIns;

  /// Challenge difficulty focusing text
  ///
  /// In en, this message translates to:
  /// **'Challenge: You might be struggling to focus on \"{category}\" goals (approx. {value}%).'**
  String challengeDifficultyFocusing(String category, int value);

  /// General status healthy progress text
  ///
  /// In en, this message translates to:
  /// **'General status: Healthy progress in all categories.'**
  String get generalStatusHealthyProgress;

  /// Report title with type and period
  ///
  /// In en, this message translates to:
  /// **'{reportType} Report - {period}'**
  String reportTitle(String reportType, String period);

  /// Application settings section title
  ///
  /// In en, this message translates to:
  /// **'Application Settings'**
  String get applicationSettings;

  /// Notifications setting label
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Upcoming check-ins section title
  ///
  /// In en, this message translates to:
  /// **'Upcoming Check-ins'**
  String get upcomingCheckIns;

  /// No upcoming check-ins message
  ///
  /// In en, this message translates to:
  /// **'No upcoming check-ins for this week.'**
  String get noUpcomingCheckIns;

  /// All goals completed message
  ///
  /// In en, this message translates to:
  /// **'All goals completed! 🎉'**
  String get allGoalsCompleted;

  /// All goals completed description
  ///
  /// In en, this message translates to:
  /// **'You\'ve completed all your goals for this week. Time to set new ones or enjoy your progress!'**
  String get allGoalsCompletedDescription;

  /// View all goals button text
  ///
  /// In en, this message translates to:
  /// **'View All Goals'**
  String get viewAllGoals;

  /// Weekly summary title
  ///
  /// In en, this message translates to:
  /// **'Weekly Summary'**
  String get weeklySummaryTitle;

  /// Weekly summary description
  ///
  /// In en, this message translates to:
  /// **'Your progress for this week'**
  String get weeklySummaryDescription;

  /// Weekly summary no data message
  ///
  /// In en, this message translates to:
  /// **'No data for this week yet. Start adding goals and checking in to see your progress!'**
  String get weeklySummaryNoData;

  /// Name prompt title
  ///
  /// In en, this message translates to:
  /// **'Let\'s set your name'**
  String get namePromptTitle;

  /// Name prompt description
  ///
  /// In en, this message translates to:
  /// **'We\'ll address you by your name on screen. You can always change this from your profile if you don\'t want to.'**
  String get namePromptDescription;

  /// Name prompt save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get namePromptSave;

  /// Name prompt later button
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get namePromptLater;

  /// Name prompt name saved message
  ///
  /// In en, this message translates to:
  /// **'Name saved'**
  String get namePromptNameSaved;

  /// Profile page title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Annual report label
  ///
  /// In en, this message translates to:
  /// **'Annual Report'**
  String get annualReport;

  /// Account information section title
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInformation;

  /// Edit button text
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Full name field label
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// Upcoming check-ins description text
  ///
  /// In en, this message translates to:
  /// **'Do check-ins for goals with less than 7 days remaining'**
  String get upcomingCheckInsDescription;

  /// Question of the day title
  ///
  /// In en, this message translates to:
  /// **'QUESTION OF THE DAY'**
  String get questionOfTheDay;

  /// Question of the day text
  ///
  /// In en, this message translates to:
  /// **'What was the biggest thing that motivated you to reach your goals today?'**
  String get questionOfTheDayText;

  /// Write your answer button text
  ///
  /// In en, this message translates to:
  /// **'Write Your Answer'**
  String get writeYourAnswer;

  /// Monthly report type label
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// Weekly report type label
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// Yearly report type label
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// Data section title
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// Download all data option
  ///
  /// In en, this message translates to:
  /// **'Download all my data'**
  String get downloadAllMyData;

  /// Restore from backup option
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get restoreFromBackup;

  /// Security and support section title
  ///
  /// In en, this message translates to:
  /// **'Security and Support'**
  String get securityAndSupport;

  /// Privacy and security option
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacyAndSecurity;

  /// Log out button text
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// Log out dialog title
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOutTitle;

  /// Log out confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of your account?'**
  String get logOutConfirmation;

  /// Restore from backup dialog title
  ///
  /// In en, this message translates to:
  /// **'Restore from Backup'**
  String get restoreFromBackupTitle;

  /// Restore from backup warning message
  ///
  /// In en, this message translates to:
  /// **'The backup file you selected will delete all current goal and report data and replace them with the backup data.\n\nThis action cannot be undone. Are you sure you want to continue?'**
  String get restoreFromBackupWarning;

  /// Yes continue button text
  ///
  /// In en, this message translates to:
  /// **'Yes, continue'**
  String get yesContinue;

  /// Change password button and dialog title
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// Current password field label
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// New password field label
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// New password repeat field label
  ///
  /// In en, this message translates to:
  /// **'New Password (Repeat)'**
  String get newPasswordRepeat;

  /// Password mismatch error
  ///
  /// In en, this message translates to:
  /// **'New passwords do not match'**
  String get passwordsDoNotMatch;

  /// Password changed success message
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccess;

  /// Export all data dialog title
  ///
  /// In en, this message translates to:
  /// **'Export All Data'**
  String get exportAllData;

  /// Export data format question
  ///
  /// In en, this message translates to:
  /// **'In which format would you like to save your data?'**
  String get exportDataFormatQuestion;

  /// CSV format option
  ///
  /// In en, this message translates to:
  /// **'Table (CSV)'**
  String get tableCsv;

  /// JSON format option
  ///
  /// In en, this message translates to:
  /// **'Advanced (JSON)'**
  String get advancedJson;

  /// Current password validation error
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get enterCurrentPassword;

  /// New password validation error
  ///
  /// In en, this message translates to:
  /// **'Enter your new password'**
  String get enterNewPassword;

  /// New password repeat validation error
  ///
  /// In en, this message translates to:
  /// **'Re-enter your new password'**
  String get reEnterNewPassword;

  /// Password mismatch validation error
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsMismatch;

  /// Backup imported success message
  ///
  /// In en, this message translates to:
  /// **'Backup imported successfully. You can check by refreshing the Goals screen.'**
  String get backupImportedSuccess;

  /// Export completed message
  ///
  /// In en, this message translates to:
  /// **'Export completed. You can access the files from the Downloads folder.'**
  String get exportCompleted;

  /// Edit profile dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Email field helper text
  ///
  /// In en, this message translates to:
  /// **'Email address cannot be changed'**
  String get emailCannotBeChanged;

  /// Profile updated success message
  ///
  /// In en, this message translates to:
  /// **'Profile information updated'**
  String get profileUpdatedSuccess;

  /// Delete account button and dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// Delete account confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.'**
  String get deleteAccountConfirmation;

  /// Account deleted success message
  ///
  /// In en, this message translates to:
  /// **'Your account has been successfully deleted'**
  String get accountDeletedSuccess;

  /// Error deleting account message
  ///
  /// In en, this message translates to:
  /// **'An error occurred while deleting account'**
  String get errorDeletingAccount;

  /// Goal title field label
  ///
  /// In en, this message translates to:
  /// **'Goal Title'**
  String get goalTitle;

  /// Goal title field hint
  ///
  /// In en, this message translates to:
  /// **'e.g., Learn a new language'**
  String get goalTitleHint;

  /// Goal title validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a goal title'**
  String get goalTitleRequired;

  /// Goal title minimum length validation error
  ///
  /// In en, this message translates to:
  /// **'Goal title must be at least 3 characters'**
  String get goalTitleMinLength;

  /// Category selection field label
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// Category validation error
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get categoryRequired;

  /// Motivation field label
  ///
  /// In en, this message translates to:
  /// **'Why do you want this goal?'**
  String get whyThisGoal;

  /// Motivation field hint
  ///
  /// In en, this message translates to:
  /// **'Write your motivation and purpose...'**
  String get motivationHint;

  /// Motivation validation error
  ///
  /// In en, this message translates to:
  /// **'Please explain why you want this goal'**
  String get motivationRequired;

  /// Completion date field label
  ///
  /// In en, this message translates to:
  /// **'Completion Date'**
  String get completionDate;

  /// Date picker placeholder
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// Date validation error
  ///
  /// In en, this message translates to:
  /// **'Please select a completion date'**
  String get dateRequired;

  /// Category dropdown hint
  ///
  /// In en, this message translates to:
  /// **'e.g., Career, Health'**
  String get categoryExample;

  /// Note deleted success message
  ///
  /// In en, this message translates to:
  /// **'Note deleted'**
  String get noteDeleted;

  /// Note added success message
  ///
  /// In en, this message translates to:
  /// **'Note added'**
  String get noteAdded;

  /// Note content validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter note content'**
  String get pleaseEnterNoteContent;

  /// Error deleting note message
  ///
  /// In en, this message translates to:
  /// **'An error occurred while deleting note: {error}'**
  String errorDeletingNote(String error);

  /// Error adding note message
  ///
  /// In en, this message translates to:
  /// **'An error occurred while adding note: {error}'**
  String errorAddingNote(String error);

  /// Add note dialog title
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get addNote;

  /// Edit note dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit Note'**
  String get editNote;

  /// Note content field label
  ///
  /// In en, this message translates to:
  /// **'Note Content'**
  String get noteContent;

  /// Note content field hint
  ///
  /// In en, this message translates to:
  /// **'Write your note here...'**
  String get noteContentHint;

  /// Monthly check-in page title
  ///
  /// In en, this message translates to:
  /// **'Monthly Check-in'**
  String get monthlyCheckIn;

  /// Check-in page subtitle
  ///
  /// In en, this message translates to:
  /// **'Take a moment to reflect'**
  String get takeAMomentToReflect;

  /// Progress evaluation question
  ///
  /// In en, this message translates to:
  /// **'How do you evaluate your progress this month?'**
  String get howDoYouEvaluateThisMonth;

  /// Score slider description
  ///
  /// In en, this message translates to:
  /// **'1 means very low progress, 10 means excellent progress.'**
  String get scoreDescription;

  /// Score display
  ///
  /// In en, this message translates to:
  /// **'Score: {score} / 10'**
  String score(int score);

  /// Save check-in button text
  ///
  /// In en, this message translates to:
  /// **'Save Check-in'**
  String get saveCheckIn;

  /// Error saving check-in message
  ///
  /// In en, this message translates to:
  /// **'An error occurred while saving check-in: {error}'**
  String errorSavingCheckIn(String error);

  /// Progress question title
  ///
  /// In en, this message translates to:
  /// **'What did you do for this goal this month?'**
  String get whatDidYouDoThisMonth;

  /// Progress question subtitle
  ///
  /// In en, this message translates to:
  /// **'Small steps count too. A short answer is enough.'**
  String get smallStepsCount;

  /// Progress question hint
  ///
  /// In en, this message translates to:
  /// **'e.g., I worked out 3 times a week, read two chapters, practiced vocabulary…'**
  String get progressExample;

  /// Challenge question title
  ///
  /// In en, this message translates to:
  /// **'What challenged you most during this process? How did you deal with it?'**
  String get whatChallengedYouMost;

  /// Challenge question subtitle
  ///
  /// In en, this message translates to:
  /// **'You can also write only the part that challenged you.'**
  String get youCanWriteOnlyChallenges;

  /// Challenge question hint
  ///
  /// In en, this message translates to:
  /// **'e.g., Workload disrupted my routine; I started making weekly plans to get back on track…'**
  String get challengeExample;

  /// Note question title
  ///
  /// In en, this message translates to:
  /// **'Would you like to leave a small note for your future self?'**
  String get leaveNoteForFutureSelf;

  /// Note question hint
  ///
  /// In en, this message translates to:
  /// **'e.g., You\'re doing great. Stay consistent and trust the process.'**
  String get noteExample;

  /// Optional field label
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// Note label in note
  ///
  /// In en, this message translates to:
  /// **'Note:'**
  String get note;

  /// Check-in goal selection dialog title
  ///
  /// In en, this message translates to:
  /// **'Which goal would you like to check in for?'**
  String get whichGoalForCheckIn;

  /// Check-in goal selection dialog description
  ///
  /// In en, this message translates to:
  /// **'Select a goal from below; we\'ll take you directly to the check-in screen.'**
  String get selectGoalFromBelow;

  /// Goals loading message
  ///
  /// In en, this message translates to:
  /// **'Loading goals...'**
  String get goalsLoading;

  /// Error loading goals message
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading goals: {error}'**
  String errorLoadingGoals(String error);

  /// No goals message when trying to check in
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any goals yet. You need to create a goal first.'**
  String get noGoalsYetCreateFirst;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Complete button text
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// Delete subtask dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Subtask'**
  String get deleteSubtask;

  /// Delete subtask confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this subtask?'**
  String get deleteSubtaskConfirmation;

  /// Delete report dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Report'**
  String get deleteReport;

  /// Error message shown when a page is not found
  ///
  /// In en, this message translates to:
  /// **'Page not found: {path}'**
  String pageNotFound(String path);

  /// Error message when AI optimization result is not found
  ///
  /// In en, this message translates to:
  /// **'Optimization result not found'**
  String get optimizationResultNotFound;

  /// Instruction text for creating first report
  ///
  /// In en, this message translates to:
  /// **'You can create your first report by clicking the \"Create Report\" button above.'**
  String get createFirstReportInstruction;

  /// Remove button text
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Firebase Auth error: email already in use
  ///
  /// In en, this message translates to:
  /// **'The email address is already in use by another account.'**
  String get errorEmailAlreadyInUse;

  /// Firebase Auth error: weak password
  ///
  /// In en, this message translates to:
  /// **'The password is too weak. Please choose a stronger password.'**
  String get errorWeakPassword;

  /// Firebase Auth error: invalid email
  ///
  /// In en, this message translates to:
  /// **'The email address is invalid. Please enter a valid email address.'**
  String get errorInvalidEmail;

  /// Firebase Auth error: user not found
  ///
  /// In en, this message translates to:
  /// **'No account found with this email address. Please check your email or sign up.'**
  String get errorUserNotFound;

  /// Firebase Auth error: wrong password
  ///
  /// In en, this message translates to:
  /// **'The password is incorrect. Please try again.'**
  String get errorWrongPassword;

  /// Firebase Auth error: invalid credential
  ///
  /// In en, this message translates to:
  /// **'The email or password is incorrect. Please try again.'**
  String get errorInvalidCredential;

  /// Firebase Auth error: user disabled
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled. Please contact support.'**
  String get errorUserDisabled;

  /// Firebase Auth error: too many requests
  ///
  /// In en, this message translates to:
  /// **'Too many failed login attempts. Please try again later.'**
  String get errorTooManyRequests;

  /// Firebase Auth error: operation not allowed
  ///
  /// In en, this message translates to:
  /// **'This sign-in method is not currently available. Please try again later.'**
  String get errorOperationNotAllowed;

  /// Firebase Auth error: network request failed
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection.'**
  String get errorNetworkRequestFailed;

  /// Firebase Auth error: requires recent login
  ///
  /// In en, this message translates to:
  /// **'For security reasons, please sign in again.'**
  String get errorRequiresRecentLogin;

  /// Firebase Auth error: general sign in failure
  ///
  /// In en, this message translates to:
  /// **'Sign in failed. Please check your email and password, then try again.'**
  String get errorSignInFailed;

  /// Firebase Auth error: general sign up failure
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please try again.'**
  String get errorSignUpFailed;

  /// Firebase Auth error: password reset failure
  ///
  /// In en, this message translates to:
  /// **'Password reset failed. Please try again.'**
  String get errorPasswordResetFailed;

  /// Firebase Auth error: unexpected error
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get errorUnexpectedAuth;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'tr': return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
