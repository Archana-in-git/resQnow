# Saved Medical Conditions Feature - Implementation Guide

## Overview

This document outlines the implementation of the **Saved Medical Conditions** feature for the resQnow application. Users can now save medical condition details from the Medical Conditions Detail page and access them later from a dedicated Saved Topics page.

## Features Implemented

### 1. **Save Functionality on Medical Conditions Detail Page**

- Added a functional **bookmark icon** on the condition detail page
- Icon shows filled state when a condition is saved, outline when not saved
- Users can click the icon to toggle save/unsave with visual feedback
- Success/error messages displayed via SnackBar notifications

### 2. **Persistent Storage using SQLite**

- Conditions are saved to local SQLite database
- Automatic persistence across app sessions
- All condition details preserved including:
  - ID, name, images, severity
  - First aid descriptions, precautions
  - Video URLs, required kits, FAQs
  - Doctor types, hospital locator links
  - Timestamp of when condition was saved

### 3. **Saved Topics Page**

- Dedicated page to display all saved medical conditions
- Grid-like card layout with:
  - Condition thumbnail image
  - Condition name
  - Severity badge (color-coded)
  - Saved date (formatted as "2h ago", "Yesterday", etc.)
  - Delete button to remove from saved
- Empty state with helpful message when no conditions are saved
- Error handling and loading states

### 4. **Easy Navigation**

- New route `/saved-topics` added to app router
- Conditions in the saved list can be tapped to view full details
- Delete confirmation dialog prevents accidental removals

## Technical Architecture

### File Structure

```
lib/features/saved_topics/
├── data/
│   ├── models/
│   │   └── saved_condition_model.dart
│   └── services/
│       └── saved_topics_service.dart
└── presentation/
    ├── controllers/
    │   └── saved_controller.dart
    └── pages/
        └── saved_topics_page.dart
```

### Key Components

#### 1. SavedConditionModel (`saved_condition_model.dart`)

- Wrapper model around `ConditionModel`
- Handles conversion to/from database format using JSON encoding
- Manages timestamp for saved conditions
- Provides factory methods for easy creation from `ConditionModel`

#### 2. SavedTopicsService (`saved_topics_service.dart`)

- **Singleton pattern** for database management
- Handles all SQLite operations:
  - `saveCondition()` - Save or update a condition
  - `getSavedConditions()` - Fetch all saved conditions ordered by save time
  - `deleteCondition()` - Remove a saved condition
  - `isConditionSaved()` - Check if condition is already saved
  - `clearAllConditions()` - Clear entire saved conditions table
- Automatic database initialization with proper schema

#### 3. SavedController (`saved_controller.dart`)

- Extends `ChangeNotifier` for reactive state management
- Manages saved conditions list and loading states
- Provides methods:
  - `loadSavedConditions()` - Load all conditions from database
  - `saveCondition()` - Save a new condition
  - `deleteCondition()` - Delete a condition
  - `isConditionSaved()` - Check save status
  - `clearAllConditions()` - Clear all conditions

#### 4. SavedTopicsPage (`saved_topics_page.dart`)

- Responsive UI with empty state handling
- Lists all saved conditions in card format
- Features:
  - Pull-to-refresh capability via loading state
  - Severity color coding (Critical=Red, High=Orange, Medium=Yellow, Low=Green)
  - Relative date formatting (2h ago, Yesterday, etc.)
  - Delete confirmation dialog
  - Tap to view full condition details

#### 5. Updated ConditionDetailPage

- Added imports for saved functionality
- Integrated save toggle functionality
- Icon state management (filled/outline)
- Status checking on page load
- User feedback via SnackBar

#### 6. Updated App Router

- Added new route: `/saved-topics` → `SavedTopicsPage`
- Maintains app navigation structure

## Database Schema

**Table: saved_conditions**

```sql
CREATE TABLE saved_conditions(
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  imageUrls TEXT NOT NULL,         -- JSON encoded
  severity TEXT NOT NULL,
  firstAidDescription TEXT NOT NULL, -- JSON encoded
  doNotDo TEXT NOT NULL,           -- JSON encoded
  videoUrl TEXT NOT NULL,
  requiredKits TEXT NOT NULL,      -- JSON encoded
  faqs TEXT NOT NULL,              -- JSON encoded
  doctorType TEXT NOT NULL,        -- JSON encoded
  hospitalLocatorLink TEXT NOT NULL,
  savedAt INTEGER NOT NULL         -- Unix timestamp
)
```

## User Flow

### Saving a Condition

1. User navigates to any Medical Condition Detail Page
2. Clicks the **bookmark icon** in the top-right
3. Condition is saved to local database
4. Icon changes to filled state
5. Success message confirms save

### Viewing Saved Conditions

1. User navigates to `/saved-topics` route
2. Sees list of all saved conditions
3. Can tap any condition to view full details
4. Can delete by clicking the trash icon and confirming

### Unsaving a Condition

1. User can unsave by clicking the filled bookmark icon in detail page
2. Or delete from the saved list using the delete button
3. Condition is removed from database

## Dependencies Used

- `sqflite` - SQLite database for local persistence
- `path` - Path handling for database
- `go_router` - Navigation routing
- `cached_network_image` - Loading remote images
- `provider` / `ChangeNotifier` - State management

## Error Handling

- Try-catch blocks on all database operations
- User-friendly error messages via SnackBar
- Graceful fallback to empty state on errors
- Loading states to prevent multiple simultaneous operations

## Performance Considerations

- Singleton pattern ensures single database connection
- Lazy database initialization
- Efficient queries with proper ordering (most recent first)
- JSON encoding for complex nested objects
- Minimal rebuilds using `ValueListenableBuilder` and `ListenableBuilder`

## Future Enhancements

- Cloud synchronization of saved conditions
- Filtering/sorting options (by severity, date, etc.)
- Search functionality within saved conditions
- Share saved conditions with others
- Export saved conditions as PDF
- Syncing with user profile across devices

## Testing the Feature

### Manual Testing Steps

1. Open Medical Conditions Detail page
2. Verify bookmark icon is clickable
3. Click to save - verify icon fills and success message appears
4. Click to unsave - verify icon outline returns and success message appears
5. Navigate to `/saved-topics`
6. Verify saved condition appears in list
7. Click condition card - should navigate to detail page
8. Return to saved list and click delete
9. Confirm deletion - condition should disappear from list

## Troubleshooting

- **Conditions not persisting**: Verify SQLite database permissions
- **Icon not updating**: Check that setState() is called after async operations
- **Navigation not working**: Ensure route is properly registered in AppRouter
- **Database errors**: Check that tables were created properly on first run

## Code Examples

### Save a Condition

```dart
final condition = controller.condition.value!;
final savedCondition = SavedConditionModel.fromCondition(condition);
await _savedTopicsService.saveCondition(savedCondition);
```

### Check if Saved

```dart
final isSaved = await _savedTopicsService.isConditionSaved(conditionId);
```

### Delete Condition

```dart
await _savedTopicsService.deleteCondition(conditionId);
```

### Load All Saved

```dart
final saved = await _savedTopicsService.getSavedConditions();
```
