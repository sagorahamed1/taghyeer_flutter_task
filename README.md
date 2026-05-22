# SpendArc

SpendArc is a personal finance tracker application built with Flutter. 

## About the Project

This project was built as a Senior Flutter Developer technical assessment. The goal was to demonstrate clean architecture, state management with BLoC, local persistence, remote data integration.

## Features

1. Add income and expense transactions with a title, amount, category, and date
2. View a summary of total income, total expense, and current balance
3. Showing how much of the income has been spent this month
4. Weekly spending chart displaying income vs expense over the last 7 days
5. Set a custom monthly budget from appbar
6. Pull to refresh to sync data
8. Swipe to delete a transaction
9. Offline support with local SQLite storage and pending operation queue
10. Automatic sync when the device comes back online

## Transaction Categories

Expense categories: Food, Transport, Shopping, Health, Entertainment

Income categories: Salary, Freelance, Investment, Gift

## Architecture

The project follows Clean Architecture principles with three layers:

- Domain layer: entities, repository interfaces, and use cases
- Data layer: local data source (SQLite via sqflite), remote data source (REST API via http), repository implementation with offline-first logic
- Presentation layer: BLoC for state management, pages, and widgets

Dependency injection is handled by GetIt. The project uses the repository pattern to abstract data sources from the business logic.

## State Management

The app uses three BLoC instances:

- TransactionBloc: handles loading, adding, and deleting transactions
- SummaryBloc: listens to TransactionBloc and computes income, expense, balance, and weekly chart data
- (Auth removed — app opens directly to the home screen)


## Getting Started

Make sure you have Flutter installed. Then run the following commands:

```
flutter pub get
flutter run
```

## Notes

- Remote data is fetched from JSONPlaceholder (a public mock API) and mapped to transaction objects for demonstration purposes.
- Local data persists across app restarts using SQLite.
- If the device is offline, new transactions are saved locally and queued for sync when connectivity is restored.
