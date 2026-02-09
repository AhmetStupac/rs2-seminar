# personaltrainer_mobile

A Flutter desktop/web application for personal trainer management.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Configuration

### Password Recovery Setup

The app now supports URL-based password recovery. When users click the password reset link in their email, they will be redirected to the app.

**Important Backend Configuration:**

Your backend must send password recovery emails with the **frontend URL**, not the backend URL.

Example recovery link format:
```
http://localhost:8080/#/reset-password?token={RESET_TOKEN}
```

**Route Configuration:**
- Login: `/`
- Register: `/register`
- Training Plans: `/training-plans`
- Reset Password: `/reset-password?token=xxx`
- Change Password: `/change-password`

### Running the App

For web:
```bash
flutter run -d chrome --web-port=8080
```

For Windows desktop:
```bash
flutter run -d windows
```

### Ports

- **Frontend (Flutter web):** `http://localhost:8080` (default)
- **Backend API:** `https://localhost:7093`
