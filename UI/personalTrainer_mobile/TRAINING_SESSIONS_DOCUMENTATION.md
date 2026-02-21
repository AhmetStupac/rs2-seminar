# Training Session Management Screens

This document describes the two new screens created for managing training sessions in the Personal Trainer Mobile app.

## Created Screens

### 1. TrainingSessionBookingScreen
**Location:** `lib/screens/training_session_booking_screen.dart`

**Purpose:** Allows clients to book training sessions with their selected trainer.

**Features:**
- Calendar view for selecting training date
- Horizontal scrollable time slot picker (6:00 AM - 6:00 PM)
- Real-time availability checking
- Visual feedback for slot availability (green for available, red for unavailable)
- Booking confirmation with trainer details

**Usage Example:**
```dart
import 'package:personaltrainer_mobile/screens/training_session_booking_screen.dart';
import 'package:personaltrainer_mobile/models/personal_trainer.dart';

// Navigate to booking screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => TrainingSessionBookingScreen(
      trainer: selectedTrainer, // PersonalTrainer object
    ),
  ),
);
```

**UI Colors:**
- Background: Beige (#F5E6D3)
- Primary (selected/buttons): Orange (#E8B44A)
- Available status: Green (#4CAF50)
- Unavailable status: Red

### 2. TrainingSessionsListScreen
**Location:** `lib/screens/training_sessions_list_screen.dart`

**Purpose:** Displays all scheduled training sessions for the logged-in client.

**Features:**
- List of all training sessions sorted by date (newest first)
- Status indicators with colored circles:
  - Green: Confirmed/Active
  - Orange: Pending
  - Red: Cancelled
  - Grey: No Show
- Session details including:
  - Date and time
  - Trainer name
  - Gym location
  - Duration
  - Status label
  - Notes (if any)
  - Cancellation reason (if cancelled)
- Action buttons:
  - Delete icon: Cancel session (if cancellable)
  - Calendar icon: Reschedule session (if editable)
- Pull to refresh functionality
- Empty state handling
- Error state handling with retry option

**Usage Example:**
```dart
import 'package:personaltrainer_mobile/screens/training_sessions_list_screen.dart';

// Navigate to sessions list
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const TrainingSessionsListScreen(),
  ),
);
```

## Integration Points

### Where to Add Navigation

1. **Personal Trainer Detail Screen:**
   Add a "Book Session" button that navigates to `TrainingSessionBookingScreen`:
   ```dart
   ElevatedButton(
     onPressed: () {
       Navigator.push(
         context,
         MaterialPageRoute(
           builder: (context) => TrainingSessionBookingScreen(
             trainer: widget.trainer,
           ),
         ),
       );
     },
     child: const Text('Book Training Session'),
   )
   ```

2. **Main Navigation/Dashboard:**
   Add a menu item or button to view all sessions:
   ```dart
   ListTile(
     leading: const Icon(Icons.calendar_today),
     title: const Text('My Training Sessions'),
     onTap: () {
       Navigator.push(
         context,
         MaterialPageRoute(
           builder: (context) => const TrainingSessionsListScreen(),
         ),
       );
     },
   )
   ```

## API Dependencies

Both screens use the `TrainingSessionProvider` which requires the following API endpoints:

### TrainingSessionProvider Methods Used:
- `get(filter)` - Get list of training sessions
- `insert(request)` - Create new training session
- `cancel(id, request)` - Cancel a training session
- `getAvailableSlots(trainerId, date, durationMinutes)` - Get available time slots
- `checkAvailability(trainerId, scheduledDateTime, durationMinutes)` - Check if specific slot is available
- `confirm(id)` - Confirm a session (trainer only)

## Status Codes

The training session status is represented by integers:
- `0` - Pending
- `1` - Confirmed
- `2` - Completed
- `3` - Cancelled
- `4` - No Show

## Models Used

- `TrainingSession` - Main session data model
- `TrainingSessionUpsertRequest` - Request model for creating/updating sessions
- `TrainingSessionCancelRequest` - Request model for cancelling sessions
- `PersonalTrainer` - Trainer information

## Authentication

Both screens use `AuthProvider.userId` to get the current logged-in user's ID for filtering sessions.

## Styling

Both screens follow the app's design language with:
- Beige/cream background (#F5E6D3)
- Orange/yellow accent color (#E8B44A)
- Clean, modern UI with rounded corners
- Status-based color coding
- Consistent spacing and padding

## Future Enhancements

Potential improvements:
1. Implement actual reschedule functionality (currently shows "coming soon" message)
2. Add push notifications for session reminders
3. Add recurring session booking
4. Add trainer availability calendar view
5. Add session filtering by status
6. Add session search functionality
7. Add trainer notes display after session completion
