# Condition Categories Module - Admin Functionalities Reference

## Overview

This document outlines the **Admin Dashboard capabilities** for managing medical condition categories in the ResQnow Condition Categories Module. Since this is an academic project with a small user base, the admin features focus on **practical, essential operations** for managing category visibility, ordering, and metadata.

**Technology**: Firebase Firestore, Flutter, Provider

---

## Table of Contents

1. [Category Management](#category-management)
2. [Visibility & Display Control](#visibility--display-control)
3. [Category Organization](#category-organization)
4. [Search & Filtering](#search--filtering)
5. [Admin Tasks & Workflows](#admin-tasks--workflows)
6. [Admin Dashboard Components](#admin-dashboard-components)
7. [Firestore Schema for Admin](#firestore-schema-for-admin)
8. [Access Control](#access-control)

---

## Category Management

### 1. View All Categories

**Responsibility**: CategoryService.getVisibleCategories()

**Admin Actions**:

- Fetch complete list of medical condition categories
- Display category information
- View category metadata
- Check visibility status

**Data Visible**:

- Category name (e.g., "Heart Disease", "Diabetes")
- Icon asset reference
- Display order
- Visibility status (visible/hidden)
- Search aliases

**Use Cases**:

- Get system overview of available categories
- Monitor category configuration
- Review category order
- Verify category visibility

**Permissions Required**:

- Read access to `categories` collection

---

### 2. View Individual Category Details

**Responsibility**: CategoryService queries + direct Firestore access

**Admin Can View**:

- Category name
- Icon asset file path
- Display order value
- Visibility toggle status
- Search aliases (keywords for matching)
- Associated medical conditions (if tracked)
- Category creation/update timestamps

**Use Cases**:

- Review specific category configuration
- Check icon asset validity
- Verify search alias keywords
- Audit category metadata

**Permissions Required**:

- Read access to individual category documents

---

### 3. Edit Category Information

**Responsibility**: Direct Firestore update

**Admin Can Edit**:

- Category name
- Icon asset reference
- Search aliases (for improved search matching)
- Description or notes
- Order value (for display sequencing)

**Admin Cannot Edit** (Protected):

- Category ID (unique identifier)
- Creation timestamp
- Disabled categories (use visibility toggle instead)

**Use Cases**:

- Correct category name spelling
- Update icon asset path
- Add search aliases for better matching
- Update description or medical details
- Change category order

**Permissions Required**:

- Update access to category documents
- Audit trail for modifications

---

### 4. Toggle Category Visibility

**Responsibility**: Direct Firestore update of `isVisible` field

**Admin Actions**:

- Show category in app (isVisible = true)
- Hide category from users (isVisible = false)
- Verify visibility status

**Data Updated**:

- `isVisible`: Boolean flag

**Soft Delete Approach**:

- Hidden categories remain in database
- Can be re-activated anytime
- No data loss

**Use Cases**:

- Hide categories not yet ready for users
- Temporarily disable problematic categories
- Manage category rollout gradually
- Archive outdated categories

**Permissions Required**:

- Update access to `isVisible` field

---

### 5. Delete Category

**Responsibility**: Direct Firestore delete operation

**Admin Actions**:

- Permanently remove category from system
- Delete all associated metadata

**Important Considerations**:

- **Hard Delete**: Category completely removed
- **Data Loss**: Cannot be recovered without backup
- **Recommendation**: Use visibility toggle instead for safer management

**Use Cases**:

- Remove duplicate categories
- Delete test/temporary categories
- Clean up system after category consolidation

**Permissions Required**:

- Delete access to category documents
- Confirmation dialog required

---

## Visibility & Display Control

### 1. Category Display Order

**Purpose**: Control sequence of categories shown to users

**Admin Can Manage**:

- Set display order value (numeric: 1, 2, 3, ...)
- Lower numbers display first
- Reorder categories by updating order values

**Use Cases**:

- Place frequently used categories first
- Organize by medical specialty
- Alphabetical ordering
- Custom priority arrangement

**Data Field**: `order` (integer)

**Example Order**:

```
Order 1: "Heart Disease" (frequent)
Order 2: "Diabetes" (frequent)
Order 3: "Respiratory Issues"
Order 4: "Allergies"
Order 5: "Other"
```

---

### 2. Category Visibility Management

**Purpose**: Control which categories appear to end users

**Visibility States**:

- **Visible** (isVisible = true): Category shows in app
- **Hidden** (isVisible = false): Category hidden from users

**Admin Actions**:

- View visibility status
- Toggle visibility on/off
- Batch hide/show categories
- Monitor visible category count

**Use Cases**:

- Hide categories under development
- Temporarily remove problematic categories
- Phased rollout of new categories
- Seasonal category management

**Performance Note**: Only visible categories loaded in app

---

## Category Organization

### 1. Category Naming

**Purpose**: Ensure clear, consistent category names

**Admin Responsibilities**:

- Use clear, medically accurate names
- Keep names concise (2-3 words typical)
- Avoid abbreviations or jargon
- Maintain consistent naming convention

**Examples of Good Names**:

- Heart Disease
- Diabetes
- Respiratory Issues
- Mental Health
- Allergies
- Cancer

**Examples to Avoid**:

- CVD (use full name)
- HTN (abbreviations unclear)
- "Stuff with lungs" (unprofessional)
- Very Long Category Names That Take Multiple Lines

---

### 2. Search Aliases

**Purpose**: Improve category discoverability through search

**Admin Can Add**:

- Alternative names for category
- Common medical terms
- Acronyms that are widely known
- Related keywords

**Data Field**: `aliases` (array of strings)

**Examples**:

```
Category: "Heart Disease"
Aliases: ["Cardiac", "Heart Attack", "Heart Condition", "CVD"]

Category: "Diabetes"
Aliases: ["Blood Sugar", "Insulin", "Type 1", "Type 2"]

Category: "Mental Health"
Aliases: ["Depression", "Anxiety", "Stress", "Psychological"]
```

**Search Behavior**:

- User searches for "Cardiac"
- System matches to "Heart Disease" via alias
- "Heart Disease" category returned in results

**Admin Notes**:

- Aliases should be medically relevant
- Avoid misleading synonyms
- Keep aliases 1-3 words
- Regular review of alias effectiveness

---

### 3. Icon Asset Management

**Purpose**: Maintain visual representations of categories

**Admin Can Manage**:

- Icon asset file path
- Verify icon displays correctly
- Update icon references
- Ensure icon accessibility

**Data Field**: `iconAsset` (file path string)

**Asset Location**: `assets/icons/` (or similar)

**Admin Verification**:

- Icon file exists in assets folder
- Icon is recognizable and appropriate
- Icon displays in circular container (72x72)
- Icon is visible in both light and dark modes

**Use Cases**:

- Update icon for improved clarity
- Change icon to better represent category
- Fix broken icon references
- Upgrade icon quality/resolution

---

## Search & Filtering

### 1. Search by Category Name

**Responsibility**: CategoryController.searchCategories()

**Purpose**: Find categories by name matching

**Search Behavior**:

- Case-insensitive matching
- Partial name matching (substring)
- Real-time search as admin types
- Instant result filtering

**Query Example**:

```
Admin searches: "heart"
Results:
- "Heart Disease"
- "Heart Conditions" (if exists)
```

**Use Cases**:

- Find specific category quickly
- Verify category exists
- Check naming consistency
- Locate category for editing

---

### 2. Search by Aliases

**Responsibility**: CategoryController.searchCategories()

**Purpose**: Find categories using alternative keywords

**Search Behavior**:

- Searches in aliases array
- Case-insensitive matching
- Partial word matching
- Combined with name search

**Query Example**:

```
Admin searches: "cardiac"
Aliases searched: ["Cardiac", "Heart Attack", "CVD", ...]
Results:
- "Heart Disease" (contains "Cardiac" in aliases)
```

**Use Cases**:

- Verify alias effectiveness
- Check if keyword already used
- Identify categories by medical term
- Validate search configuration

---

### 3. View Hidden Categories

**Purpose**: Access categories hidden from users

**Admin Can**:

- View complete list including hidden categories
- Filter to show only hidden categories
- Show only visible categories
- Review all categories regardless of status

**Use Cases**:

- Manage draft/under-development categories
- Review temporarily disabled categories
- Archive management
- Category lifecycle tracking

---

## Admin Tasks & Workflows

### Workflow 1: Add New Medical Category

**Scenario**: New medical condition needs to be added to system

**Admin Steps**:

1. Determine category name (e.g., "Respiratory Disease")
2. Prepare icon asset file
3. Create category document in Firestore:
   - name: "Respiratory Disease"
   - iconAsset: "assets/icons/respiratory.png"
   - aliases: ["Asthma", "COPD", "Lung Disease", "Breathing Issues"]
   - isVisible: false (initially hidden)
   - order: 99 (provisional)
4. Test category visibility
5. Test search functionality with aliases
6. Verify icon displays correctly
7. Update order when ready for rollout
8. Toggle visibility to true

**Data Created**:

```
categories/{categoryId}
├── name: "Respiratory Disease"
├── iconAsset: "assets/icons/respiratory.png"
├── aliases: ["Asthma", "COPD", "Lung Disease", "Breathing Issues"]
├── isVisible: false
├── order: 99
├── createdAt: timestamp
└── updatedAt: timestamp
```

---

### Workflow 2: Update Category Order

**Scenario**: Need to reorganize category display sequence

**Admin Steps**:

1. Review current category order in dashboard
2. Identify desired new order
3. Update order values for affected categories:
   - "Heart Disease": 1 → 2
   - "Diabetes": 2 → 1
   - Others remain unchanged
4. Verify order updates in app
5. Confirm changes reflect correctly

**Use Cases**:

- Move frequently accessed categories to top
- Reorganize by medical specialty
- Implement alphabetical ordering
- Adjust based on user behavior

---

### Workflow 3: Enable/Disable Category

**Scenario**: Category needs to be hidden or shown

**Admin Steps**:

1. Locate category in admin list
2. Review category details
3. Toggle visibility:
   - isVisible: true → false (hide)
   - isVisible: false → true (show)
4. Verify visibility change in app
5. Check if affected any user workflows

**Timing**: Changes take effect immediately

---

### Workflow 4: Improve Search Aliases

**Scenario**: Users cannot find category via search

**Admin Steps**:

1. Identify problematic category
2. Review current aliases
3. Analyze what users might search for
4. Add relevant medical terms as aliases
5. Test search with new keywords
6. Verify category appears in results
7. Monitor search effectiveness over time

**Example**:

```
Category: "Mental Health"
Problem: Users searching "depression" don't find it
Solution: Add "depression" to aliases
Updated aliases: ["Depression", "Anxiety", "Stress", "Psychological"]
```

---

### Workflow 5: Verify Category Configuration

**Scenario**: Periodic audit of category system

**Admin Steps**:

1. Check all categories are properly named
2. Verify all icon assets are valid
3. Audit alias quality and relevance
4. Review order matches priority
5. Confirm visibility settings appropriate
6. Test search functionality
7. Document any issues found

**Checklist**:

- [ ] All names clear and medically accurate
- [ ] All icons display correctly
- [ ] Search aliases relevant and helpful
- [ ] Order reflects user needs
- [ ] Visibility matches intended rollout
- [ ] No broken references

---

## Admin Dashboard Components

### Recommended Dashboard Sections

1. **Category Overview Card**

   - Total categories count
   - Visible categories count
   - Hidden categories count
   - Recent updates count

2. **Category List Table**

   - Sortable columns: Name, Order, Visibility, Icon Status
   - Action buttons: View, Edit, Hide/Show, Delete
   - Search bar for quick lookup
   - Filter by visibility status
   - Batch operations capability

3. **Category Details View**

   - Full category information
   - Icon preview (72x72 display)
   - Current aliases list
   - Display order value
   - Visibility toggle
   - Edit button
   - Delete button

4. **Category Search & Alias Manager**

   - Current aliases list
   - Add new alias form
   - Remove alias buttons
   - Alias search verification
   - Test search functionality

5. **Category Order Manager**

   - Drag-drop ordering interface
   - Numeric order input
   - Preview current order
   - Save order changes
   - Revert to previous order

6. **Category Operations**
   - Create new category
   - Batch hide/show categories
   - Export category list (JSON)
   - Import categories (bulk upload)

---

## Firestore Schema for Admin

### Categories Collection (`categories`)

**Collection Path**: `categories/{categoryId}`

**Document Structure**:

```
categories/
├── category_1/
│   ├── id: "category_1" (or docId)
│   ├── name: "Heart Disease"
│   ├── iconAsset: "assets/icons/heart.png"
│   ├── aliases: ["Cardiac", "Heart Attack", "CVD"]
│   ├── isVisible: true
│   ├── order: 1
│   ├── createdAt: Timestamp(2024-01-01)
│   └── updatedAt: Timestamp(2024-02-01)
│
├── category_2/
│   ├── name: "Diabetes"
│   ├── iconAsset: "assets/icons/diabetes.png"
│   ├── aliases: ["Blood Sugar", "Type 1", "Type 2"]
│   ├── isVisible: true
│   ├── order: 2
│   ├── createdAt: Timestamp(2024-01-02)
│   └── updatedAt: Timestamp(2024-02-01)
│
├── category_3/
│   ├── name: "Respiratory Disease"
│   ├── iconAsset: "assets/icons/respiratory.png"
│   ├── aliases: ["Asthma", "COPD", "Lung Disease"]
│   ├── isVisible: false (under development)
│   ├── order: 99
│   ├── createdAt: Timestamp(2024-02-15)
│   └── updatedAt: Timestamp(2024-02-20)
│
└── category_N/
    └── ... (similar structure)
```

### Field Descriptions

**Core Fields**:

- `id`: Unique category identifier (matches document ID)
- `name`: Display name (e.g., "Heart Disease")
- `iconAsset`: File path to icon asset (e.g., "assets/icons/heart.png")
- `aliases`: Array of search keywords/alternative names
- `isVisible`: Boolean - whether category appears to users
- `order`: Integer - display sequence (ascending)

**Admin Fields**:

- `createdAt`: Timestamp of creation (server-generated)
- `updatedAt`: Timestamp of last modification (server-generated)
- `createdBy`: Admin UID who created (optional)
- `updatedBy`: Admin UID who last modified (optional)

### Indexes Required

**Single Field Indexes**:

- `isVisible`: For "visible categories only" queries
- `order`: For sorting by display order
- `createdAt`: For sorting by recency

**Composite Indexes**:

1. **(isVisible, order)**
   - For fetching visible categories in order (used by app)
2. **(isVisible, createdAt DESC)**
   - For recently added visible categories

---

## Access Control

### Admin Role Capabilities

**Admin Can**:

- ✅ View all categories (visible and hidden)
- ✅ Create new categories
- ✅ Edit category information
- ✅ Change display order
- ✅ Toggle visibility
- ✅ Manage search aliases
- ✅ Delete categories (with confirmation)
- ✅ View category usage/associations
- ✅ Audit category modifications

**Admin Cannot**:

- ❌ Modify system-level category settings
- ❌ Change category ID/unique identifier
- ❌ Bypass visibility controls
- ❌ Access other admin settings
- ❌ Modify user roles

---

## Simple Security Guidelines

1. **Admin-Only Access**: Restrict admin dashboard to admin role only
2. **Visibility Enforcement**: Only fetch visible categories for regular users
3. **Activity Logging**: Log all admin modifications with timestamp and admin ID
4. **Confirmation Required**: Deletion and major changes need confirmation
5. **Icon Validation**: Verify icon assets exist before saving
6. **Alias Review**: Ensure aliases are medically appropriate
7. **Order Consistency**: Maintain proper ordering after updates

---

## Configuration & Setup

### Enable Firestore Indexes

Ensure these indexes exist for optimal performance:

1. **Index**: `isVisible` + `order` (ascending)

   - Used: `getVisibleCategories()` query
   - Purpose: Fetch visible categories in display order

2. **Index**: `isVisible` + `createdAt` (descending)
   - Used: Admin view of recent categories
   - Purpose: Show latest changes first

---

## Summary

This admin dashboard provides essential category management:

- ✅ **View Categories**: Complete visibility of all categories
- ✅ **Create Categories**: Add new medical condition categories
- ✅ **Edit Information**: Update names, icons, aliases
- ✅ **Manage Visibility**: Control what users see
- ✅ **Organize Display**: Set category order priority
- ✅ **Search Optimization**: Manage aliases for discoverability
- ✅ **Safe Operations**: Soft delete via visibility toggle
- ✅ **Audit Trail**: Track all modifications

**What's NOT Included** (too complex for academic project):

- ❌ Category hierarchies/parent-child relationships
- ❌ Complex categorization rules
- ❌ Multi-language translations
- ❌ Complex usage analytics
- ❌ Automatic category suggestions
- ❌ Category association workflows
- ❌ Advanced permission systems

This keeps admin functionality practical and implementable for an in-app admin dashboard suitable for a small academic project.
