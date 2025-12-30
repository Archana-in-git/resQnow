# Saved Topics Module - Admin Functionalities Reference

## Overview

This document outlines the **Admin Dashboard capabilities** for managing the Saved Topics Module in the ResQnow application. The Saved Topics Module allows users to save (bookmark) medical conditions for quick access. Since this is an academic project with a small user base, the admin features focus on **practical, essential operations** for managing user-saved content, monitoring saved topics, and maintaining data integrity.

**Current Status**: Users can save/unsave conditions locally; Admin monitoring and content management functionalities documented for future implementation.

**Technology**: SQLite (local storage), Flutter, Provider State Management

**Data Scope**: User bookmarked/saved medical conditions - stored locally on device

---

## Table of Contents

1. [Saved Topics Content Overview](#saved-topics-content-overview)
2. [Admin Management Capabilities](#admin-management-capabilities)
3. [User Saved Content Management](#user-saved-content-management)
4. [Saved Topics Analytics](#saved-topics-analytics)
5. [Admin Tasks & Workflows](#admin-tasks--workflows)
6. [Admin Dashboard Components](#admin-dashboard-components)
7. [Data Storage Schema](#data-storage-schema)
8. [Access Control & Permissions](#access-control--permissions)

---

## Saved Topics Content Overview

### What Users Can Save

**Saveable Content Types**:

- Medical Conditions (conditions from Medical Conditions module)
- First Aid Procedures (resources from First Aid Resources module)
- Emergency Procedures (from Emergency Numbers module)

**Current Implementation**:

- ✅ Save/unsave medical conditions locally
- ✅ View saved conditions list
- ✅ Delete individual saved conditions
- ✅ Clear all saved conditions (user action)
- ❓ Save resources (can be extended)
- ❓ Save emergency numbers (can be extended)

### Current Data Structure

**SavedConditionModel**:

```dart
{
  id: String,
  name: String,
  imageUrls: List<String>,
  severity: String (low|medium|high|critical),
  firstAidDescription: List<String>,
  doNotDo: List<String>,
  videoUrl: String,
  requiredKits: List<RequiredKit>,
  faqs: List<FaqItem>,
  doctorType: List<String>,
  hospitalLocatorLink: String,
  savedAt: long (timestamp in milliseconds)
}
```

---

## Admin Management Capabilities

### 1. View All Saved Conditions Across Users (**NOT YET IMPLEMENTED**)

**Responsibility**: Access aggregated data about what users are saving

**Admin Can View**:

- List of all saved conditions (across all users)
- Which conditions are saved most frequently
- Aggregate user save statistics
- Trending saved conditions
- User save patterns
- Timestamp of saves

**Current Limitation**:

- Saved conditions stored locally on each device
- No centralized backend tracking currently
- Would require Firestore implementation for cross-device tracking

**Future Enhancement**:
To enable admin visibility, saved conditions should be synced to Firestore:

```json
// Optional: Add to Firestore if needed
collection: "users/{userId}/saved_conditions"
{
  conditionId: String,
  conditionName: String,
  severity: String,
  savedAt: Timestamp,
  userNotes: String (optional)
}
```

**Use Cases**:

- Monitor which conditions users find important
- Identify gaps in resources (frequently saved but missing details)
- Plan content improvements based on save trends
- Identify critical conditions that need updates
- Understand user interests by region

---

### 2. Export User Saved Data (**NOT YET IMPLEMENTED**)

**Responsibility**: Generate reports on saved topics for analysis

**Admin Actions**:

- Export saved topics for a specific user (with permission)
- Generate aggregated statistics report
- Export to CSV/JSON format
- Search for specific user's saved conditions

**Use Cases**:

- Data analysis for content improvement
- User research (what's important to them)
- Privacy compliance (GDPR right to data)
- Backup user's saved conditions
- Migrate user data

**Future Implementation**:

```dart
// New use case to create:
class ExportUserSavedTopics {
  Future<String> exportAsJson(String userId);
  Future<String> exportAsCsv(String userId);
}
```

---

### 3. Monitor Saved Topics Quality (**NOT YET IMPLEMENTED**)

**Responsibility**: Ensure saved conditions still have current/accurate information

**Admin Can Check**:

- Verify saved condition still exists in system
- Check for outdated saved content
- Identify broken references
- Validate condition data integrity

**Quality Checks**:

- Condition data hasn't been deleted
- Condition information is still current
- Images/videos are still accessible
- Medical information is accurate
- No orphaned saves (references to deleted conditions)

**Use Cases**:

- Regular data integrity audits
- Identify when conditions are updated (users have old version saved)
- Alert users when saved conditions are updated
- Clean up invalid saves
- Maintain data quality

**Current Status**:

- ✅ Conditions can be saved as snapshot (full copy of data at save time)
- ❌ No mechanism to detect if original condition was updated
- ❌ No mechanism to detect if condition was deleted

---

### 4. Manage Saved Topics Display & Search (**NOT YET IMPLEMENTED**)

**Responsibility**: Control how saved conditions are displayed to users

**Admin Can Configure**:

- Sort order of saved conditions (by name, date, severity)
- Display format (list, grid, cards)
- Search functionality scope
- Category grouping
- Severity-based filtering display
- Custom views

**Current Implementation**:

- ✅ Displays in list format
- ✅ Sorted by saved date (newest first)
- ✅ Shows severity badge
- ✅ Shows save date
- ❌ No custom sorting options
- ❌ No filtering UI for users
- ❌ No search within saved conditions

**Configurable Display Options**:

```json
{
  sortBy: "savedAt" | "name" | "severity" | "custom",
  displayFormat: "list" | "grid" | "compact",
  enableSearch: true | false,
  enableGrouping: true | false,
  groupBy: "severity" | "category" | "none",
  enableFiltering: true | false,
  maxDisplayItems: 10 | 20 | 50
}
```

**Use Cases**:

- Optimize user experience based on usage patterns
- Prioritize critical conditions (sort by severity)
- Improve discoverability (search)
- Personalize view (grouping, filtering)
- Performance optimization (limit items)

---

### 5. Manage Saved Topics Retention (**NOT YET IMPLEMENTED**)

**Responsibility**: Control how long saved conditions are retained

**Admin Can Configure**:

- Auto-deletion policy (keep saved items for 30/60/90 days)
- Archive old saves instead of deleting
- Notification before deletion
- Backup before deletion

**Current Implementation**:

- Saves persist indefinitely
- Users can manually delete
- No automatic cleanup

**Retention Policies**:

```json
{
  retentionPolicy: "unlimited" | "archive_after_days" | "delete_after_days",
  retentionDays: 90,
  archiveBeforeDeletion: true,
  notifyBeforeDeletion: true,
  notificationDays: 7
}
```

**Use Cases**:

- Free up local storage
- Encourage app usage (saved items older than X days marked)
- Data privacy (auto-cleanup of old data)
- Archive important items before deletion
- Notification reminders (your saves expire soon)

---

### 6. User Saved Topics Audit (**NOT YET IMPLEMENTED**)

**Responsibility**: Track and monitor user save/unsave activities

**Admin Can View**:

- Save/unsave activity log
- Most recently saved conditions
- Most frequently saved conditions
- User save patterns
- Time-based analytics (when users save)
- Save persistence (do users revisit saved items)

**Metrics to Track**:

- Total saves per user
- Average saves per user
- Most saved conditions
- Least saved conditions
- Save frequency by time of day
- Save frequency by condition type
- User retention via saved items

**Use Cases**:

- Understand user behavior
- Identify important/critical conditions
- Measure feature engagement
- Plan content based on user interests
- Detect inactive users

---

## User Saved Content Management

### Current User-Facing Operations

#### 1. Save a Condition ✅

**User Action**: Tap "Save" button on any condition detail page
**Behind Scenes**:

- Condition snapshot saved to local SQLite
- SavedTopicsService.saveCondition() called
- Timestamp recorded
- SavedController notified

**Data Saved**: Full condition data at moment of save

---

#### 2. View Saved Conditions ✅

**User Action**: Navigate to "Saved Topics" page from bottom navigation
**Displays**:

- List of all saved conditions
- Ordered by save date (newest first)
- Severity badge per condition
- Save date/time indicator
- Tap to view full details
- Delete button per condition

---

#### 3. Delete Individual Saved Condition ✅

**User Action**: Tap delete icon on condition card, confirm
**Result**:

- Condition removed from saved list
- SavedTopicsService.deleteCondition() called
- Database updated
- UI refreshes

---

#### 4. Clear All Saved Conditions ✅

**User Action**: Call SavedController.clearAllConditions()
**Requires**: User confirmation
**Result**: All saved conditions deleted from local storage

---

## Saved Topics Analytics

### Proposed Admin Analytics Dashboard

**Metrics to Display**:

#### 1. Save Statistics

- Total saved conditions across app
- Average saves per user
- Most saved condition
- Least saved condition
- New saves today/week/month

#### 2. User Engagement

- Users with saves (vs without)
- Active savers (accessed saved in last 7 days)
- Inactive savers (no saves in 30 days)
- Average time between saves

#### 3. Content Popularity

- Top 10 most saved conditions
- Conditions with 0 saves
- Trending saves (growing saves over time)
- Seasonal patterns

#### 4. Data Health

- Orphaned saves (condition deleted, save remains)
- Stale saves (saved >90 days ago)
- Duplicate saves (same condition saved multiple times)
- Storage utilization

---

## Admin Tasks & Workflows

### Workflow 1: View Saved Topics Statistics

**Scenario**: Admin wants to see what conditions users are saving

**Steps**:

1. **Open Admin Dashboard**
2. **Navigate to**: "Saved Topics Analytics"
3. **View Summary**:
   - Total saves: 245
   - Active savers: 18 users
   - Most saved: "Cardiac Arrest" (23 saves)
   - Trending: "Anaphylaxis" (+5 this week)
4. **View Charts**:
   - Save frequency over time
   - Top saved conditions
   - Save distribution by severity
5. **Export Report** (optional):
   - Generate PDF/CSV report
   - Share with team

**Result**:

- Admin understands user priorities
- Can identify important conditions needing updates
- Can plan content improvements

---

### Workflow 2: Identify Broken Saved Condition References

**Scenario**: Admin deleted a condition, need to find users with saved references

**Steps**:

1. **Open Admin Dashboard**
2. **Go to**: "Saved Topics Quality Check"
3. **Search**: "Find orphaned saves"
4. **Results**:
   ```
   Condition: "Old Treatment Method" (deleted 2023)
   Users with save: 3
   Last accessed: 45 days ago
   Status: ORPHANED
   ```
5. **Actions**:
   - Option A: Recreate condition with updated info
   - Option B: Notify users, suggest alternative
   - Option C: Auto-cleanup the saves

**Result**: Data integrity maintained, users informed

---

### Workflow 3: Configure Saved Topics Display

**Scenario**: Admin wants to optimize saved topics view for better UX

**Steps**:

1. **Open Admin Dashboard**
2. **Navigate to**: "Saved Topics Configuration"
3. **Adjust Display Settings**:
   - Sort order: Change from "Saved Date" to "Severity"
   - Enable search within saved items
   - Enable grouping by severity
   - Set max display: 20 items per page
4. **Preview Changes**: See before/after
5. **Publish**: Apply to all users

**Result**:

- Saved topics more accessible
- Critical conditions appear first
- Search capability added
- Better user experience

---

### Workflow 4: Export User Saved Data (GDPR Compliance)

**Scenario**: User requests their saved data for privacy compliance

**Steps**:

1. **Open Admin Dashboard**
2. **Go to**: "User Data Management"
3. **Search User**: By email or ID
4. **View Their Saves**:
   - List all conditions they saved
   - Show save timestamps
   - Show last accessed date
5. **Export Data**:
   - Format: JSON or CSV
   - Include: All saved conditions, save dates, metadata
6. **Deliver to User**: Email or download link

**Result**: GDPR compliance, user privacy respected

---

### Workflow 5: Monitor Saved Topics Performance

**Scenario**: Admin wants to ensure feature works well for all users

**Steps**:

1. **Open Admin Dashboard**
2. **Go to**: "Saved Topics Performance"
3. **Monitor Metrics**:
   - Save operation success rate: 99.8%
   - Load saved conditions: avg 200ms
   - Database size growth: +5MB/week
   - Users affected by issues: 0
4. **View Logs**:
   - Recent save failures
   - Database errors
   - Sync issues (if cloud-synced)
5. **Take Action**: Optimize, alert, or rollback if needed

**Result**: Feature stability ensured

---

### Workflow 6: Manage Saved Topics Retention Policy

**Scenario**: Admin wants to implement auto-cleanup of old saves

**Steps**:

1. **Open Admin Dashboard**
2. **Go to**: "Retention Settings"
3. **Current Policy**:
   - Saves kept: indefinitely
4. **New Policy**:
   - Archive saves older than 90 days
   - Notify users before archiving (7 days before)
   - Keep archives for 1 year
5. **Preview Impact**:
   - Estimate 45 saves to be archived
   - 12 users will be affected
6. **Schedule Implementation**:
   - Date: Next month
   - Gradual rollout: Yes
7. **Save & Confirm**

**Result**: Storage optimized, data preserved, users informed

---

## Admin Dashboard Components

### Recommended Admin Pages

#### 1. **Saved Topics Overview Page**

(saved_topics_admin_overview_page.dart - to be created)

**Purpose**: Main dashboard for saved topics management

**Components**:

- AppBar: "Saved Topics Management"
- Tabs:
  - "Overview"
  - "Analytics"
  - "Quality Check"
  - "Configuration"
  - "User Data"

**Overview Tab**:

- Key Statistics Cards:
  - Total saves
  - Active savers
  - Avg saves per user
  - Most saved condition
- Recent Saves List
- Top Saved Conditions
- User Engagement Gauge

**Analytics Tab**:

- Time-series chart: Saves over time
- Bar chart: Top 10 conditions
- Pie chart: Saves by severity
- Heatmap: Save patterns by time
- Export button

**Quality Check Tab**:

- List of orphaned saves
- Stale saves (older than 90 days)
- Duplicate saves
- Invalid references
- Actions: Delete, Notify, Archive

**Configuration Tab**:

- Display settings
- Sort order options
- Search configuration
- Retention policy
- Notification settings
- Save button to apply

**User Data Tab**:

- Search user by email/ID
- View their saved items
- Export user data
- Delete user saves
- View save history

---

#### 2. **Saved Condition Detail Inspector**

(saved_condition_inspector_dialog.dart - to be created)

**Purpose**: Inspect specific saved condition details

**Shows**:

- Condition name & ID
- Who saved it (user email/ID)
- When saved (timestamp)
- Last accessed date
- Data snapshot (what was saved)
- Current condition status (updated? deleted?)
- Actions: View original, Notify user, Delete

---

#### 3. **Saved Topics Analytics Dashboard**

(saved_topics_analytics_page.dart - to be created)

**Purpose**: Detailed analytics on saving behavior

**Charts & Metrics**:

- Save frequency over time (line chart)
- Top 20 most saved conditions (bar chart)
- Least saved conditions (sorted)
- Saves by severity distribution (pie chart)
- Hourly/daily save patterns (heatmap)
- User save distribution (histogram)
- New vs returning savers (line chart)
- Engagement metrics by condition type

**Export Options**:

- PDF report
- CSV data
- JSON snapshot

---

## Data Storage Schema

### SQLite Table (Local Storage)

**Table**: `saved_conditions`

**Columns**:

```sql
CREATE TABLE saved_conditions(
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  imageUrls TEXT NOT NULL,           -- JSON string of URLs
  severity TEXT NOT NULL,            -- low|medium|high|critical
  firstAidDescription TEXT NOT NULL, -- JSON string of steps
  doNotDo TEXT NOT NULL,             -- JSON string of warnings
  videoUrl TEXT NOT NULL,
  requiredKits TEXT NOT NULL,        -- JSON of RequiredKit objects
  faqs TEXT NOT NULL,                -- JSON of FaqItem objects
  doctorType TEXT NOT NULL,          -- JSON array of doctor types
  hospitalLocatorLink TEXT NOT NULL,
  savedAt INTEGER NOT NULL           -- Unix timestamp (ms)
)
```

---

### Proposed Firestore Collection (for Admin Features)

**For Future Implementation** (optional, enables admin features):

**Collection Path**: `saved_topics_analytics`

**Document Path**: `saved_topics_analytics/{conditionId}`

```json
{
  "conditionId": String,
  "conditionName": String,
  "totalSaves": Number,
  "uniqueUsers": Number,
  "lastSavedAt": Timestamp,
  "firstSavedAt": Timestamp,
  "avgRetention": Number (days),
  "saves": [
    {
      "userId": String (hashed for privacy),
      "savedAt": Timestamp,
      "lastAccessedAt": Timestamp,
      "status": "active" | "archived" | "deleted"
    }
  ]
}
```

**Alternative Collection** (tracks saves per user):

**Collection Path**: `users/{userId}/saved_topics_log`

**Document**: Auto-generated per save

```json
{
  "conditionId": String,
  "conditionName": String,
  "severity": String,
  "savedAt": Timestamp,
  "unsavedAt": Timestamp (null if still saved),
  "lastAccessedAt": Timestamp,
  "notes": String (user notes, optional)
}
```

---

## Access Control & Permissions

### Admin Role Capabilities

**Admin Can**:

- ✅ View all saved conditions statistics (aggregate)
- ✅ View which conditions are saved most
- ✅ Monitor save/unsave activity
- ✅ Export analytics reports
- ✅ Configure display settings
- ✅ Set retention policies
- ✅ Identify quality issues
- ✅ Export user data (with permission/compliance)
- ✅ View user-specific saves (only if needed for support)
- ✅ Receive alerts on anomalies

**Admin Cannot** (Restricted):

- ❌ Delete user saves without cause (audit trail needed)
- ❌ Modify user save timestamps (data integrity)
- ❌ Access user notes/personal data without purpose
- ❌ Share user save data externally
- ❌ Make saves on behalf of users

**Regular User Can**:

- ✅ Save conditions
- ✅ View own saved conditions
- ✅ Delete own saves
- ✅ Clear all own saves
- ✅ Add notes to saves (future)
- ❌ View other users' saves
- ❌ Modify app display of saves
- ❌ Access analytics

---

### Implementation Approach

**SQLite Access Control**:

- Local storage: No authentication needed (user-only data)
- Service layer restricts operations to authenticated user

**Firestore Access Control** (if implemented):

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User-specific saves (if synced)
    match /users/{userId}/saved_topics_log/{document=**} {
      allow read: if request.auth.uid == userId;
      allow create: if request.auth.uid == userId;
      allow delete: if request.auth.uid == userId;
      allow update: if request.auth.uid == userId;
    }

    // Admin analytics (aggregate data, no PII)
    match /saved_topics_analytics/{document=**} {
      allow read: if request.auth != null && 'admin' in request.auth.token.claims;
      allow write: if request.auth != null && 'admin' in request.auth.token.claims;
    }
  }
}
```

---

## Summary of Implementable Admin Functionalities

| Operation                      | Current Status | Can Be Implemented       | Component           | Priority |
| ------------------------------ | -------------- | ------------------------ | ------------------- | -------- |
| **View Save Statistics**       | ❌ No          | ✅ Yes                   | Analytics dashboard | High     |
| **Monitor Saved Conditions**   | ❌ No          | ✅ Yes                   | Overview page       | High     |
| **Export Analytics Reports**   | ❌ No          | ✅ Yes                   | Report generator    | Medium   |
| **Configure Display Settings** | ❌ No          | ✅ Yes                   | Config page         | High     |
| **Set Retention Policies**     | ❌ No          | ✅ Yes                   | Settings page       | Medium   |
| **Quality Checks**             | ❌ No          | ✅ Yes                   | Audit tool          | Medium   |
| **Export User Data**           | ❌ No          | ✅ Yes (with permission) | Data exporter       | Low      |
| **View Save Activity Logs**    | ❌ No          | ✅ Yes                   | Activity page       | Low      |
| **Identify Orphaned Saves**    | ❌ No          | ✅ Yes                   | Quality checker     | Medium   |
| **Send Save Notifications**    | ❌ No          | ✅ Yes (future)          | Notifier            | Low      |

---

## Pages to Be Implemented

### 1. `saved_topics_admin_overview_page.dart`

**Purpose**: Main admin dashboard for saved topics management
**Tabs**:

- Overview (statistics, recent saves)
- Analytics (charts, trends)
- Quality Check (orphaned saves, issues)
- Configuration (display settings, retention)
- User Data (export, view user saves)

### 2. `saved_topics_analytics_page.dart`

**Purpose**: Detailed analytics and reporting
**Features**:

- Multiple chart types (line, bar, pie, heatmap)
- Exportable reports
- Filterable data
- Time range selection

### 3. `saved_condition_inspector_dialog.dart`

**Purpose**: Inspect individual saved condition
**Shows**:

- Saved data details
- Save metadata
- Current vs saved status
- Actions (delete, notify)

### 4. `saved_topics_config_page.dart`

**Purpose**: Configure display and retention settings
**Settings**:

- Sort order
- Display format
- Search/filter options
- Retention policy
- Notification settings

---

## Use Cases to Implement

### Core Use Cases

```
lib/domain/usecases/
├── get_saved_topics_statistics.dart
├── get_most_saved_conditions.dart
├── export_saved_topics_analytics.dart
├── update_saved_topics_configuration.dart
├── get_user_saved_conditions.dart
└── identify_orphaned_saves.dart
```

### Service Layer

```dart
// Enhancements to SavedTopicsService:
Future<Map<String, dynamic>> getSaveStatistics();
Future<List<Map>> getTopSavedConditions(int limit);
Future<Map> getConditionSaveMetrics(String conditionId);
Future<List<Map>> getOrphanedSaves();
Future<List<Map>> getStalesaves(int days);
Future<String> exportAsJson(String userId);
Future<String> exportAsCsv(String userId);
```

---

## Implementation Notes for Developer

### Phase 1: Analytics Foundation

1. Add Firestore collection: `saved_topics_analytics`
2. Create analytics service layer
3. Build overview dashboard
4. Implement basic charts

### Phase 2: Configuration & Management

1. Create configuration service
2. Build settings pages
3. Implement display customization
4. Add retention policies

### Phase 3: Quality & Compliance

1. Build quality check tools
2. Implement data export
3. Add activity logging
4. Create audit reports

### Phase 4: User Communication

1. Add notification system
2. Implement alerts
3. Add save reminders
4. Send status updates

---

## Conclusion

The Saved Topics Module has **significant admin management potential** despite being a local-storage feature. Key implementable functionalities include:

✅ **View & Monitor Statistics** - Understand what users save  
✅ **Configure Display Settings** - Optimize UX  
✅ **Set Retention Policies** - Manage storage  
✅ **Quality Monitoring** - Detect issues  
✅ **Analytics & Reporting** - Track engagement  
✅ **Data Export** - Privacy compliance  
✅ **Activity Logging** - Audit trail

While currently no backend tracking, these admin functions can be implemented with optional Firestore integration for cross-device analytics. The module is suitable for meaningful admin oversight.

**Implementation Status**: Documentation complete for future developer implementation.

---

**Document Status**: Admin Functionalities Reference Guide
**Applicable for Admin Management**: ✅ YES
**Recommended for Implementation**: ✅ YES (moderate priority for analytics & insights)
**Scope**: Academic project - practical content management and monitoring
