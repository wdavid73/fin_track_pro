import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'FinTrack Pro'**
  String get appTitle;

  /// Home
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Analytics
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// Categories
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// Settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Account
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Profile
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Manage your profile
  ///
  /// In en, this message translates to:
  /// **'Manage your profile'**
  String get manageYourProfile;

  /// Security
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// Password, 2FA, Biometrics
  ///
  /// In en, this message translates to:
  /// **'Password, 2FA, Biometrics'**
  String get passwordBiometrics;

  /// Preferences
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// Notifications
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Budget alerts, reminders
  ///
  /// In en, this message translates to:
  /// **'Budget alerts, reminders'**
  String get budgetAlertsReminders;

  /// Currency
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// Appearance
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Data & Privacy
  ///
  /// In en, this message translates to:
  /// **'Data & Privacy'**
  String get dataPrivacy;

  /// Export data
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get exportData;

  /// Privacy Policy
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Support
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// About
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// FAQ
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// Log Out
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// Coming soon...
  ///
  /// In en, this message translates to:
  /// **'Coming soon...'**
  String get comingSoon;

  /// Select Theme
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get selectTheme;

  /// System
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// Light
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Dark
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// Add Transaction
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// Retry
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Delete Category
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get deleteCategory;

  /// Cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// All Transactions
  ///
  /// In en, this message translates to:
  /// **'All Transactions'**
  String get allTransactions;

  /// Update Transaction
  ///
  /// In en, this message translates to:
  /// **'Update Transaction'**
  String get updateTransaction;

  /// Save Transaction
  ///
  /// In en, this message translates to:
  /// **'Save Transaction'**
  String get saveTransaction;

  /// Transaction Type
  ///
  /// In en, this message translates to:
  /// **'Transaction Type'**
  String get transactionType;

  /// All
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Expense
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// Income
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// Category
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// All categories
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategories;

  /// Date Range
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// Clear All
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// Apply Filters
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// Total Balance
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get totalBalance;

  /// Budget Overview
  ///
  /// In en, this message translates to:
  /// **'Budget Overview'**
  String get budgetOverview;

  /// View Details
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No budget data available
  ///
  /// In en, this message translates to:
  /// **'No budget data available'**
  String get noBudgetDataAvailable;

  /// Budget Remaining
  ///
  /// In en, this message translates to:
  /// **'Budget Remaining'**
  String get budgetRemaining;

  /// Total Income
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get totalIncome;

  /// Total Expenses
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get totalExpenses;

  /// Net Savings
  ///
  /// In en, this message translates to:
  /// **'Net Savings'**
  String get netSavings;

  /// Spending by Category
  ///
  /// In en, this message translates to:
  /// **'Spending by Category'**
  String get spendingByCategory;

  /// No spending data available
  ///
  /// In en, this message translates to:
  /// **'No spending data available'**
  String get noSpendingDataAvailable;

  /// Top Spending Categories
  ///
  /// In en, this message translates to:
  /// **'Top Spending Categories'**
  String get topSpendingCategories;

  /// transaction (singular)
  ///
  /// In en, this message translates to:
  /// **'transaction'**
  String get transaction;

  /// transactions (plural)
  ///
  /// In en, this message translates to:
  /// **'transactions'**
  String get transactions;

  /// Edit Category
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// New Category
  ///
  /// In en, this message translates to:
  /// **'New Category'**
  String get newCategory;

  /// Update
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// Save
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Type
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// Color
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// Category Name
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// e.g., Groceries
  ///
  /// In en, this message translates to:
  /// **'e.g., Groceries'**
  String get egGroceries;

  /// Please enter a category name
  ///
  /// In en, this message translates to:
  /// **'Please enter a category name'**
  String get pleaseEnterCategoryName;

  /// Icon
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get icon;

  /// Preview
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// Are you sure you want to delete this category?
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this category?'**
  String get areYouSureDeleteCategory;

  /// Select Category
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// Amount
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// Select Date
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// Add a note...
  ///
  /// In en, this message translates to:
  /// **'Add a note...'**
  String get addNote;

  /// Spent
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// View All
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// Search by description
  ///
  /// In en, this message translates to:
  /// **'Search by description'**
  String get searchByDescription;

  /// Start Date
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// End Date
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// Filter Transactions
  ///
  /// In en, this message translates to:
  /// **'Filter Transactions'**
  String get filterTransactions;

  /// Week
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// Month
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// Year
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// Income vs Expense
  ///
  /// In en, this message translates to:
  /// **'Income vs Expense'**
  String get incomeVsExpense;

  /// This Month
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// Logout
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No data available
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
