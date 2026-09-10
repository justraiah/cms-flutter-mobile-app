# CMS Flutter Mobile App

Mobile companion application for the **Clinic Monitoring System (CMS)** capstone project.

The app is designed for **students to securely view their clinic medical records and health information from a mobile device**.

## Scope

The mobile application focuses on viewing information already recorded in the CMS backend. It does not replace the clinic staff web system.

### Current Features

- Student login with JWT authentication
- Student dashboard
- Medical records viewing
- Medical record details
- Vital signs history viewing
- Loading, error, empty, and retry states
- Secure authenticated API requests to the CMS backend

## Application Flow

1. Student opens the mobile application.
2. Student signs in using their clinic account.
3. The app authenticates against the CMS mobile API.
4. The student can view their available medical records.
5. The student can view recorded vital signs and other available health information.

## Technology

- Flutter
- Dart
- Material UI
- REST API
- JWT Bearer Authentication

## Project Structure

`text
lib/
├── main.dart
├── models/
│   └── medical_record.dart
├── screens/
│   ├── dashboard_screen.dart
│   ├── login_screen.dart
│   ├── medical_records_screen.dart
│   ├── medical_record_details_screen.dart
│   └── vital_signs_screen.dart
└── Services/
    └── api_service.dart
Backend Integration

The mobile app communicates with the CMS backend through its mobile API.

The API base URL is configured in:

lib/Services/api_service.dart

Update the baseUrl value when running the application against a different CMS backend or deployment environment.

The mobile API uses JWT Bearer tokens for authenticated student requests.

Main API Endpoints

The current mobile functionality uses endpoints under:

/api/mobile/

Key functionality includes:

Student authentication
Student information
Medical records
Vital signs

The mobile application only requests records belonging to the authenticated student.

Running the App
Requirements
Flutter SDK
Dart SDK included with Flutter
Android Studio or another supported Flutter development environment
A running CMS backend accessible from the mobile device/emulator
Setup
Clone this repository.
Open the project in Android Studio or VS Code.
Run:
flutter pub get
Configure the CMS API base URL in lib/Services/api_service.dart.
Start the CMS backend.
Connect an Android device/emulator or another supported Flutter target.
Run:
flutter run
Integration Notes

For integration with another CMS environment, update the API base URL and ensure the required mobile API endpoints and JWT authentication are available.

The mobile app is intended to consume the CMS backend; clinic staff continue to manage records through the main CMS system.

Project Status

Mobile application: Feature-complete for the current capstone scope.
