# Blood Donor Module - Admin Functionalities Reference

## Overview

This document outlines the **Admin Dashboard capabilities** for managing blood donors in the ResQnow Blood Donor Module. Since this is an academic project with a small user base (max ~10 users), the admin features focus on **practical, essential operations** for managing registered blood donors.

**Technology**: Firebase Firestore, Firebase Auth, Firebase Storage, Flutter

---

## Table of Contents

1. [Donor Account Management](#donor-account-management)
2. [Donor Information Management](#donor-information-management)
3. [Search & Filtering](#search--filtering)
4. [Donor Monitoring & Analytics](#donor-monitoring--analytics)
5. [Admin Tasks & Workflows](#admin-tasks--workflows)
6. [Admin Dashboard Components](#admin-dashboard-components)
7. [Firestore Schema for Admin](#firestore-schema-for-admin)
8. [Access Control](#access-control)

---

## Donor Account Management

### 1. View All Donors

**Responsibility**: BloodDonorService.getAllDonors()

**Admin Actions**:

- Fetch complete list of registered donors
- Display donor summary information
- Browse all donors in the system

**Data Visible**:

- Donor name
- Blood group
- District and town
- Availability status
- Registration date
- Contact information

**Use Cases**:

- Get system overview
- Monitor registered donors
- Verify community size
- Identify inactive donors

**Permissions Required**:

- Read access to `donors` collection

---

### 2. View Individual Donor Profile

**Responsibility**: BloodDonorService.getDonorById()

**Admin Can View**:

- Full name and age
- Gender and blood group
- Email and phone number
- Complete address details
- District and town
- Medical conditions
- Health notes
- Availability status
- Last login/activity timestamp
- Profile picture
- Registration date

**Use Cases**:

- Review donor details
- Verify information accuracy
- Check contact information
- Assess donor profile completeness

**Permissions Required**:

- Read access to individual donor documents

---

### 3. Suspend Donor Account

**Responsibility**: BloodDonorService.updateDonor()

**Admin Actions**:

- Temporarily disable donor profile visibility
- Add suspension reason
- Mark suspension timestamp
- Document suspending admin

**Data Fields Updated**:

- `isAvailable`: Set to false (soft suspend)
- `suspendedAt`: Current timestamp
- `suspendedBy`: Admin UID
- `suspensionReason`: Text reason

**Use Cases**:

- Donor violates community guidelines
- Suspicious/fraudulent activity detected
- Temporary deactivation request
- Medical/health concerns

**Note**: Profile remains in database for records (soft delete)

---

### 4. Delete Donor Account

**Responsibility**: BloodDonorService.deleteDonor()

**Admin Actions**:

- Permanently remove donor from system
- Delete all profile data
- Remove from search results

**Data Deleted**:

- Complete donor document
- Profile picture (from Storage)
- All associated records

**Use Cases**:

- User requests permanent deletion
- Test/spam account removal
- Data cleanup

**Permissions Required**:

- Delete access to Firestore documents
- Delete access to Storage files
- Confirmation required to prevent accidental deletion

---

### 5. Edit Donor Information

**Responsibility**: BloodDonorService.updateDonor()

**Admin Can Edit**:

- Name (correct registration errors)
- Blood group
- Medical conditions
- Health notes
- Address details
- Pincode
- Town/district

**Admin Cannot Edit** (Protected):

- Email (linked to authentication)
- User ID/UID
- Registration date
- Phone number (should use support ticket)

**Use Cases**:

- Correct information errors
- Update health conditions
- Fix address typos
- Update availability

**Permissions Required**:

- Update access to donor documents
- Audit trail for all modifications

---

## Donor Information Management

### 1. Blood Group Management

**Purpose**: Track and manage blood group distribution

**Admin Can View**:

- All registered blood groups
- Count of donors per blood group
- Availability by blood group

**Blood Groups Tracked**:

- A+, A-, B+, B-, O+, O-, AB+, AB-

**Use Cases**:

- Understand donor diversity
- Identify rare blood type donors
- Match donors with requests
- Plan donor recruitment

**Data Retrieved**:

- Blood group field from each donor
- Filter by availability status

---

### 2. Medical Conditions Tracking

**Purpose**: Monitor health conditions in donor population

**Admin Can View**:

- Medical conditions for each donor
- Count of donors with specific conditions
- Health risk assessment

**Tracked Conditions**:

- Diabetes
- Blood Pressure
- Thyroid
- Asthma
- None (healthy)

**Use Cases**:

- Screen donors for compatibility
- Understand health profile
- Identify health risks
- Make informed decisions

**Data Available**:

- `medicalConditions`: List of conditions per donor
- `notes`: Health-related notes

---

### 3. Location Management

**Purpose**: Organize donors by geographic location

**Admin Can View**:

- Donors by district
- Donors by town/city
- Geographic distribution

**Location Fields**:

- District: State district (e.g., Ernakulam)
- Town: City/town name (e.g., Kochi)
- Pincode: Postal code for precision

**Use Cases**:

- Organize by service area
- Plan local coordination
- Identify coverage gaps
- Geographic analytics

**Data Retrieved**:

- Firestore queries filtered by district/town
- Location-based grouping

---

## Search & Filtering

### 1. Search by Blood Group

**Responsibility**: BloodDonorService.filterDonors(bloodGroup: ...)

**Purpose**: Find donors with specific blood types

**Search Parameters**:

- Blood group: Exact match (A+, B-, etc.)
- Availability: Only available donors
- Optional: District/town combination

**Use Cases**:

- Find O+ donors in Ernakulam district
- Locate AB- donors (rare blood type)
- Identify compatible donors
- Match donation requests

**Query Example**:

```dart
// Find available O+ donors in Ernakulam
filterDonors(
  bloodGroup: "O+",
  district: "Ernakulam",
  isAvailable: true,
)
```

---

### 2. Search by Location (District)

**Responsibility**: BloodDonorService.getDonorsByDistrict()

**Purpose**: Find all donors in a district

**Search Parameters**:

- District: State district name
- Availability: Filter for available donors only

**Use Cases**:

- Browse all donors in district
- Plan regional coordination
- Identify service coverage
- Geographic outreach

**Query Example**:

```dart
// Get all available donors in Kottayam
getDonorsByDistrict("Kottayam")
```

---

### 3. Search by Town/City

**Responsibility**: BloodDonorService.getDonorsByTown()

**Purpose**: Find donors in specific town

**Search Parameters**:

- District: State district
- Town: City/town name
- Availability: Available donors only

**Use Cases**:

- Narrow to specific city
- Local coordination
- Community blood sharing
- Emergency local response

**Query Example**:

```dart
// Get all available donors in Thiruvananthapuram city
getDonorsByTown(
  district: "Thiruvananthapuram",
  town: "Thiruvananthapuram",
)
```

---

### 4. Advanced Multi-Criteria Search

**Responsibility**: BloodDonorService.filterDonors()

**Purpose**: Complex donor search with multiple filters

**Available Filters**:

- **Blood Group**: A+, A-, B+, B-, O+, O-, AB+, AB-
- **Gender**: Male, Female, Other
- **Age Range**: Minimum and maximum age
- **Location**: District and/or town
- **Availability**: Available donors only
- **Health Status**: Filter by medical conditions (optional)

**Query Example**:

```dart
// Find male O+ donors in Kochi aged 18-40
filterDonors(
  bloodGroup: "O+",
  gender: "Male",
  minAge: 18,
  maxAge: 40,
  district: "Ernakulam",
  town: "Kochi",
  isAvailable: true,
)
```

**Use Cases**:

- Complex donor matching
- Specific demographic search
- Health-aware matching
- Priority donor identification

---

## Donor Monitoring & Analytics

### 1. Donor Registration Analytics

**Purpose**: Track donor growth and engagement

**Metrics to Monitor**:

- **Total Donors**: Complete count of registered donors
- **New Donors This Month**: Registration trend
- **Available Donors**: Currently available for donation
- **Unavailable Donors**: Temporarily suspended
- **Donor Growth Trend**: Rate of new registrations
- **District-wise Distribution**: Donors per district

**Data Source**:

- `createdAt`: Registration timestamp
- `isAvailable`: Current availability status
- `district`: Geographic distribution

**Use Cases**:

- Monitor community growth
- Identify recruitment needs
- Plan donor retention
- Capacity planning

---

### 2. Blood Group Distribution

**Purpose**: Understand blood group availability

**Metrics to Track**:

- **Count per Blood Group**: A+, A-, B+, B-, O+, O-, AB+, AB-
- **Rare Types**: AB- and other rare blood groups
- **Common Types**: O+ and A+
- **Availability by Blood Group**: Count of available donors per type

**Data Available**:

- `bloodGroup` field from each donor
- Firestore aggregation queries

**Use Cases**:

- Identify donor diversity
- Locate rare blood type donors
- Plan emergency responses
- Match donor-patient requests

---

### 3. Availability Status Monitoring

**Purpose**: Track donor availability

**Metrics**:

- **Available Donors**: Count with isAvailable = true
- **Unavailable Donors**: Count with isAvailable = false
- **Availability Rate**: Percentage of available donors
- **Recent Changes**: Track status changes over time

**Use Cases**:

- Quick resource assessment
- Emergency donor identification
- Plan outreach campaigns
- Identify inactive donors

---

### 4. Donor Activity Monitoring

**Purpose**: Track donor engagement

**Metrics to Monitor**:

- **Inactive Donors**: No login/activity for X days
- **Recently Active**: Recently logged in
- **Profile Completion**: How many donors have complete profiles
- **Medical Info**: Count with health conditions listed

**Use Cases**:

- Identify engagement levels
- Plan re-engagement campaigns
- Understand usage patterns
- Quality control

---

### 5. Location-wise Analytics

**Purpose**: Geographic distribution insights

**Metrics**:

- **Donors per District**: Count in each district
- **Top 3 Districts**: Most donors concentrated
- **Underserved Areas**: Districts with low donor count
- **Coverage Analysis**: Geographic reach assessment

**Data Source**:

- `district` and `town` fields
- Firestore grouping queries

**Use Cases**:

- Plan expansion strategy
- Identify coverage gaps
- Regional resource allocation
- Community planning

---

## Admin Tasks & Workflows

### Workflow 1: Onboard New Donor

**Scenario**: User self-registers as donor via app

**Admin Steps**:

1. Check if new donor registration successful
2. View new donor profile in dashboard
3. Verify information accuracy
4. Confirm medical conditions listed
5. Mark as verified (optional field)
6. Monitor first activity

---

### Workflow 2: Search for Compatible Donor

**Scenario**: Emergency blood donation needed (O+ required)

**Admin Steps**:

1. Open Donor Search
2. Filter by blood group: "O+"
3. Filter by district: Patient's district
4. Sort by availability
5. Review available donors list
6. Select compatible donor
7. Contact donor via phone (number visible to admin)

---

### Workflow 3: Handle Inactive Donor

**Scenario**: Donor not active for 3+ months

**Admin Steps**:

1. Identify inactive donors (from analytics)
2. View donor profile
3. Check last activity date
4. Consider options:
   - Send re-engagement notification
   - Verify if still interested
   - Mark as inactive in notes

---

### Workflow 4: Suspend Problem Donor

**Scenario**: Donor violates community guidelines

**Admin Steps**:

1. Locate donor in list
2. Review their profile
3. View any reports/notes
4. Suspend account with reason
5. Document incident in notes
6. Remove from active searches

---

### Workflow 5: Verify Donor Information

**Scenario**: Verify donor details after registration

**Admin Steps**:

1. View new donor profile
2. Check all fields:
   - Name, age, blood group
   - Medical conditions
   - Address completeness
   - Contact information
3. Edit if errors found
4. Mark as verified

---

### Workflow 6: Generate Donor Statistics Report

**Scenario**: Periodic reporting on donor community

**Admin Steps**:

1. Open Analytics Dashboard
2. View key metrics:
   - Total donor count
   - Blood group distribution
   - Geographic spread
   - Availability rate
3. Identify trends
4. Plan next actions

---

## Admin Dashboard Components

### Recommended Dashboard Sections

1. **Donor Overview Card**

   - Total registered donors
   - Available donors count
   - Suspended donors count
   - New donors this month
   - Quick stat cards

2. **Donor Search & Filter**

   - Search by name/phone
   - Filter by blood group
   - Filter by district/town
   - Filter by age range
   - Filter by gender
   - Apply/Reset buttons
   - Results count

3. **Donor List Table**

   - Sortable columns: Name, Blood Group, District, Status
   - Action buttons: View, Edit, Suspend, Delete
   - Quick info display
   - Pagination

4. **Individual Donor Details View**

   - Full profile information
   - All contact details
   - Health information
   - Availability toggle
   - Edit button
   - Suspend/Delete buttons
   - Audit trail of changes

5. **Analytics Dashboard**

   - Total donors chart (line graph)
   - Blood group distribution (pie chart)
   - Geographic distribution (bar chart)
   - Availability status (donut chart)
   - New registrations this month
   - Inactive donors count

6. **Donor Management Tools**
   - Bulk status update (suspend)
   - Bulk delete (with confirmation)
   - Export donor list (CSV)
   - Import contacts (if needed)
   - Backup operations

---

## Firestore Schema for Admin

### Donors Collection (`donors`)

**Admin-Required Fields** (for management):

```
donors/{uid}
├── Core Fields (Existing)
│   ├── name: string              // Display name
│   ├── age: integer              // Age (calculated)
│   ├── gender: string            // Male/Female/Other
│   ├── bloodGroup: string        // A+, A-, etc.
│   ├── phone: string             // Contact
│   ├── email: string             // Email
│   ├── district: string          // For filtering
│   ├── town: string              // For filtering
│   ├── pincode: string           // Location detail
│   ├── medicalConditions: array  // Health info
│   ├── notes: string             // Health notes
│   ├── isAvailable: boolean      // Availability
│   ├── profileImageUrl: string   // Image URL
│   ├── createdAt: timestamp      // Registration date
│   └── updatedAt: timestamp      // Last update
│
└── Admin Fields (For Management)
    ├── isVerified: boolean       // Admin verification
    ├── verifiedBy: string        // Admin UID
    ├── suspendedAt: timestamp    // Suspension time
    ├── suspendedBy: string       // Admin UID
    ├── suspensionReason: string  // Why suspended
    ├── adminNotes: string        // Internal notes
    ├── lastActivityAt: timestamp // Last login
    └── profileCompleteness: integer  // % complete
```

---

## Access Control

### Admin Role Capabilities

**Admin Can**:

- ✅ View all donor profiles
- ✅ Search and filter donors
- ✅ Edit donor information
- ✅ Suspend/unsuspend donors
- ✅ Delete donor accounts (with confirmation)
- ✅ View analytics and reports
- ✅ Monitor availability
- ✅ Add internal notes
- ✅ Export donor data

**Admin Cannot**:

- ❌ Access user authentication system
- ❌ Modify blood group without verification
- ❌ Force change phone number
- ❌ Access admin-only settings
- ❌ Change other admin roles

---

## Simple Security Guidelines

1. **Admin-Only Access**: Restrict admin dashboard to admin role only
2. **Activity Logging**: Log all admin actions (view, edit, delete)
3. **Approval Required**: Confirmation dialog before delete/suspend
4. **Data Privacy**: Show phone numbers only to authenticated admins
5. **Audit Trail**: Keep record of who modified what and when
6. **Read-Only First**: Implement view-only access before edit access

---

## Configuration & Setup

### Enable Firestore Composite Indexes

For optimal admin queries, ensure these indexes exist:

1. **(district, bloodGroup, isAvailable)**

   - For "Find O+ donors in Ernakulam"

2. **(district, town, isAvailable)**

   - For "Find donors in specific city"

3. **(isAvailable, createdAt DESC)**

   - For "recently registered available donors"

4. **(bloodGroup, isAvailable)**
   - For "Find all O+ donors"

---

## Summary

This admin dashboard provides essential donor management:

- ✅ **View Registered Donors**: Complete visibility of all donors
- ✅ **Search & Filter**: Find donors by blood group, location, age
- ✅ **Account Management**: Suspend, delete, or edit donor profiles
- ✅ **Monitor Analytics**: Track growth, distribution, availability
- ✅ **Manage Availability**: Control donor visibility in search
- ✅ **Document Actions**: Maintain audit trail of admin work
- ✅ **Emergency Response**: Quickly locate compatible donors

**What's NOT Included** (too complex for academic project):

- ❌ Donor reputation/rating system
- ❌ Donation tracking/history
- ❌ Complex compliance workflows
- ❌ Mass automated messaging
- ❌ Advanced fraud detection
- ❌ IP blocking/rate limiting
- ❌ Device management

This keeps admin functionality practical and implementable for an in-app admin dashboard suitable for a small academic project.
