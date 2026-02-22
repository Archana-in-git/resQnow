# Medical Conditions Module - Admin Functionalities Reference

## Overview

This document outlines the **Admin Dashboard capabilities** for managing medical conditions in the ResQnow Medical Conditions Module. Medical conditions content provides comprehensive information about health emergencies including first aid guidance, severity assessment, FAQs, and professional medical resources. Since this is an academic project with a small user base, the admin features focus on **practical, essential operations** for managing medical condition content.

**Current Status**: Read-only user implementation; Admin functionalities documented for future implementation.

**Technology**: Firebase Firestore, Flutter, Provider State Management

---

## Table of Contents

1. [Condition Management](#condition-management)
2. [Condition Content Configuration](#condition-content-configuration)
3. [Search & Discovery](#search--discovery)
4. [Admin Tasks & Workflows](#admin-tasks--workflows)
5. [Admin Dashboard Components](#admin-dashboard-components)
6. [Firestore Schema for Admin](#firestore-schema-for-admin)
7. [Access Control](#access-control)

---

## Condition Management

### 1. View All Medical Conditions

**Responsibility**: ConditionService.getAllConditions() (already exists for users)

**Admin Actions**:

- Fetch complete list of all medical conditions
- Display all health condition data
- View condition metadata
- Monitor total conditions count
- Review condition distribution by severity

**Data Visible**:

- Condition name
- Severity level (low, medium, high, critical)
- Image count
- FAQ count
- Doctor specializations needed
- Hospital locator availability

**Use Cases**:

- Get system overview of medical content
- Monitor condition library completeness
- Verify condition availability
- Audit medical content collection
- Plan content updates

**Current Implementation**: ✅ ConditionService.getAllConditions()

---

### 2. View Individual Condition Details

**Responsibility**: ConditionService.getConditionById() (already exists for users)

**Admin Can View**:

- Condition name
- Severity level (low, medium, high, critical)
- First aid description (multiple steps)
- Video URL (educational resource)
- FAQs (questions and answers)
- Doctor types (specializations needed)
- Hospital locator link
- Creation/modification timestamps

**Use Cases**:

- Review complete medical condition information
- Verify accuracy of first aid guidance
- Check severity classification
- Review FAQ completeness
- Validate doctor specializations
- Verify external links (hospital locator)

**Current Implementation**: ✅ ConditionDetailPage (displays all data)

---

### 3. Create New Medical Condition (**NOT YET IMPLEMENTED**)

**Responsibility**: ConditionService.addCondition() (to be implemented)

**Admin Actions**:

- Add new medical condition
- Define comprehensive condition information
- Classify severity level
- Provide first aid guidance
- Add educational video
- Create FAQ content
- Specify doctor specializations
- Link to hospital locator

**Data To Create**:

- `name`: Condition name (e.g., "Heat Stroke")
- `severity`: Level classification (low/medium/high/critical)
- `imageUrls`: Educational images (one or multiple)
- `firstAidDescription`: Step-by-step first aid guidance (array of steps)
- `videoUrl`: Educational video URL
- `faqs`: Frequently asked questions (array with question + answer)
- `doctorType`: Specializations (e.g., ["Cardiologist", "Emergency Medicine"])
- `hospitalLocatorLink`: URL to find nearby hospitals/clinics
- `createdAt`: Auto-generated timestamp
- `updatedAt`: Auto-generated timestamp

**Validation Required**:

- Name: Non-empty, 3+ characters
- Severity: One of (low/medium/high/critical)
- First aid description: At least one step
- Video URL: Valid HTTP/HTTPS URL (optional)
- FAQs: Recommended for completeness
- Doctor types: At least one specialization
- Hospital link: Valid URL for medical resource location

**Use Cases**:

- Add new medical condition (e.g., "Anaphylaxis")
- Include comprehensive first aid procedures
- Document severity classifications
- Create medical guidance content
- Provide specialist recommendations
- Enable professional medical consultation pathways

**Future Implementation**: Will create ConditionAdminController with createCondition()

---

### 4. Edit Medical Condition (**NOT YET IMPLEMENTED**)

**Responsibility**: ConditionService.updateCondition() (to be implemented)

**Admin Can Edit**:

- Condition name
- Severity classification
- Image URLs
- First aid description (add/remove/reorder steps)
- Video URL
- FAQ entries (add/remove/update)
- Doctor specializations
- Hospital locator link

**Admin Cannot Edit** (Protected):

- Condition ID
- Creation timestamp
- User-generated content (saved conditions)

**Important**:

- Modification timestamp auto-updates
- Creation timestamp preserved
- All changes effective immediately
- Previous versions not tracked

**Use Cases**:

- Update severity based on new medical guidelines
- Add new first aid steps based on latest protocols
- Improve description clarity
- Expand FAQ based on user questions
- Update doctor specialization recommendations
- Fix incorrect information
- Add new images or videos

**Example Scenarios**:

1. **New Medical Guidelines**: Update first aid steps based on latest medical standards
2. **Enhanced Images**: Add better quality instructional images
3. **Expanded FAQ**: Add new FAQs based on common user questions
4. **Severity Update**: Reclassify condition based on medical review
5. **Video Updates**: Replace with newer educational videos

**Future Implementation**: Will create updateConditionData() method

---

### 5. Delete Medical Condition (**NOT YET IMPLEMENTED**)

**Responsibility**: ConditionService.deleteCondition() (to be implemented)

**Admin Actions**:

- Permanently remove condition from system
- Delete all associated metadata
- Remove from user view

**Important Considerations**:

- **Hard Delete**: Condition completely removed from Firestore
- **Data Loss**: Cannot be recovered without backup
- **User Impact**: Breaks saved topics referencing this condition
- **Recommendation**: Use visibility toggle instead (when implemented)
- **Confirmation Required**: Must confirm deletion dialog

**Use Cases**:

- Remove obsolete medical conditions
- Delete duplicate condition entries
- Remove test/temporary conditions
- Clean up incorrect medical information
- Remove conditions consolidated with others

**Caution**: Deleting removes access for all users including those who saved the condition

**Future Implementation**: Will create deleteCondition() method with confirmation

---

### 6. Severity Classification Management (**NOT YET IMPLEMENTED**)

**Responsibility**: Update `severity` field (to be implemented)

**Severity Levels**:

- **Low**: Minor health issues, can manage with basic first aid
  - Examples: Minor cuts, mild headache, small burn
- **Medium**: Moderate health issues, require professional attention
  - Examples: Moderate wound, severe burn, suspected fracture
- **High**: Serious health emergencies, require immediate medical care
  - Examples: Heavy bleeding, severe allergic reaction, chest pain
- **Critical**: Life-threatening emergencies, call 911/ambulance immediately
  - Examples: Cardiac arrest, severe anaphylaxis, loss of consciousness

**Admin Actions**:

- Classify condition correctly by severity
- Update severity if medical consensus changes
- Ensure appropriate urgency level
- Trigger correct UI indicators (color-coded severity display)

**Current User View**:

- ✅ SeverityIndicator widget displays color-coded severity
- ✅ ConditionDetailPage shows severity prominently

**UI Impact**:

- Severity level controls display color and icon
- High/Critical conditions show urgent action indicators
- Affects sorting and prioritization in user view

**Future Admin Implementation**:

```dart
// During condition creation/edit:
const severityLevels = ['low', 'medium', 'high', 'critical'];
await conditionService.updateCondition(id, {
  severity: selectedSeverityLevel,
  updatedAt: DateTime.now(),
});
```

---

## Condition Content Configuration

### 1. First Aid Description Management

**Purpose**: Provide step-by-step first aid guidance

**Structure**: Array of description steps

- Each step is a string describing one action
- Steps displayed in order to user
- Clear, actionable language

**Admin Responsibilities**:

- Write clear, actionable first aid steps
- Follow latest medical guidelines
- Test procedures for accuracy
- Organize steps in logical sequence
- Use medical accuracy

**Example Steps**:

```
Resource: "Severe Burn Management"

Steps:
1. "Remove person from heat source immediately"
2. "Cool the burn with cool (not ice-cold) water for 10-15 minutes"
3. "Remove tight items like rings, bracelets, watches"
4. "Cover burn with clean, dry cloth to prevent infection"
5. "Do NOT apply ice directly to skin"
6. "Do NOT apply butter, oil, or ointments"
7. "If burn is large or deep, call ambulance"
8. "Elevate burned area if possible to reduce swelling"
```

**Validation**:

- Minimum 1-2 steps
- Clear language
- Medically accurate
- Safe recommendations

**Current User View**: FirstAidDescription section shows steps in order

---

### 2. Video Resource Management

**Purpose**: Provide visual learning aids

**Structure**: Single URL to educational video

- Can be YouTube, Vimeo, or embedded video
- Shows demonstration of technique
- Professional medical video preferred

**Admin Responsibilities**:

- Source high-quality medical education videos
- Ensure videos show correct procedures
- Test video URLs for access
- Provide closed captioning if possible
- Use reputable medical sources

**Video Criteria**:

- ✅ Medically accurate
- ✅ Clear demonstrations
- ✅ Professional production
- ✅ Publicly accessible
- ✅ Appropriate length (2-10 minutes)

**Current User View**: VideoPlayerWidget displays embedded video

**Admin Implementation**:

```dart
final videoUrl = "https://youtube.com/watch?v=medical_video_id";
// or
final videoUrl = "https://vimeo.com/medical_video_id";

await conditionService.updateCondition(id, {
  videoUrl: videoUrl,
});
```

---

### 3. FAQ Management

**Purpose**: Address common user questions

**Structure**: Array of question-answer pairs

- Each item has question and answer
- Organized in accordion widget (expandable)
- Common questions prioritized

**Admin Responsibilities**:

- Identify common user questions
- Provide clear, accurate answers
- Base answers on medical guidelines
- Update based on new questions
- Keep FAQs concise but complete

**Example FAQs**:

```
Condition: "Cardiac Arrest"

Q1: "How long can brain survive without blood flow?"
A1: "Brain damage begins within 3-4 minutes. Permanent damage occurs after 6 minutes."

Q2: "Should I perform CPR if I'm untrained?"
A2: "Yes! Hands-only CPR is better than no CPR. Follow instructions from 911 operator."

Q3: "When should I use an AED?"
A3: "AED helps restart heart rhythm in sudden cardiac arrest. Use as soon as available."

Q4: "How do I know if someone has cardiac arrest?"
A4: "Person is unresponsive and not breathing. These are the two signs."
```

**Current User View**: FAQAccordion widget shows expandable Q&A

**Admin Implementation**:

```dart
final faqs = [
  FaqItem(
    question: "How long can brain survive without blood flow?",
    answer: "Brain damage begins within 3-4 minutes..."
  ),
  FaqItem(
    question: "When should I use an AED?",
    answer: "AED helps restart heart rhythm..."
  ),
];
```

---

### 4. Doctor Specialization Management

**Purpose**: Recommend appropriate medical professionals

**Structure**: Array of doctor type strings

- Medical specializations (e.g., "Cardiologist", "Orthopedist")
- Multiple specializations per condition
- Users guided to appropriate doctors

**Admin Responsibilities**:

- Identify relevant medical specializations
- List primary and secondary doctors
- Ensure accuracy (e.g., heart condition = Cardiologist)
- Update based on medical consensus
- Guide users to appropriate care

**Example Specializations**:

```
Condition: "Myocardial Infarction (Heart Attack)"
Doctor Types: ["Cardiologist", "Emergency Medicine", "Cardiac Surgeon"]

Condition: "Fracture"
Doctor Types: ["Orthopedist", "Emergency Medicine", "Trauma Surgeon"]

Condition: "Severe Allergic Reaction"
Doctor Types: ["Allergist", "Immunologist", "Emergency Medicine"]
```

**Current User View**: Doctor types displayed in condition details

**Future Hospital Integration**: Hospital locator can filter by doctor type

---

### 5. Hospital Locator Integration

**Purpose**: Connect users to nearby medical facilities

**Structure**: URL to hospital/clinic locator service

- External link to medical facility finder
- Can be Google Maps search, dedicated app, local directory
- Guides users to appropriate care

**Admin Responsibilities**:

- Provide accurate locator links
- Test links for functionality
- Ensure links lead to appropriate facilities
- Update if services change
- Consider regional variations

**Example Links**:

```
Condition: "Cardiac Emergency"
Link: "https://www.google.com/maps/search/cardiologist+near+me"
Or: "https://www.practo.com/search/doctors/cardiologist"

Condition: "Orthopedic Fracture"
Link: "https://www.google.com/maps/search/orthopedist+hospital+near+me"
```

**Current User View**: Button to open hospital locator link externally

---

## Search & Discovery

### Search by Condition Name

**Purpose**: Find conditions by medical name

**Search Behavior**:

- Case-insensitive matching
- Partial name matching
- Real-time filtering

**Query Examples**:

```
User searches: "cardiac"
Results: Cardiac Arrest, Myocardial Infarction, Cardiac Arrhythmia

User searches: "stroke"
Results: Heat Stroke, Stroke (Cerebrovascular), Mini-Stroke

User searches: "allergy"
Results: Allergic Reaction, Severe Allergy, Anaphylaxis
```

---

### Filter by Severity Level

**Purpose**: Find conditions by urgency

**Current Filters**:

- Low: Minor health issues
- Medium: Moderate issues requiring attention
- High: Serious emergencies
- Critical: Life-threatening (immediate action needed)

**Use Cases**:

- View all critical emergencies
- Review high-priority conditions
- Browse general health information
- Learn about different severity levels

---

### Browse by Medical Topic

**Purpose**: Organize conditions by category (if implemented)

**Potential Categories**:

- Cardiovascular emergencies
- Respiratory emergencies
- Allergic reactions
- Trauma/Injuries
- Environmental emergencies
- Poisoning/Overdose
- Neurological emergencies
- Gastrointestinal emergencies

---

## Admin Tasks & Workflows

### Workflow 1: Create New Medical Condition

**Scenario**: Add "Severe Anaphylaxis" condition to system

**Steps**:

1. **Open Condition Creation Form** (to be implemented)
2. **Enter Basic Information**:
   - Name: "Severe Anaphylaxis"
   - Severity: Critical
3. **Add Images**:
   - Upload 2-3 images showing symptoms/treatment
   - Provide image URLs
4. **Write First Aid Description**:
   - Step 1: "Inject epinephrine immediately (if available)"
   - Step 2: "Call emergency services (911/ambulance)"
   - Step 3: "Lie person down with feet elevated"
   - Step 4: "If available, apply second epinephrine if no improvement after 5-15 minutes"
   - Step 5: "Monitor breathing and pulse"
5. **Add Do's and Don'ts**:
   - Do's: "Call 911", "Inject epi-pen", "Keep lying down"
   - Don'ts: "Don't delay epi-pen", "Don't give food/drink", "Don't leave alone"
6. **Add Video URL**:
   - URL: "https://youtube.com/anaphylaxis_video"
7. **Define Required Kits**:
   - Epinephrine auto-injector
   - Antihistamine tablets
   - Corticosteroid tablets
   - Oxygen (if available)
8. **Add FAQs**:
   - Q: "Can I use someone else's epinephrine?"
   - A: "Yes, in life-threatening situation use any available epi-pen"
   - Q: "After epinephrine, do I still need hospital?"
   - A: "Yes, always go to hospital even if symptoms improve"
9. **Set Doctor Specializations**:
   - Allergist
   - Immunologist
   - Emergency Medicine
10. **Add Hospital Locator Link**:
    - "https://www.google.com/maps/search/hospital+near+me"
11. **Save to Firestore**:
    - Auto-generates ID and timestamps
    - Condition immediately available to users

**Result**:

```json
{
  "id": "auto_generated_id",
  "name": "Severe Anaphylaxis",
  "imageUrls": ["url1", "url2", "url3"],
  "severity": "critical",
  "firstAidDescription": [
    "Inject epinephrine immediately",
    "Call emergency services",
    "Lie person down with feet elevated",
    "Apply second epinephrine if needed",
    "Monitor breathing and pulse"
  ],
  "doNotDo": [
    "Don't delay epinephrine injection",
    "Don't give food or drink",
    "Don't leave person alone"
  ],
  "videoUrl": "https://youtube.com/anaphylaxis_video",
  "requiredKits": [
    {"name": "Epinephrine Auto-injector", "iconUrl": "..."},
    {"name": "Antihistamine", "iconUrl": "..."},
    {"name": "Corticosteroid", "iconUrl": "..."}
  ],
  "faqs": [
    {"question": "Can I use someone else's epi-pen?", "answer": "Yes..."},
    {"question": "Do I need hospital after epi?", "answer": "Yes..."}
  ],
  "doctorType": ["Allergist", "Immunologist", "Emergency Medicine"],
  "hospitalLocatorLink": "https://www.google.com/maps/search/hospital+near+me",
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

**Time to Complete**: ~15-20 minutes per condition

---

### Workflow 2: Update Existing Condition

**Scenario**: Update "CPR" based on new medical guidelines

**Steps**:

1. **Find Condition**: Search for "CPR" in admin dashboard
2. **Open Edit Form**:
   - All fields pre-populated
3. **Update First Aid Steps**:
   - Change compression depth: "2 inches" (from 1.5)
   - Update compression rate: "100-120 per minute"
   - Modify steps based on new guidelines
4. **Update Video** (optional):
   - Replace with newer training video
5. **Add FAQ**:
   - New question: "Can I do CPR on a child?"
   - Answer: "Yes, use gentler technique with single hand"
6. **Update Required Kits** (optional):
   - Add: "CPR Face Shield"
7. **Save Changes**:
   - Updated timestamp auto-updates
   - Creation timestamp preserved
   - Changes immediately effective

**Result**: Users see updated CPR guidance on next app refresh

---

### Workflow 3: Delete Outdated Condition

**Scenario**: Remove consolidated condition

**Steps**:

1. **Find Condition**: "Minor Burns"
2. **Review**: Verify before deletion
3. **Check Usage**: See if users saved it
4. **Click Delete**:
   - Confirmation dialog appears
5. **Confirm**:
   - PermVideo URL\*\*:
   - URL: "https://youtube.com/anaphylaxis_video"
     6\*Scenario\*\*: Review and validate condition severity levels

**Steps**:

1. **Review Severity Distribution**:
2. **Set Doctor Specializations**:
   - Allergist
   - Immunologist
   - Emergency Medicine
3. **Add Hospital Locator Link**:
   - "https://www.google.com/maps/search/hospital+near+me"
     9 - Change severity if needed
   - Test UI display (color changes)
4. **Verify Result**:
   - Severity indicators display correctly
   - Appropriate urgency messaging shows

---

### Workflow 5: Review Content Completeness

**Scenario**: Admin audit of condition information quality

**Steps**:

1. **Review Each Condition**:

   - Name: Present and clear? ✓
   - Severity: Correctly classified? ✓
   - First Aid Steps: Clear and complete? ✓
     videoUrl": "https://youtube.com/anaphylaxis_video"- Expand sparse FAQs
   - Improve unclear descriptions
   - Update outdated video links

2. **Quality Check**:
   - Test all links (video, hospital locator)
   - Verify medical accuracy
   - Check clarity of language

---

## Admin Dashboard Components

### Recommended Admin Pages

#### 1. **Condition Admin List Page**

(condition_admin_list_page.dart - to be created)

**Components**:

- AppBar with title: "Manage Medical Conditions"
- FAB button: "Add New Condition" (+)
- Search bar for quick lookup
- Filter chips: By severity level
- Condition cards showing:
  - Condition name
  - Severity indicator (color-coded)
  - First aid steps count
  - FAQ count
  - Doctor types summary
  - Edit button (pencil icon)
  - Delete button (trash icon)
- Summary stats:
  - Tresh indicator (pull-to-refresh)

**Actions**:

- Tap FAB → Opens create form
- Tap Edit → Opens edit form
- Tap Delete → Shows confirmation dialog
- Search → Real-time filtering
- Filter → Severity-based filtering

---

#### 2. **Condition Admin Detail Page**

(condition_admin_detail_page.dart - to be created)

**Purpose**: Create/Edit condition

**Form Sections**:

**Basic Information**:

- Text input: Condition name \*
- Dropdown: Severity (Low/Medium/High/Critical) \*
- Text area: Brief description

**First Aid Content**:

- Dynamic list: First aid steps (add/remove/reorder) \*
- Dynamic list: Do's (add/remove)
- Dynamic list: Don'ts (add/remove)

**Images & Video**:

- Text area: Image URLs (one per line) \*
- Text input: Video URL (optional)

**Medical Content**:

- Dynamic list: Required medical kits (add/remove) \*
  - Each kit has: name + icon URL
- Dynamic list: FAQs (add/remove)
  - Each FAQ has: question + answer

**Professional Content**:

- Dynamic list: Doctor specializations (add/remove) \*
- Text input: Hospital locator link \*

**Actions**:

- Button: Create / Update
- Button: Cancel

**Validation**:

- All fields marked with \* are required
- At least one image URL
- Valid URLs for video and hospital link
- At least one medical kit

---Video: Working and relevant

(condition_stats_widget.dart - optional)

**Components**:

- Total conditions count
- Count breakdown by severity (Low/Medium/High/Critical)
- Conditions with incomplete info (missing video/FAQ)
- Recently added conditions
- Recently modified conditions
- Most referenced conditions (by user saves)

---

## Firestore Schema for Admin

### Conditions Collection (`conditions`)

**Collection Path**: `conditions/{docId}`

**Document Structure**:

````
conditions/
├── doc_1/
│   ├── id: "doc_1"
│   ├── name: "Cardiac Arrest"
│   ├── severity: "critical"
│   ├── imageUrls: [
│   │   "https://cdn.example.com/cardiac-1.jpg",
│   │   "https://cdn.example.com/cardiac-2.jpg"
│   │ ]
│   ├── firstAidDescription: [
│   │   "Check responsiveness",
│   │   "Call emergency services",
│   │   "Start CPR immediately",
│   │   "Use AED if available",
│   │   "Continue until ambulance arrives"
│   │ ]
│   ├── doNotDo: [
│   │   "Don't delay CPR",
│   │   "Don't stop CPR until professional takes over",
│   │   "Don't move person unnecessarily"
│   │ ]
│   ├── videoUrl: "https://youtube.com/cardiac_arrest_video"
│   ├── requiredKits: [
│   │   {"name": "AED", "iconUrl": "https://cdn.example.com/aed-icon.png"},
│   │   {"name": "CPR Mask", "iconUrl": "https://cdn.example.com/mask-icon.png"}
│   │ ]
│   ├── faqs: [
│   │   {
│   │     "question": "Can I do CPR on a child?",
│   │     "answer": "Yes, use single hand and gentler technique"
│   │   },
│   │   {
│   │     "question": "How long can brain survive?",
│   │     "answer": "Brain damage begins after 3-4 minutes"
│   │   }
│   │ ]
│   ├── doctorType: ["Cardiologist", "Emergency Medicine", "Cardiac Surgeon"]
│   ├── hospitalLocatorLink: "https://www.google.com/maps/search/hospital+near+me"
│   ├── createdAt: Timestamp(2024-01-15T10:30:00Z)
│   └── updatedAt: Timestamp(2024-02-20T14:45:00Z)
│
├── doc_2/
│   ├── name: "Severe Burn"
│   ├── severity: "high"
│   ├── imageUrls: [...]
│   ├── firstAidDescription: [
│   │   "Remove from heat source",
│   │   "Cool with water for 10-15 minutes",
│   │   "Remove tight items",
│   │   "Cover with clean cloth",
│   │   "Call ambulance for large burns"
│   │ ]videoUrl: "https://youtube.com/cardiac_arrest_video"-------------- | --------- | -------- | ------- | ----------------------------------------------- |
| id                  | String    | Yes      | No      | Auto-generated by Firestore                     |
| name                | String    | Yes      | Yes     | Medical condition name                          |
| severity            | String    | Yes      | Yes     | One of: low/medium/high/critical                |
| imageUrls           | Array     | Yes      | Yes     | Educational images                              |
| firstAidDescription | Array     | Yes      | Yes     | Step-by-step guidance (string array)            |
| doNotDo             | Array     | No       | Yes     | Important precautions                           |
| videoUrl            | String    | No       | Yes     | Educational video URL                           |
| requiredKits        | Array     | Yes      | Yes     | Medical kits needed (objects with name+iconUrl) |
| faqs                | Array     | No       | Yes     | FAQ items (objects with question+answer)        |
| doctorType          | Array     | Yes      | Yes     | Medical specializations (string array)          |
| hospitalLocatorLink | String    | Yes      | Yes     | URL to find medical facilities                  |
| createdAt           | Timestamp | Yes      | No      | Creation timestamp                              |
| updatedAt           | Timestamp | Yes      | Yes     | Last modification timestamp                     |

### Firestore Indexes Required

**Single Field Indexes**:

1. `severity` (Ascending)
"..."]d, "new content" display

3. `updatedAt` (Descending)
   - Query: Recently modified conditions
   - Used by: Admin audit trail, content freshness

**Composite Indexes**:

1. `(severity, createdAt DESC)`
   - Query: Recent conditions by severity
   - Used by: Dashboard "critical emergency" highlights

---

## Access Control

### Admin Role Capabilities

**Admin Can**:

- ✅ View all conditions
- ✅ Create new conditions
- ✅ Edit condition information
- ✅ Delete conditions
- ✅ Manage first aid descriptions
- ✅ Manage do's and don'ts
- ✅ Manage medical kits
- ✅ Manage FAQs
- ✅ Classify severity levels
- ✅ Assign doctor specializations
- ✅ Search and filter conditions

**Admin Cannot** (Restricted):

- ❌ Modify condition IDs
- ❌ Change creation timestamps
- ❌ Access user saved conditions data
- ❌ Modify user-level settings
- ❌ Delete system-level configurations

**Regular User Can**:

- ✅ View published conditions
- ✅ Search conditions
- ✅ Filter by severity
- ✅ Read first aid guidance
- ✅ Watch videos
- ✅ Access FAQs
- ✅ Find nearby hospitals
- ✅ Save conditions
- ❌ Create/edit/delete conditions

---

### Implementation Approach

**Firestore Security Rules** (Recommended):

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /conditions/{document=**} {
      // Allow read for all authenticated users
      allow read: if request.auth != null;

      // Allow write only for admins
      allow create, update, delete: if request.auth != null &&
                                       'admin' in request.auth.token.claims;
    }
  }
}
````

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

| Operation                  | Current Status  | Can Be Implemented | Component                           |
| -------------------------- | --------------- | ------------------ | ----------------------------------- |
| **View All Conditions**    | ✅ Implemented  | N/A (already done) | ConditionService.getAllConditions() |
| **View Condition Details** | ✅ Implemented  | N/A (already done) | ConditionDetailPage                 |
| **Create Condition**       | ❌ Not yet      | ✅ Yes             | condition_admin_detail_page.dart    |
| **Edit Condition**         | ❌ Not yet      | ✅ Yes             | condition_admin_detail_page.dart    |
| **Delete Condition**       | ❌ Not yet      | ✅ Yes             | condition_admin_list_page.dart      |
| **Manage First Aid Steps** | ❌ Not yet      | ✅ Yes             | condition_admin_detail_page.dart    |
| **Manage Do's/Don'ts**     | ❌ Not yet      | ✅ Yes             | condition_admin_detail_page.dart    |
| **Manage Medical Kits**    | ❌ Not yet      | ✅ Yes             | condition_admin_detail_page.dart    |
| **Manage FAQs**            | ❌ Not yet      | ✅ Yes             | condition_admin_detail_page.dart    |
| **Classify Severity**      | ❌ Not yet      | ✅ Yes             | condition_admin_detail_page.dart    |
| **Manage Doctor Types**    | ❌ Not yet      | ✅ Yes             | condition_admin_detail_page.dart    |
| **Search Conditions**      | ✅ Can be added | ✅ Yes (admin UI)  | condition_admin_list_page.dart      |
| **Filter by Severity**     | ✅ Can be added | ✅ Yes (admin UI)  | condition_admin_list_page.dart      |

---

## Pages to Be Implemented

### 1. `condition_admin_list_page.dart`

**Purpose**: Admin dashboard for condition management
**Features**:

- List all conditions
- Search by name
- Filter by severity level
- Edit button for each condition
- Delete button for each condition
- Add new condition FAB
- Summary statistics (total count, count by severity)

**Controller to Create**: `ConditionAdminController` (extends ChangeNotifier)

### 2. `condition_admin_detail_page.dart`

**Purpose**: Create/Edit condition form
**Features**:

- Form fields for all condition data
- Severity dropdown selector
- Dynamic lists for:
  - First a kits (with icon URLs)
  - FAQs (question + answer pairs)
  - Doctor specializations
- Image URL input
- Video URL input
- Hospital locator link input
- Validation
- Submit/Cancel buttons

**Use Case Patterns**:

- Create mode: Empty form, "Create" button
- Edit mode: Pre-filled form, "Update" button

---

## Use Cases (To Be Implemented)

### Use Case 1: CreateCondition

**Input**: Condition details (all fields)
**Process**: Validate → Create in Firestore → Auto-generate ID
**Output**: Condition ID, Success message

### Use Case 2: UpdateCondition

**Input**: Condition ID, Updated fields
**Process**: Validate → Update in Firestore → Preserve createdAt
**Output**: Success message

### Use Case 3: DeleteCondition

**Input**: Condition ID
**Process**: Confirm → Delete from Firestore
**Output**: Success message

### Use Case 4: ListAllConditions

**Input**: Optional filters (severity, search query)
**Process**: Fetch from Firestore with optional filtering
**Output**: List of conditions

---

## Implementation Notes for Developer

### Service Layer Additions Needed

```dart
// In ConditionService:
Future<String> addCondition(ConditionModel condition);
Future<void> updateCondition(String id, ConditionModel condition);
Future<void> deleteCondition(String id);
Future<List<ConditionModel>> searchConditions(String query);
Future<List<ConditionModel>> filterBySeverity(String severity);
```

### New Use Cases to Create

```
lib/domain/usecases/
├── add_condition.dart
├── update_condition.dart
└── delete_condition.dart
```

### New Admin Controller

```
lib/features/medical_conditions/presentation/controllers/
└── condition_admin_controller.dart
```

### New Admin Pages

```
lib/features/medical_conditions/presentation/pages/
├── condition_admin_list_page.dart
└── condition_admin_detail_page.dart
```

---

## Conclusion

The Medical Conditions module has **significant admin management potential** that mirrors other content modules. While currently read-only in implementation, the following admin functionalities are **clearly applicable and implementable**:

✅ **Create Conditions** - Add new medical emergencies  
✅ **Edit Conditions** - Update first aid guidance  
✅ **Delete Conditions** - Remove obsolete information  
✅ **Manage First Aid Steps** - Organize procedure guidance  
✅ **Manage Medical Kits** - List required supplies  
✅ **Manage FAQs** - Address user questions  
✅ **Classify Severity** - Categorize emergency levels  
✅ **Manage Doctor Types** - Recommend specializations  
✅ **Manage Hospital Links** - Connect to medical facilities

This documentation provides the complete roadmap for implementing admin functionalities. The module can be made admin-friendly following the same architectural patterns as existing modules.

**Implementation Status**: Documentation complete for future developer implementation.

---

**Document Status**: Admin Functionalities Reference Guide
**Applicable for Admin Management**: ✅ YES
**Recommended for Implementation**: ✅ YES (following same pattern as other modules)
**Scope**: Academic project - practical admin operations only
