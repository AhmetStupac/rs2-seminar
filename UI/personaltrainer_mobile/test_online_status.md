# Testing Online Status Feature

## Prerequisites
- Backend SignalR hub running on `https://localhost:7093/hubs/presence`
- At least 2 user accounts in your database

## Test Scenario 1: Single User Login
1. Launch the app
2. Log in with User A
3. Check console for: `✅ SignalR Connected successfully`
4. Navigate to User List Screen
5. User A should NOT see a green dot next to their own name (they're viewing themselves)

## Test Scenario 2: Multiple Users Online
1. **Window 1**: Log in with User A
2. **Window 2**: Open another instance and log in with User B
3. In Window 1, navigate to User List Screen
4. You should see a green dot next to User B's name
5. In Window 2, navigate to User List Screen
6. You should see a green dot next to User A's name

## Test Scenario 3: User Goes Offline
1. With both users logged in (from Scenario 2)
2. Close Window 2 (User B logs out)
3. In Window 1, check User List Screen
4. Green dot should disappear from User B's name
5. Console should show: `👤 User offline: [User B email]`

## Troubleshooting

### No green dots appearing?
- Check if SignalR is connected: Look for `✅ SignalR Connected successfully` in console
- Verify backend is running and accepting connections
- Check if user IDs match between frontend and backend

### Connection fails?
- Check console for: `❌ SignalR Connection error:`
- Verify credentials are saved: Look for `📝 Saved credentials` logs
- Check backend hub URL is correct

### Green dot doesn't disappear when user logs out?
- Backend may not be triggering `UserOffline` event
- Check backend hub disconnect handling

## Debug Commands
```dart
// In user_list_screen.dart, add this to see online users:
@override
void initState() {
  super.initState();
  _loadUsers();
  
  // Debug: Print online users
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final signalR = Provider.of<SignalRProvider>(context, listen: false);
    print("🟢 Online users: ${signalR.onlineUsers.map((u) => u.userId).toList()}");
  });
}
```
