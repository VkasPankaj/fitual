# fitual

Fitual App — Flutter Workout Tracker

Welcome to the Fitual App, a Flutter-based workout and fitness tracking application. This app is designed with clean architecture principles and modern state management using Riverpod. It allows users to authenticate, track workouts, view workout details, and access history — all wrapped in a beautiful and responsive UI.

## Getting Started

lib/
├── core/
│   └── routing/
│       └── app_routing.dart         # Manages app navigation and route definitions
├── models/
│   └── workout.dart                 # Defines the Workout model
├── presentation/
│   └── screens/
│       ├── auth_screen.dart         # UI for user login/registration
│       ├── home_screen.dart         # Displays available workouts
│       ├── detail_screen.dart       # Shows detailed info about a selected workout
│       └── history_screen.dart      # Lists user's workout history
├── providers/
│   ├── auth_provider.dart           # Handles user authentication logic
│   ├── history_provider.dart        # Manages workout history state
│   ├── theme_provider.dart          # Toggles light/dark theme
│   ├── workouts_providers.dart      # Fetches and manages workouts list
│   └── workout_progress_provider.dart  # Tracks progress for ongoing workouts
└── main.dart                        # App entry point and root setup

## Architecture Overview
State Management: Riverpod

Routing: Declarative navigation using a central route file

Clean Structure: Separated concerns for core logic, models, providers, and presentation

## Features
🔐 User Authentication

📋 List of Workouts

📈 Track Workout Progress

🕓 View Workout History

🌙 Light & Dark Theme Support