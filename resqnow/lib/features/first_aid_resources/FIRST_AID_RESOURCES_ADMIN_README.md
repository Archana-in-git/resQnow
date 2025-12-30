# First Aid Resources Module - Admin Functionalities Reference

## Overview

This document outlines the **Admin Dashboard capabilities** for managing first aid resources in the ResQnow First Aid Resources Module. First aid resources are critical educational content that help users learn life-saving techniques. Since this is an academic project with a small user base, the admin features focus on **practical, essential operations** for managing educational resources.

**Current Status**: Read-only user implementation; Admin functionalities documented for future implementation.

**Technology**: Firebase Firestore, Flutter, Provider State Management

---

## Table of Contents

1. [Resource Management](#resource-management)
2. [Resource Configuration](#resource-configuration)
3. [Search & Display](#search--display)
4. [Admin Tasks & Workflows](#admin-tasks--workflows)
5. [Admin Dashboard Components](#admin-dashboard-components)
6. [Firestore Schema for Admin](#firestore-schema-for-admin)
7. [Access Control](#access-control)

---

## Resource Management

### 1. View All Resources

**Responsibility**: ResourceService.getResources() (already exists for users)

**Admin Actions**:

- Fetch complete list of all first aid resources
- Display all available educational content
- View resource metadata and details
- Monitor total resource count
- Check featured resources

**Data Visible**:

- Resource name
- Description
- Categories
- Tags (search keywords)
- Image count
- Featured status
- Creation/modification timestamps

**Use Cases**:

- Get system overview
- Monitor content library
- Verify resource availability
- Audit resource collection

**Current Implementation**: ✅ ResourceController.fetchResources()

---

### 2. View Individual Resource Details

**Responsibility**: ResourceService.getResourceById() (already exists for users)

**Admin Can View**:

- Resource name
- Full description
- Categories (multiple)
- Tags
- Image URLs (all images)
- When to use (usage guidance)
- Safety tips
- Professional tips
- Featured status
- Creation timestamp
- Last modified timestamp

**Use Cases**:

- Review specific resource content
- Verify accuracy of information
- Check images are loading
- Audit safety information
- Plan updates or modifications

**Current Implementation**: ✅ ResourceDetailPage (displays all data)

---

### 3. Create New Resource (**NOT YET IMPLEMENTED**)

**Responsibility**: ResourceService.addResource() (to be implemented)

**Admin Actions**:

- Add new first aid resource
- Define resource information
- Upload/link images
- Assign categories
- Add search tags
- Set guidance text

**Data To Create**:

- `name`: Resource title (e.g., "CPR for Adults")
- `description`: Detailed explanation
- `category`: List of categories (e.g., ["Emergency Care", "Resuscitation"])
- `tags`: Search keywords (e.g., ["cpr", "heart attack", "unconscious"])
- `imageUrls`: Educational images (one or multiple)
- `whenToUse`: When to apply this technique
- `safetyTips`: Important safety considerations
- `proTip`: Professional/expert advice
- `isFeatured`: Display on homepage (boolean)
- `createdAt`: Auto-generated timestamp
- `updatedAt`: Auto-generated timestamp

**Validation Required**:

- Name: Non-empty, 3+ characters
- Description: Clear, helpful text
- Categories: At least one category
- Tags: At least one tag for searchability
- Images: At least one image URL
- Image URLs: Valid HTTP/HTTPS URLs

**Use Cases**:

- Add new first aid technique (e.g., "Heimlich Maneuver")
- Include emergency response procedure
- Add wound care instructions
- Document recovery techniques
- Create specialized medical guidance

**Future Implementation**: Will create ResourceAdminController with createResource()

---

### 4. Edit Resource Information (**NOT YET IMPLEMENTED**)

**Responsibility**: ResourceService.updateResource() (to be implemented)

**Admin Can Edit**:

- Resource name
- Description
- Categories
- Tags
- Image URLs
- When to use guidance
- Safety tips
- Professional tips
- Featured status

**Admin Cannot Edit** (Protected):

- Resource ID
- Creation timestamp
- Price field (reserved for future shopping feature)

**Important**:

- Modification timestamp auto-updates
- Creation timestamp preserved
- All changes effective immediately
- Previous versions not tracked (no version history)

**Use Cases**:

- Correct inaccurate information
- Update based on latest guidelines
- Improve descriptions
- Add additional images
- Adjust category assignments
- Update safety information
- Reorganize tags for better search

**Example Scenarios**:

1. **Outdated Guidelines**: Update CPR instructions to match latest medical standards
2. **Better Images**: Replace low-quality images with better illustrations
3. **Expanded Content**: Add professional tips based on user feedback
4. **Recategorization**: Move resource to different categories
5. **Enhanced Search**: Add missing tags for keyword discovery

**Future Implementation**: Will create updateResourceData() method

---

### 5. Delete Resource (**NOT YET IMPLEMENTED**)

**Responsibility**: ResourceService.deleteResource() (to be implemented)

**Admin Actions**:

- Permanently remove resource from system
- Delete all associated metadata
- Remove from user view

**Important Considerations**:

- **Hard Delete**: Resource completely removed from Firestore
- **Data Loss**: Cannot be recovered without backup
- **Recommendation**: Use visibility toggle instead (when implemented)
- **Confirmation Required**: Must confirm deletion dialog

**Use Cases**:

- Remove obsolete techniques (replaced by newer methods)
- Delete duplicate resources
- Remove test/temporary entries
- Archive techniques no longer relevant
- Clean up incorrect information

**Future Implementation**: Will create deleteResource() method with confirmation

---

### 6. Toggle Featured Status (**NOT YET IMPLEMENTED**)

**Responsibility**: Firestore update of `isFeatured` field (to be implemented)

**Admin Actions**:

- Mark resource as featured (isFeatured = true)
- Remove from featured (isFeatured = false)
- Display featured resources on homepage
- Promote important techniques

**Use Cases**:

- Feature critical life-saving techniques
- Highlight seasonal content (e.g., heatstroke in summer)
- Promote new resources
- Emphasize commonly-needed techniques
- Rotate featured content

**Current User View**: ResourceListPage already displays featured indicator with star icon

**Future Admin Implementation**:

```dart
// Admin can toggle:
await resourceService.toggleFeatured(resourceId);

// Or during edit:
await resourceService.updateResource(id, {
  ...otherFields,
  isFeatured: true/false
});
```

---

## Resource Configuration

### 1. Category Management

**Purpose**: Organize resources by medical/emergency topics

**Current Categories** (inferred from code):

- Emergency Care
- Resuscitation
- Wound Management
- Fracture Management
- Poison Control
- Allergic Reactions
- Environmental Emergencies
- Cardiac Emergencies
- Choking/Airway
- Burns
- (More can be added)

**Admin Responsibilities**:

- Assign correct categories to resources
- Keep categories consistent
- Use meaningful category names
- Review and update category assignments
- Maintain category hierarchy

**Multiple Categories**:

- Resources can belong to 2+ categories
- Enables better search/discovery
- Example: "CPR" in both "Resuscitation" AND "Cardiac Emergencies"

**Display Logic**:

- Category chips shown on resource cards
- Users can filter by category
- Categories used in search

**Future Admin Implementation**:

```dart
// Can assign multiple categories:
final categories = ["Emergency Care", "Resuscitation"];

// Edit resource with new categories:
await resourceService.updateResource(id, {
  category: newCategories,
  updatedAt: DateTime.now(),
});
```

---

### 2. Search Tags Management

**Purpose**: Enable quick resource discovery via keywords

**Current Implementation**: ResourceController.searchResources() searches by:

- Resource name
- Description
- Tags
- Categories

**Admin Responsibilities**:

- Add comprehensive tags for each resource
- Include common search terms
- Include medical terminology
- Include layman's terms
- Ensure discoverability

**Tag Examples**:

```
Resource: "CPR for Adults"
Tags: [
  "cpr",
  "cardiopulmonary resuscitation",
  "heart attack",
  "cardiac arrest",
  "unconscious",
  "unresponsive",
  "chest compression",
  "resuscitation",
  "lifesaving"
]
```

**Why Multiple Tags Matter**:

- User searches "heart attack" → Finds CPR guide
- User searches "unconscious" → Finds CPR guide
- User searches "chest compression" → Finds CPR guide
- Same resource found via multiple search terms

**Future Admin Implementation**: Edit tags during resource creation/editing

---

### 3. Image Management

**Purpose**: Provide visual learning aids

**Image Requirements**:

- Store as URLs (not files)
- Support multiple images per resource
- Multiple images = carousel view (already in ResourceDetailPage)

**Admin Responsibilities**:

- Upload images to cloud storage (Firebase Storage)
- Generate public URLs
- Include images showing step-by-step technique
- Ensure images are clear and instructional
- Verify images load correctly

**Current User View**: ResourceDetailPage shows image carousel with page indicators

**Example Image URLs**:

```
https://storage.googleapis.com/resqnow/resources/cpr/step1.jpg
https://storage.googleapis.com/resqnow/resources/cpr/step2.jpg
https://storage.googleapis.com/resqnow/resources/cpr/step3.jpg
```

**Future Admin Implementation**:

```dart
final imageUrls = [
  "https://cdn.example.com/image1.jpg",
  "https://cdn.example.com/image2.jpg",
  "https://cdn.example.com/image3.jpg",
];

await resourceService.updateResource(id, {
  imageUrls: imageUrls,
});
```

---

### 4. Content Sections Management

**Purpose**: Organize educational information

**Admin Can Set**:

- `description`: Main explanation (required)
- `whenToUse`: When to apply technique (optional but recommended)
- `safetyTips`: Critical safety information (optional but recommended)
- `proTip`: Professional advice (optional, nice-to-have)

**User View**: All fields displayed in ResourceDetailPage

**Example Content**:

```
Resource: "Heimlich Maneuver"

Description:
"Emergency technique to dislodge object from airway. Stand behind person,
place fist above navel, thrust inward and upward with quick motions.
Repeat until object is dislodged or person becomes unconscious."

When to Use:
"When person is choking and unable to cough, speak, or breathe."

Safety Tips:
"Do NOT perform if person is partially breathing. Be prepared for person
to vomit after object removal. Place in recovery position."

Pro Tip:
"If person becomes unconscious, begin CPR immediately. Chest compressions
may dislodge object."
```

**Future Admin Implementation**: Edit all content sections during resource management

---

## Search & Display

### 1. Search by Resource Name

**Purpose**: Find resources by title

**Search Behavior**:

- Case-insensitive matching
- Partial name matching
- Real-time filtering

**Query Examples**:

```
Admin/User searches: "cpr"
Results: CPR for Adults, CPR for Infants, Hands-Only CPR

Admin/User searches: "heimlich"
Results: Heimlich Maneuver, Choking Relief

Admin/User searches: "wound"
Results: Wound Care, Minor Wounds, Severe Wounds
```

**Current Implementation**: ✅ ResourceController.searchResources() includes name matching

---

### 2. Filter by Category

**Purpose**: Group resources by medical topic

**Current Categories** (from code analysis):

- Emergency Care
- Resuscitation
- Wound Management
- Fracture Management
- Poison Control
- Allergic Reactions
- Environmental Emergencies
- Cardiac Emergencies
- Choking/Airway
- Burns

**Filter UI** (already in ResourceListPage):

- Show available categories as filter chips
- Multi-select (can select multiple categories)
- Real-time filtering

**Use Cases**:

- Find all resuscitation techniques
- View all wound care resources
- Access allergy-related information
- Browse cardiac emergency resources

**Current Implementation**: ✅ ResourceController.toggleCategory() + \_applyFilters()

---

### 3. Search by Tags

**Purpose**: Discover resources via keywords

**Search Examples**:

```
Search: "heart attack" → Finds: CPR, AED Use, Cardiac Emergencies
Search: "unconscious" → Finds: CPR, Recovery Position, Head Injuries
Search: "chest" → Finds: CPR, Rib Fracture, Chest Wounds
```

**Comprehensive Tagging Strategy**:

- Medical terms
- Common terminology
- Layman's language
- Abbreviations (e.g., "CPR" instead of just "Cardiopulmonary Resuscitation")
- Related keywords

**Current Implementation**: ✅ ResourceController.searchResources() searches tags

---

### 4. View Featured Resources

**Purpose**: Highlight important resources

**Current Implementation**:

- ✅ ResourceService.getFeaturedResources() (exists but not used by default in list)
- ✅ ResourceDetailPage shows star icon for featured resources

**Future Admin Use**:

- Display featured resources first on homepage
- Rotate featured resources seasonally
- Highlight life-critical techniques
- Promote new high-quality content

---

## Admin Tasks & Workflows

### Workflow 1: Create New Resource

**Scenario**: Admin wants to add "Recovery Position" technique

**Steps**:

1. **Open Resource Creation Form** (to be implemented in resource_admin_detail_page.dart)
2. **Enter Basic Information**:
   - Name: "Recovery Position"
   - Description: "Safe position for unconscious breathing person to prevent choking..."
3. **Select/Create Categories**:
   - Select: "Emergency Care", "Resuscitation"
4. **Add Search Tags**:
   - Tags: ["recovery position", "unconscious", "breathing", "side position", "airway"]
5. **Upload Images**:
   - Add 3-4 step-by-step images
   - Provide image URLs
6. **Add Guidance Content**:
   - When to Use: "When person is unconscious but breathing"
   - Safety Tips: "Do NOT move if spinal injury suspected"
   - Pro Tip: "Check airway is clear, monitor breathing continuously"
7. **Set Featured Status**:
   - Toggle: "Featured" (Yes/No)
8. **Save to Firestore**:
   - Auto-generates ID and timestamps
   - Resource immediately available to users

**Result**:

```json
{
  "id": "auto_generated_id",
  "name": "Recovery Position",
  "description": "Safe position for unconscious breathing person...",
  "category": ["Emergency Care", "Resuscitation"],
  "tags": ["recovery position", "unconscious", "breathing", "side position"],
  "imageUrls": ["url1", "url2", "url3", "url4"],
  "whenToUse": "When person is unconscious but breathing",
  "safetyTips": "Do NOT move if spinal injury suspected",
  "proTip": "Check airway is clear, monitor breathing",
  "price": 0.0,
  "isFeatured": false,
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

**Time to Complete**: ~5-10 minutes per resource

---

### Workflow 2: Edit Existing Resource

**Scenario**: Update CPR technique based on new medical guidelines

**Steps**:

1. **Navigate to Admin Dashboard**
2. **Find Resource**: Search for "CPR for Adults"
3. **Open Edit Form**:
   - All fields pre-populated with current data
4. **Update Information**:
   - Modify description with new guidelines
   - Update compression depth from "1.5 inches" to "2 inches"
   - Modify compression rate if changed
5. **Update Images** (optional):
   - Add new instructional images
   - Remove outdated images
   - Reorder images for clarity
6. **Update Tags** (optional):
   - Add missing search keywords
   - Remove irrelevant tags
7. **Update Category** (optional):
   - Add "Cardiac Emergencies" if not present
   - Improve categorization
8. **Save Changes**:
   - Updated timestamp auto-updates
   - Creation timestamp preserved
   - Changes immediately effective

**Result**: Users see updated content on next app refresh

---

### Workflow 3: Delete Resource

**Scenario**: Remove outdated or incorrect resource

**Steps**:

1. **Find Resource** in admin dashboard
2. **Review Before Deletion**:
   - View resource details
   - Confirm it needs to be removed
3. **Click Delete Button**:
   - Confirmation dialog appears
   - Shows resource name
   - Asks "Are you sure?"
4. **Confirm Deletion**:
   - Permanently removes from Firestore
   - No longer visible to users
5. **Verify Removal**:
   - Resource disappears from list
   - Success notification shown

**Caution**: Hard delete = permanent loss (unless backed up)

**Better Alternative** (if implemented):

- Deactivate instead of delete
- Use a `isActive` field to hide resource
- Can reactivate anytime

---

### Workflow 4: Feature/Promote Resource

**Scenario**: Highlight "CPR for Adults" as critical lifesaving technique

**Steps**:

1. **Find Resource** in list
2. **Open Resource**
3. **Toggle Featured Status**:
   - Check: "Mark as Featured"
4. **Save Changes**
5. **Verify**:
   - Star icon appears on resource card
   - Resource shows in featured section
   - Appears in getFeaturedResources() results

---

### Workflow 5: Reorganize Categories

**Scenario**: Admin reviews and reorganizes resource categories

**Steps**:

1. **Review Category Usage**:
   - View all available categories
   - Count resources per category
   - Identify missing or redundant categories
2. **Update Category Assignments**:
   - Edit resources with wrong categories
   - Add missing categories
   - Consolidate redundant categories
3. **Verify Consistency**:
   - Similar resources have similar categories
   - No duplicate category meanings
   - Category names clear and distinct
4. **Test Filtering**:
   - Verify filters work correctly
   - Ensure category chips display properly

**Example Reorganization**:

```
Before:
- "Emergency"
- "Resuscitation"
- "CPR"
- "Cardiac"

After:
- "Cardiac Emergencies" (consolidated)
- "Resuscitation"
- "Basic Life Support"
- "Advanced Life Support"
```

---

### Workflow 6: Improve Search Tags

**Scenario**: Admin reviews search functionality and improves tags

**Steps**:

1. **Review Search Results**:
   - Test various search terms
   - Note if resources are hard to find
   - Identify missing keywords
2. **Update Tags for Each Resource**:
   - Add missing search terms
   - Include common user search terms
   - Add medical abbreviations
   - Add layman's terms
3. **Test Search Again**:
   - Verify improved discoverability
   - Ensure tags match content
4. **Monitor Usage**:
   - Track which searches are popular
   - Update tags based on patterns

**Example Tag Improvements**:

```
Original Tags: ["cpr"]

Enhanced Tags: [
  "cpr",
  "cardiopulmonary resuscitation",
  "heart attack",
  "cardiac arrest",
  "cardiac emergency",
  "unconscious",
  "unresponsive",
  "chest compression",
  "mouth-to-mouth",
  "rescue breathing",
  "resuscitation",
  "lifesaving",
  "emergency"
]
```

---

## Admin Dashboard Components

### Recommended Admin Pages

#### 1. **Resource Admin List Page**

(resource_admin_list_page.dart - to be created)

**Components**:

- AppBar with title: "Manage Resources"
- FAB button: "Add New Resource" (+)
- Search bar for quick lookup
- Filter chips: By category, By featured status
- Resource cards showing:
  - Resource name
  - Brief description (truncated)
  - Categories as chips
  - Featured indicator (star)
  - Edit button (pencil icon)
  - Delete button (trash icon)
- Summary stats:
  - Total resources count
  - Featured resources count
- Refresh indicator (pull-to-refresh)

**Actions**:

- Tap FAB → Opens create form
- Tap Edit → Opens edit form
- Tap Delete → Shows confirmation dialog
- Search → Real-time filtering
- Filter → Category-based filtering

---

#### 2. **Resource Admin Detail Page**

(resource_admin_detail_page.dart - to be created)

**Purpose**: Create/Edit resource

**Form Fields**:

- Text input: Resource name \*
- Text area: Description \*
- Multi-select: Categories \*
- Text input: Tags (comma-separated) \*
- Text area: Image URLs (one per line) \*
- Text area: When to use (optional)
- Text area: Safety tips (optional)
- Text area: Professional tip (optional)
- Checkbox: Mark as featured
- Button: Create / Update
- Button: Cancel

**Validation**:

- All required fields filled (marked with \*)
- At least one category
- At least one tag
- At least one image URL

**Error Display**:

- Clear error messages for validation failures
- Success toast after save

---

#### 3. **Resource Stats/Dashboard**

(resource_stats_widget.dart - optional)

**Components**:

- Total resources count
- Featured resources count
- Resources by category (breakdown)
- Recently added resources
- Recently modified resources
- Search statistics (optional)

---

## Firestore Schema for Admin

### Resources Collection (`resources`)

**Collection Path**: `resources/{docId}`

**Document Structure**:

```
resources/
├── doc_1/
│   ├── id: "doc_1"
│   ├── name: "CPR for Adults"
│   ├── description: "Step-by-step guide for performing CPR..."
│   ├── category: ["Emergency Care", "Resuscitation", "Cardiac Emergencies"]
│   ├── tags: ["cpr", "heart attack", "cardiac arrest", "unconscious", ...]
│   ├── imageUrls: [
│   │   "https://cdn.example.com/cpr-step1.jpg",
│   │   "https://cdn.example.com/cpr-step2.jpg"
│   │ ]
│   ├── whenToUse: "When person is unresponsive and not breathing normally"
│   ├── safetyTips: "Check for responsiveness first. Call emergency..."
│   ├── proTip: "Maintain compression rate of 100-120 compressions/minute"
│   ├── price: 0.0
│   ├── isFeatured: true
│   ├── createdAt: Timestamp(2024-01-15T10:30:00Z)
│   └── updatedAt: Timestamp(2024-02-20T14:45:00Z)
│
├── doc_2/
│   ├── name: "Recovery Position"
│   ├── description: "Safe positioning for unconscious breathing person..."
│   ├── category: ["Emergency Care", "Resuscitation"]
│   ├── tags: ["recovery position", "unconscious", "breathing", ...]
│   ├── imageUrls: [...]
│   ├── whenToUse: "When person is unconscious but breathing"
│   ├── safetyTips: "Do NOT move if spinal injury suspected"
│   ├── proTip: "Monitor airway continuously, check for obstructions"
│   ├── price: 0.0
│   ├── isFeatured: false
│   ├── createdAt: Timestamp(2024-01-10T08:00:00Z)
│   └── updatedAt: Timestamp(2024-02-15T10:00:00Z)
│
└── ... (more resources)
```

### Field Descriptions

| Field       | Type      | Required | Mutable | Notes                            |
| ----------- | --------- | -------- | ------- | -------------------------------- |
| id          | String    | Yes      | No      | Auto-generated by Firestore      |
| name        | String    | Yes      | Yes     | Resource title/name              |
| description | String    | Yes      | Yes     | Detailed explanation             |
| category    | Array     | Yes      | Yes     | List of category strings         |
| tags        | Array     | Yes      | Yes     | Search keywords                  |
| imageUrls   | Array     | Yes      | Yes     | Image URLs for carousel          |
| whenToUse   | String    | No       | Yes     | Usage guidance                   |
| safetyTips  | String    | No       | Yes     | Safety considerations            |
| proTip      | String    | No       | Yes     | Professional advice              |
| price       | Number    | No       | No      | Reserved for future (always 0.0) |
| isFeatured  | Boolean   | No       | Yes     | Featured status                  |
| createdAt   | Timestamp | Yes      | No      | Creation timestamp               |
| updatedAt   | Timestamp | Yes      | Yes     | Last modification timestamp      |

### Firestore Indexes Required

**Single Field Indexes**:

1. `isFeatured` (Ascending)

   - Query: Fetch featured resources
   - Used by: getFeaturedResources()

2. `createdAt` (Descending)

   - Query: Recently added resources
   - Used by: Admin dashboard stats

3. `updatedAt` (Descending)
   - Query: Recently modified resources
   - Used by: Admin audit trail

**Composite Indexes**:

1. `(isFeatured, createdAt DESC)`

   - Query: Recent featured resources
   - Used by: Homepage featured section

2. `(category, isFeatured)`
   - Query: Featured resources by category
   - Used by: Category-specific display

---

## Access Control

### Admin Role Capabilities

**Admin Can**:

- ✅ View all resources
- ✅ Create new resources
- ✅ Edit resource information
- ✅ Delete resources
- ✅ Toggle featured status
- ✅ Manage categories
- ✅ Manage tags
- ✅ Upload/manage images
- ✅ Search and filter resources

**Admin Cannot** (Restricted):

- ❌ Modify resource IDs
- ❌ Change creation timestamps
- ❌ Access payment/pricing (frozen at 0.0)
- ❌ Modify user-level access controls
- ❌ Delete system-level settings

**Regular User Can**:

- ✅ View published resources
- ✅ Search resources
- ✅ Filter by category
- ✅ View images
- ✅ Read guidance content
- ❌ Create/edit/delete resources

---

### Implementation Approach

**Firestore Security Rules** (Recommended):

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /resources/{document=**} {
      // Allow read for all authenticated users
      allow read: if request.auth != null;

      // Allow write only for admins
      allow create, update, delete: if request.auth != null &&
                                       'admin' in request.auth.token.claims;
    }
  }
}
```

**UI-Level Access Control**:

```dart
// In admin pages:
if (!isUserAdmin()) {
  return UnauthorizedPage();
}

// Show admin pages only in admin dashboard
if (userRole == 'admin') {
  showAdminPages();
} else {
  showUserPages();
}
```

---

## Summary of Implementable Admin Functionalities

| Operation                 | Current Status  | Can Be Implemented | Component                       |
| ------------------------- | --------------- | ------------------ | ------------------------------- |
| **View All Resources**    | ✅ Implemented  | N/A (already done) | ResourceListPage                |
| **View Resource Details** | ✅ Implemented  | N/A (already done) | ResourceDetailPage              |
| **Create Resource**       | ❌ Not yet      | ✅ Yes             | resource_admin_detail_page.dart |
| **Edit Resource**         | ❌ Not yet      | ✅ Yes             | resource_admin_detail_page.dart |
| **Delete Resource**       | ❌ Not yet      | ✅ Yes             | resource_admin_list_page.dart   |
| **Toggle Featured**       | ❌ Not yet      | ✅ Yes             | resource_admin_list_page.dart   |
| **Search Resources**      | ✅ Implemented  | N/A (already done) | ResourceController              |
| **Filter by Category**    | ✅ Implemented  | N/A (already done) | ResourceController              |
| **Manage Categories**     | ✅ Logic exists | ✅ Yes (admin UI)  | resource_admin_detail_page.dart |
| **Manage Tags**           | ✅ Logic exists | ✅ Yes (admin UI)  | resource_admin_detail_page.dart |
| **Manage Images**         | ❌ Not yet      | ✅ Yes             | resource_admin_detail_page.dart |

---

## Pages to Be Implemented

### 1. `resource_admin_list_page.dart`

**Purpose**: Admin dashboard for resource management
**Features**:

- List all resources
- Search by name
- Filter by category
- Filter by featured status
- Edit button for each resource
- Delete button for each resource
- Add new resource FAB
- Summary statistics

**Controller to Create**: `ResourceAdminController` (extends ChangeNotifier)

### 2. `resource_admin_detail_page.dart`

**Purpose**: Create/Edit resource form
**Features**:

- Form fields for all resource data
- Category selector
- Tag input
- Image URL input
- When to use, safety tips, pro tip inputs
- Featured toggle
- Validation
- Submit/Cancel buttons

**Use Case Patterns**:

- Create mode: Empty form, "Create" button
- Edit mode: Pre-filled form, "Update" button, loads resource by ID

---

## Use Cases (To Be Implemented)

### Use Case 1: CreateResource

**Input**: Resource details (name, description, categories, tags, images, guidance)
**Process**: Validate → Create in Firestore → Auto-generate ID → Update timestamps
**Output**: Resource ID, Success message

### Use Case 2: UpdateResource

**Input**: Resource ID, Updated fields
**Process**: Validate → Update in Firestore → Preserve createdAt → Update updatedAt
**Output**: Success message

### Use Case 3: DeleteResource

**Input**: Resource ID
**Process**: Confirm → Delete from Firestore → Remove from user view
**Output**: Success message

### Use Case 4: GetResourceById

**Input**: Resource ID
**Process**: Fetch from Firestore
**Output**: Resource details (already implemented for users)

### Use Case 5: ListAllResources

**Input**: None
**Process**: Fetch all resources from Firestore
**Output**: List of resources (already implemented for users)

---

## Implementation Notes for Developer

### Service Layer Additions Needed

```dart
// In ResourceRemoteDataSource:
Future<String> addResource(ResourceModel resource);
Future<void> updateResource(String id, ResourceModel resource);
Future<void> deleteResource(String id);

// In ResourceRepository:
Future<String> addResource(Resource resource);
Future<void> updateResource(String id, Resource resource);
Future<void> deleteResource(String id);
```

### New Use Cases to Create

```
lib/domain/usecases/
├── add_resource.dart
├── update_resource.dart
└── delete_resource.dart
```

### New Admin Controller

```
lib/features/first_aid_resources/presentation/controllers/
└── resource_admin_controller.dart
```

### New Admin Pages

```
lib/features/first_aid_resources/presentation/pages/
├── resource_admin_list_page.dart
└── resource_admin_detail_page.dart
```

---

## Conclusion

The First Aid Resources module has **significant admin management potential** that mirrors the Condition Categories and Emergency Numbers modules. While currently read-only in implementation, the following admin functionalities are **clearly applicable and implementable**:

✅ **Create Resources** - Add new first aid techniques  
✅ **Edit Resources** - Update content and metadata  
✅ **Delete Resources** - Remove outdated information  
✅ **Toggle Featured** - Promote critical resources  
✅ **Manage Categories** - Organize resources effectively  
✅ **Manage Tags** - Improve searchability  
✅ **Manage Images** - Provide visual learning aids

This documentation provides the complete roadmap for implementing admin functionalities. The module can be made admin-friendly following the same architectural patterns as existing modules (Blood Donors, Emergency Numbers, Categories).

**Implementation Status**: Documentation complete for future developer implementation.

---

**Document Status**: Admin Functionalities Reference Guide
**Applicable for Admin Management**: ✅ YES
**Recommended for Implementation**: ✅ YES (following same pattern as other modules)
**Scope**: Academic project - practical admin operations only
