# Presentation Module (Home Page) - Admin Functionalities Reference

## Overview

This document outlines the **Admin Dashboard capabilities** for managing the Presentation Module (Home Page) in the ResQnow application. The Presentation Module is the main entry point for users and displays aggregated content from multiple feature modules (First Aid Resources, Medical Conditions, Blood Banks, Emergency Numbers, etc.). Since this is an academic project with a small user base, the admin features focus on **practical, essential operations** for managing home page layout, featured content, and section visibility.

**Current Status**: Home page displays aggregated content from other modules; Home page layout/section management documented for future implementation.

**Technology**: Firebase Firestore, Flutter, Provider State Management

---

## Table of Contents

1. [Home Page Content Management](#home-page-content-management)
2. [Section Visibility & Ordering](#section-visibility--ordering)
3. [Featured Content Management](#featured-content-management)
4. [Home Page Configuration](#home-page-configuration)
5. [Admin Tasks & Workflows](#admin-tasks--workflows)
6. [Admin Dashboard Components](#admin-dashboard-components)
7. [Firestore Schema for Admin](#firestore-schema-for-admin)
8. [Access Control](#access-control)

---

## Home Page Content Management

### 1. View Current Home Page Layout

**Responsibility**: Fetch home page configuration (to be implemented)

**Admin Can View**:

- All home page sections and their order
- Visibility status of each section
- Featured content in each section
- Section metadata (title, description)
- Category count displayed
- Resource count displayed
- Hospital count displayed

**Current Sections Displayed**:

1. Top Bar (Location + Search + Menu)
2. First Aid Categories (horizontal carousel)
3. Nearby Hospitals (horizontal carousel)
4. First Aid Kits/Resources (vertical list with featured)
5. Blood Banks & Donors (section)
6. Workshops (section)

**Use Cases**:

- Monitor home page configuration
- Plan content layout changes
- Review which sections are visible
- Audit featured content placement

**Current Implementation**: ✅ HomePage displays all sections

---

### 2. Manage Section Visibility (**NOT YET IMPLEMENTED**)

**Responsibility**: Control which sections appear on home page

**Admin Actions**:

- Show/hide sections independently
- Disable sections without removing configuration
- Maintain section configuration while hiding

**Sections That Can Be Managed**:

- First Aid Categories ✅
- Nearby Hospitals ✅
- First Aid Kits/Resources ✅
- Blood Banks & Donors ✅
- Workshops ✅
- Emergency Numbers (can be added)
- Medical Conditions (can be added)
- Saved Topics (can be added)

**Data Field**: `isVisible: boolean` per section

**Use Cases**:

- Hide sections under maintenance
- Disable seasonal content
- Customize app experience by region
- Focus on specific features
- A/B testing different layouts

**Current Implementation**: All sections always visible (hardcoded)

**Future Implementation**:

```dart
// Per section in home page config:
{
  sectionId: "first_aid_categories",
  title: "First Aid Categories",
  isVisible: true,
  order: 1,
  ...
}
```

---

### 3. Manage Section Ordering (**NOT YET IMPLEMENTED**)

**Responsibility**: Control display order of home page sections

**Admin Actions**:

- Reorder sections via drag-and-drop or number input
- Prioritize important sections
- Change section sequence

**Ordering Impact**:

- First section appears at top (most prominent)
- Last sections require scrolling
- Priority affects user engagement

**Use Cases**:

- Promote critical features (Emergency Numbers to top)
- Reorganize based on usage patterns
- A/B test different section orders
- Regional customization

**Current Implementation**: Hardcoded section order in HomePage

**Suggested Order Priority**:

```
1. Top Bar (always first - location + search)
2. Emergency/Critical Features (Emergency Numbers, Critical Conditions)
3. First Aid Resources (most accessed)
4. Medical Conditions (educational content)
5. Blood Banks & Donors (specialized feature)
6. Hospitals/Healthcare (resource finder)
7. Workshops (awareness/training)
```

---

### 4. Manage Featured Content (**PARTIALLY IMPLEMENTED**)

**Responsibility**: Control what appears as "featured" in each section

**Admin Actions**:

- Select featured resources
- Select featured medical conditions
- Select featured categories
- Control featured content count per section

**Featured Content Configuration**:

- Featured resources (already have `isFeatured` field)
- Featured conditions (can add `isFeatured` field)
- Featured categories (can add `isFeatured` field)
- Featured hospitals (can add `isFeatured` field)

**Display Logic**:

- Featured items appear first in sections
- Prominent display (larger cards, special styling)
- Limited number of featured items

**Use Cases**:

- Highlight critical life-saving techniques
- Promote new educational content
- Seasonal health campaigns
- Emergency preparedness awareness
- Highlight new resources

**Current Implementation**:

- ✅ Resources have `isFeatured` field
- ✅ Can be managed via admin pages
- ❌ Home page doesn't specifically display featured section yet

**Future Enhancement**:

```dart
// Add featured resources section to home page:
"Featured Resources" section at top
- Shows getFeaturedResources() results
- Limited to top 5 featured items
- Carousel or horizontal scroll
```

---

### 5. Manage Category Display Count (**NOT YET IMPLEMENTED**)

**Responsibility**: Control how many categories appear on home page

**Admin Actions**:

- Set number of categories to display (currently hardcoded to 6)
- Choose which categories to show
- Reorder category display

**Current Implementation**:

```dart
categories.take(6)  // Hardcoded to show 6 categories
```

**Configurable Options**:

- Display count (4, 6, 8, 12, all)
- Selection method (top used, alphabetical, featured only)
- Order (custom, alphabetical, usage count)

**Use Cases**:

- Show more categories for comprehensive view
- Limit for mobile space constraints
- Feature important categories
- Regional category customization

**Future Implementation**:

```dart
{
  sectionId: "first_aid_categories",
  displayCount: 6,
  selectionMethod: "featured_first",
  customOrder: [category_id1, category_id2, ...]
}
```

---

### 6. Manage Resource Display Count (**NOT YET IMPLEMENTED**)

**Responsibility**: Control how many resources appear in each section

**Admin Actions**:

- Set number of resources per section
- Choose which resources to prioritize
- Control section height and scroll

**Current Implementation**:

```dart
// First Aid Kits section - displays dynamically based on screen size
// Hardcoded to show all fetched resources
```

**Configurable Options**:

- Max display count (5, 10, 15, unlimited)
- Sort method (featured, recent, alphabetical, popular)
- "See All" button behavior

**Use Cases**:

- Limit scrolling on home page
- Show only most important resources
- Optimize for different screen sizes
- Improve app performance

---

## Section Visibility & Ordering

### Available Home Page Sections

#### 1. First Aid Categories Section

**Current Status**: ✅ Displayed
**Data Source**: CategoryController.categories (from Condition Categories module)
**Display**: Horizontal carousel with 6 categories
**Admin Control Needed**:

- ✅ Visibility toggle
- ✅ Order position
- ✅ Display count
- ✅ Featured categories highlight

#### 2. Nearby Hospitals Section

**Current Status**: ✅ Displayed (placeholder)
**Data Source**: LocationController + Hospital finder service
**Display**: Horizontal carousel with 3 hospitals
**Admin Control Needed**:

- ✅ Visibility toggle
- ✅ Order position
- ✅ Display count
- ❓ Hospital filtering/selection

#### 3. First Aid Kits/Resources Section

**Current Status**: ✅ Displayed
**Data Source**: ResourceController.resources (from First Aid Resources module)
**Display**: Vertical list with featured resources
**Admin Control Needed**:

- ✅ Visibility toggle
- ✅ Order position
- ✅ Featured content selection
- ✅ Display count

#### 4. Blood Banks & Donors Section

**Current Status**: ✅ Displayed
**Data Source**: Blood Donor module
**Display**: Card/list view
**Admin Control Needed**:

- ✅ Visibility toggle
- ✅ Order position
- ✅ Featured donors/banks

#### 5. Workshops Section

**Current Status**: ✅ Displayed
**Data Source**: (Not yet implemented)
**Display**: Card view
**Admin Control Needed**:

- ✅ Visibility toggle
- ✅ Order position
- ✅ Featured workshops

#### 6. Emergency Numbers Section (**To Be Added**)

**Potential Addition**: Show quick access to emergency numbers
**Data Source**: Emergency Numbers module
**Display**: Top-pinned section with quick call buttons
**Recommended**: Show as top section (highest priority)

#### 7. Medical Conditions Section (**To Be Added**)

**Potential Addition**: Featured medical conditions
**Data Source**: Medical Conditions module
**Display**: Carousel of critical conditions
**Recommended**: High position for emergency awareness

#### 8. Saved Topics Section (**To Be Added**)

**Potential Addition**: User's saved resources and conditions
**Display**: Personalized quick access
**Recommended**: Below primary navigation

---

## Featured Content Management

### Featured Resources on Home Page

**Current Status**:

- ✅ Resources have `isFeatured` field
- ❌ Not displayed separately on home page
- ❌ No featured section yet

**Recommended Enhancement**:
Add "Featured Resources" section at top of home page:

```dart
/// Featured Resources Section (HIGH PRIORITY)
_buildSectionHeader(
  title: "Featured Resources",
  onSeeAll: () => context.push('/resources?filter=featured'),
),

// Display top 5 featured resources in carousel
// Use ResourceController.getFeaturedResources()
```

**Admin Can Control**:

- Which resources are featured (managed in resource module)
- Featured resources count on home page
- Featured section visibility
- Featured section position

**Use Cases**:

- Promote critical life-saving techniques
- Highlight new content
- Emergency awareness campaigns
- Seasonal health topics

---

### Featured Medical Conditions

**Current Status**: Not yet implemented

**Recommended Addition**:
Add "Featured Medical Emergencies" section:

```dart
/// Featured Critical Conditions
- Show top 5 critical severity conditions
- Quick access to emergency procedures
- Color-coded severity indicators
```

**Admin Can Control**:

- Featured conditions (manage via condition admin module)
- Display count (3-10)
- Position on home page

---

## Home Page Configuration

### Home Page Settings (Firestore)

**Collection**: `home_page_configuration`

**Configuration Document Fields**:

```json
{
  "docId": "home_page_main",

  "sections": [
    {
      "sectionId": "first_aid_categories",
      "title": "First Aid Categories",
      "description": "Browse medical conditions by category",
      "isVisible": true,
      "order": 1,
      "displayCount": 6,
      "selectionMethod": "featured_first",
      "backgroundColor": "#FFFFFF",
      "customOrder": []
    },
    {
      "sectionId": "featured_resources",
      "title": "Featured Resources",
      "description": "Critical life-saving techniques",
      "isVisible": true,
      "order": 2,
      "displayCount": 5,
      "selectionMethod": "featured",
      "backgroundColor": "#FFF5F5"
    },
    {
      "sectionId": "nearby_hospitals",
      "title": "Nearby Hospitals",
      "description": "Healthcare facilities near you",
      "isVisible": true,
      "order": 3,
      "displayCount": 3,
      "selectionMethod": "nearest"
    },
    {
      "sectionId": "first_aid_kits",
      "title": "First Aid Kits",
      "description": "Essential medical kits and supplies",
      "isVisible": true,
      "order": 4,
      "displayCount": 10,
      "selectionMethod": "recent"
    },
    {
      "sectionId": "blood_banks_donors",
      "title": "Blood Banks & Donors",
      "description": "Blood donation and bank services",
      "isVisible": true,
      "order": 5,
      "displayCount": 5,
      "selectionMethod": "featured"
    },
    {
      "sectionId": "workshops",
      "title": "Workshops",
      "description": "Training and awareness programs",
      "isVisible": false,
      "order": 6,
      "displayCount": 4,
      "selectionMethod": "featured"
    }
  ],

  "globalSettings": {
    "enableSearchBar": true,
    "enableLocationDisplay": true,
    "enableMenuButton": true,
    "scrollPhysics": "bouncing",
    "theme": "light",
    "defaultRefreshInterval": 3600
  },

  "notifications": {
    "enablePushNotifications": true,
    "emergencyBannerText": "Emergency? Tap here for emergency numbers",
    "showEmergencyBanner": true
  },

  "lastUpdated": Timestamp,
  "updatedBy": "admin_user_id",
  "version": 1
}
```

### Global Settings

**Admin Can Configure**:

- Show/hide search bar
- Show/hide location display
- Show/hide menu button
- Scroll physics (bouncing, clamping)
- App theme (light/dark)
- Auto-refresh interval

---

## Admin Tasks & Workflows

### Workflow 1: Reorder Home Page Sections

**Scenario**: Move emergency features to top, deprioritize workshops

**Steps**:

1. **Open Home Page Configuration** (admin dashboard)
2. **View Current Order**:
   - First Aid Categories (order: 1)
   - Featured Resources (order: 2)
   - Nearby Hospitals (order: 3)
   - First Aid Kits (order: 4)
   - Blood Banks & Donors (order: 5)
   - Workshops (order: 6)
3. **Drag to Reorder**:
   - Move "Featured Resources" to position 1 (top)
   - Move "First Aid Categories" to position 2
   - Move "Nearby Hospitals" to position 3
   - Move "Workshops" to position 6 (bottom)
4. **Save Changes**
5. **Verify**:
   - Open home page on test device
   - Confirm new order displays correctly

**Result**:

```
New Home Page Order:
1. Featured Resources (CRITICAL TECHNIQUES)
2. First Aid Categories
3. Nearby Hospitals
4. First Aid Kits
5. Blood Banks & Donors
6. Workshops
```

---

### Workflow 2: Hide Section Under Maintenance

**Scenario**: Hospital finder service down for maintenance

**Steps**:

1. **Open Home Page Configuration**
2. **Find Section**: "Nearby Hospitals"
3. **Toggle Visibility**: Off
4. **Save Changes**
5. **Effect**:
   - Section disappears from home page
   - Other sections shift up
   - Configuration preserved for later re-enabling

**Result**:

```
Nearby Hospitals section {
  isVisible: false,
  order: 3  // position maintained for when re-enabled
}
```

---

### Workflow 3: Manage Featured Resources Count

**Scenario**: Add "Featured Resources" section, limit to top 5

**Steps**:

1. **Add New Section** (if not exists):
   ```json
   {
     "sectionId": "featured_resources",
     "title": "Featured Resources",
     "isVisible": true,
     "order": 2,
     "displayCount": 5
   }
   ```
2. **Configure Display**:
   - Set display count: 5
   - Set selection method: "featured"
   - Set sort order: by popularity
3. **Test on Home Page**:
   - Verify section appears
   - Verify only 5 items show
   - Verify "See All" button works
4. **Monitor Usage**:
   - Check if users click featured resources
   - Adjust count based on engagement

---

### Workflow 4: Customize Section Titles & Descriptions

**Scenario**: Change section titles for clarity

**Steps**:

1. **Open Configuration**
2. **Edit Section**:
   - Change: "First Aid Kits" → "Essential Medical Kits"
   - Add description: "Required supplies for common emergencies"
3. **Update Theme Colors** (optional):
   - Set background color: light red (#FFF5F5)
4. **Save and Verify**

**Result**: Users see updated section titles/descriptions

---

### Workflow 5: A/B Test Different Section Orders

**Scenario**: Test if moving categories to top increases engagement

**Steps**:

1. **Create Configuration Variant**:
   - Save current config as "variant_a"
   - Create "variant_b" with different order
2. **Deploy to Test Users**:
   - Show variant_a to 50% of users
   - Show variant_b to 50% of users
3. **Monitor Metrics**:
   - Track which variant has better engagement
   - Measure category clicks
   - Measure resource clicks
4. **Analyze & Choose**:
   - Select better-performing variant
   - Deploy to all users

---

### Workflow 6: Enable/Disable Global Features

**Scenario**: Disable push notifications due to spam complaints

**Steps**:

1. **Open Home Page Configuration**
2. **Go to Notifications Settings**
3. **Toggle**: "Enable Push Notifications" → OFF
4. **Save Changes**
5. **Effect**: Users stop receiving push notifications

---

## Admin Dashboard Components

### Recommended Admin Pages

#### 1. **Home Page Configuration Page**

(home_page_admin_config_page.dart - to be created)

**Components**:

- AppBar: "Configure Home Page"
- Tabs:
  - "Sections Management"
  - "Global Settings"
  - "Notifications"
  - "Analytics"

**Section Management Tab**:

- List of all sections with:
  - Section name
  - Visibility toggle (on/off)
  - Order position (drag-and-drop or number input)
  - Display count (number input)
  - Edit button (configure details)
  - Delete button (remove section)
- "Add New Section" button

**Global Settings Tab**:

- Toggle: Show search bar
- Toggle: Show location
- Toggle: Show menu button
- Dropdown: Scroll physics
- Dropdown: Theme
- Number input: Refresh interval

**Notifications Tab**:

- Toggle: Enable push notifications
- Text input: Emergency banner text
- Toggle: Show emergency banner
- Message preview

**Analytics Tab**:

- Section click statistics
- Most viewed sections
- Engagement metrics
- User interaction heatmap

---

#### 2. **Section Detail Editor**

(section_detail_editor.dart - to be created)

**Purpose**: Configure individual section settings

**Form Fields**:

- Text input: Section title
- Text area: Section description
- Dropdown: Selection method (featured, recent, alphabetical, etc.)
- Number input: Display count
- Color picker: Background color
- Text input: Button text ("See All")
- Toggle: Enable/disable section

**Dynamic Configuration Based on Section**:

- Categories section: Featured categories selector
- Resources section: Featured resources selector
- Hospitals section: Hospital filtering options
- Donors section: Donor type filters

---

## Firestore Schema for Admin

### Home Page Configuration Collection

**Collection Path**: `home_page_configuration`

**Document Path**: `home_page_configuration/home_page_main`

**Structure**:

```json
{
  "docId": "home_page_main",

  "sections": [
    {
      "sectionId": String (unique),
      "title": String,
      "description": String,
      "isVisible": Boolean,
      "order": Number (1, 2, 3, ...),
      "displayCount": Number,
      "selectionMethod": String (featured|recent|alphabetical|custom),
      "backgroundColor": String (hex color),
      "customOrder": Array<String> (IDs if custom order)
    }
  ],

  "globalSettings": {
    "enableSearchBar": Boolean,
    "enableLocationDisplay": Boolean,
    "enableMenuButton": Boolean,
    "scrollPhysics": String (bouncing|clamping|never),
    "theme": String (light|dark|system),
    "defaultRefreshInterval": Number (seconds)
  },

  "notifications": {
    "enablePushNotifications": Boolean,
    "emergencyBannerText": String,
    "showEmergencyBanner": Boolean
  },

  "lastUpdated": Timestamp,
  "updatedBy": String (admin user ID),
  "version": Number
}
```

### Firestore Indexes Required

**No complex indexes needed** for home page configuration (simple document read/write)

---

## Access Control

### Admin Role Capabilities

**Admin Can**:

- ✅ View home page configuration
- ✅ Enable/disable sections
- ✅ Reorder sections
- ✅ Modify display counts
- ✅ Customize titles/descriptions
- ✅ Configure global settings
- ✅ Enable/disable notifications
- ✅ View analytics/usage statistics
- ✅ A/B test configurations

**Admin Cannot** (Restricted):

- ❌ Delete home page configuration entirely (protect against accidents)
- ❌ Modify system-level settings outside scope
- ❌ Access user-level personalization data

**Regular User Can**:

- ✅ View home page with configured sections
- ✅ See featured content
- ✅ Receive notifications (if enabled)
- ✅ Interact with sections
- ❌ Modify home page configuration

---

### Implementation Approach

**Firestore Security Rules** (Recommended):

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /home_page_configuration/{document=**} {
      // Allow read for all authenticated users
      allow read: if request.auth != null;

      // Allow write only for admins
      allow create, update, delete: if request.auth != null &&
                                       'admin' in request.auth.token.claims;
    }
  }
}
```

---

## Summary of Implementable Admin Functionalities

| Operation                     | Current Status | Can Be Implemented       | Component                        |
| ----------------------------- | -------------- | ------------------------ | -------------------------------- |
| **View Home Page Layout**     | ✅ Visible     | ✅ Yes (config view)     | home_page_admin_config_page.dart |
| **Toggle Section Visibility** | ❌ Not yet     | ✅ Yes                   | section editor                   |
| **Reorder Sections**          | ❌ Not yet     | ✅ Yes                   | drag-and-drop UI                 |
| **Configure Display Count**   | ❌ Not yet     | ✅ Yes                   | section editor                   |
| **Customize Section Titles**  | ❌ Not yet     | ✅ Yes                   | section editor                   |
| **Manage Featured Content**   | ✅ Partial     | ✅ Yes (via sub-modules) | featured section                 |
| **Configure Global Settings** | ❌ Not yet     | ✅ Yes                   | settings panel                   |
| **Manage Notifications**      | ❌ Not yet     | ✅ Yes                   | notifications panel              |
| **View Analytics**            | ❌ Not yet     | ✅ Yes (future)          | analytics dashboard              |
| **A/B Test Layouts**          | ❌ Not yet     | ✅ Yes (future)          | variant manager                  |

---

## Pages to Be Implemented

### 1. `home_page_admin_config_page.dart`

**Purpose**: Main admin dashboard for home page configuration
**Features**:

- View all sections
- Toggle visibility
- Drag-and-drop reordering
- Edit individual sections
- Global settings panel
- Notifications panel
- Analytics view (optional)
- Save/publish changes

**Controller to Create**: `HomePageAdminController` (extends ChangeNotifier)

### 2. `section_editor_dialog.dart` or `section_detail_page.dart`

**Purpose**: Configure individual section settings
**Features**:

- Section name editor
- Description editor
- Display count selector
- Selection method dropdown
- Color picker
- Save/cancel buttons

---

## Use Cases (To Be Implemented)

### Use Case 1: UpdateHomePageConfiguration

**Input**: Updated section order, visibility, display counts
**Process**: Validate → Update in Firestore → Cache locally
**Output**: Success message, updated home page display

### Use Case 2: ReorderSections

**Input**: New section order array
**Process**: Update order field → Save to Firestore
**Output**: Home page reflects new order

### Use Case 3: ToggleSectionVisibility

**Input**: Section ID, visibility boolean
**Process**: Update isVisible field → Firestore
**Output**: Section appears/disappears immediately

### Use Case 4: UpdateGlobalSettings

**Input**: Settings configuration
**Process**: Update globalSettings object → Firestore
**Output**: App applies new settings

---

## Implementation Notes for Developer

### Service Layer Additions Needed

```dart
// In home_service.dart:
Future<Map<String, dynamic>> getHomePageConfiguration();
Future<void> updateHomePageConfiguration(Map<String, dynamic> config);
Future<void> updateSectionVisibility(String sectionId, bool isVisible);
Future<void> updateSectionOrder(List<Map<String, dynamic>> sections);
Future<void> updateGlobalSettings(Map<String, dynamic> settings);
```

### New Use Cases to Create

```
lib/domain/usecases/
├── get_home_page_configuration.dart
├── update_home_page_configuration.dart
├── toggle_section_visibility.dart
└── reorder_sections.dart
```

### New Admin Controller

```
lib/features/presentation/controllers/
└── home_page_admin_controller.dart
```

### New Admin Pages

```
lib/features/presentation/pages/
├── home_page_admin_config_page.dart
└── section_editor_dialog.dart
```

### Integration with HomePage

```dart
// Modify HomePage to load configuration:
Future<void> _loadHomePageConfiguration() async {
  final config = await homePageService.getHomePageConfiguration();
  _buildDynamicSections(config);
}
```

---

## Conclusion

The Presentation Module (Home Page) has **significant admin management potential** for controlling the user experience. While currently displaying hardcoded sections, the following admin functionalities are **clearly applicable and implementable**:

✅ **Toggle Section Visibility** - Show/hide features  
✅ **Reorder Sections** - Control prominence  
✅ **Manage Display Counts** - Limit/expand content shown  
✅ **Customize Titles** - Update section names  
✅ **Configure Settings** - Global feature toggles  
✅ **Manage Notifications** - Control user notifications  
✅ **Feature Content** - Highlight important items  
✅ **A/B Test Layouts** - Optimize engagement (future)

This documentation provides the complete roadmap for implementing admin functionalities. The module can be made admin-friendly following the same architectural patterns as existing modules.

**Implementation Status**: Documentation complete for future developer implementation.

---

**Document Status**: Admin Functionalities Reference Guide
**Applicable for Admin Management**: ✅ YES
**Recommended for Implementation**: ✅ YES (high priority for UX customization)
**Scope**: Academic project - practical layout management only
