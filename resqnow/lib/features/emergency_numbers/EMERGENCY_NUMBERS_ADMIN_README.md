# Emergency Numbers Module - Admin Functionalities Reference

## Overview

This document outlines the **Admin Dashboard capabilities** for managing emergency contact numbers in the ResQnow Emergency Numbers Module. Emergency numbers are critical system-wide resources that help users quickly access emergency services (ambulance, police, fire, etc.). Since this is an academic project with a small user base, the admin features focus on **practical, essential operations** for managing emergency service numbers.

**Technology**: Firebase Firestore, Flutter

---

## Table of Contents

1. [Emergency Number Management](#emergency-number-management)
2. [Service Configuration](#service-configuration)
3. [Search & Display](#search--display)
4. [Admin Tasks & Workflows](#admin-tasks--workflows)
5. [Admin Dashboard Components](#admin-dashboard-components)
6. [Firestore Schema for Admin](#firestore-schema-for-admin)
7. [Access Control](#access-control)

---

## Emergency Number Management

### 1. View All Emergency Numbers

**Responsibility**: EmergencyNumberService.fetchEmergencyNumbers()

**Admin Actions**:

- Fetch complete list of emergency service numbers
- Display all available emergency contacts
- View service details and information
- Check number status and validity

**Data Visible**:

- Service name (e.g., "Ambulance", "Police")
- Phone number
- Service category/type
- Description
- Service availability/status
- Last updated timestamp

**Use Cases**:

- Get complete system overview
- Monitor emergency service configuration
- Verify all critical numbers are available
- Audit emergency contact system

**Permissions Required**:

- Read access to `emergency_numbers` collection

---

### 2. View Individual Emergency Number Details

**Responsibility**: Firestore document read

**Admin Can View**:

- Service name
- Full phone number
- Service category (Ambulance, Police, Fire, Disaster Management, etc.)
- Service description
- Area of coverage (if applicable)
- Operating hours (if not 24/7)
- Contact person/department (if available)
- Validity/expiration date (if applicable)
- Last modified timestamp
- Created timestamp

**Use Cases**:

- Review specific service details
- Verify number is still correct
- Check service availability
- Audit service information accuracy

**Permissions Required**:

- Read access to individual emergency number documents

---

### 3. Add New Emergency Number

**Responsibility**: EmergencyNumberService.addEmergencyNumber()

**Admin Actions**:

- Create new emergency service entry
- Add phone number
- Assign service category
- Set service description
- Configure service details

**Data Added**:

- `serviceName`: Service name (e.g., "Ambulance")
- `phoneNumber`: Contact phone number
- `category`: Service type (ambulance/police/fire/disaster)
- `description`: Service details
- `areaOfCoverage`: Geographic area served
- `operatingHours`: Hours of operation
- `priority`: Display priority (1=highest)
- `isActive`: Service availability toggle
- `createdAt`: Timestamp

**Validation**:

- Service name: Non-empty, 3+ characters
- Phone number: Valid format, checked for duplicates
- Category: One of predefined types
- Description: Clear, helpful text

**Use Cases**:

- Add new ambulance service
- Register police hotline
- Add fire department contact
- Include disaster management number
- Add specialized medical services

**Permissions Required**:

- Create access to emergency_numbers collection
- Audit trail of creation

---

### 4. Edit Emergency Number Information

**Responsibility**: EmergencyNumberService.updateEmergencyNumber()

**Admin Can Edit**:

- Service name
- Phone number
- Category/service type
- Description
- Area of coverage
- Operating hours
- Priority order
- Active/inactive status

**Admin Cannot Edit** (Protected):

- Emergency number ID
- Creation timestamp
- Creator information

**Use Cases**:

- Correct phone number if changed
- Update service details
- Change service category
- Modify coverage area
- Update operating hours
- Change display priority

**Permissions Required**:

- Update access to emergency_numbers documents
- Audit trail for modifications

---

### 5. Delete Emergency Number

**Responsibility**: EmergencyNumberService.deleteEmergencyNumber()

**Admin Actions**:

- Permanently remove emergency number from system
- Delete all associated metadata

**Important Considerations**:

- **Hard Delete**: Number completely removed
- **Data Loss**: Cannot be recovered without backup
- **Recommendation**: Use active/inactive toggle instead

**Use Cases**:

- Remove obsolete or consolidated numbers
- Delete duplicate entries
- Clean up test/temporary entries
- Archive services no longer available

**Permissions Required**:

- Delete access to emergency_numbers documents
- Confirmation dialog required before deletion

---

### 6. Toggle Emergency Number Status

**Responsibility**: Firestore update of `isActive` field

**Admin Actions**:

- Activate emergency number (isActive = true)
- Deactivate emergency number (isActive = false)
- Verify status visibility in app

**Soft Deactivation Approach**:

- Deactivated numbers remain in database
- Can be reactivated anytime
- No data loss
- Safe alternative to deletion

**Use Cases**:

- Temporarily disable a service (under maintenance)
- Pause a number (holiday closure)
- Disable problematic entries
- Re-enable previously disabled services

**Permissions Required**:

- Update access to `isActive` field

---

## Service Configuration

### 1. Emergency Service Categories

**Purpose**: Organize emergency numbers by service type

**Predefined Categories**:

- **Ambulance**: Medical emergency transport
- **Police**: Law enforcement and security
- **Fire**: Fire department and rescue
- **Disaster Management**: Natural disasters and calamities
- **General Emergency**: Multi-service numbers
- **Specialized Medical**: Specific medical facilities

**Admin Responsibilities**:

- Assign correct category to each number
- Maintain consistent categorization
- Use predefined categories only
- Update categories if services change

**Display Logic**:

- Different icons per category
- Color-coded for quick identification
- Sorted by priority within category
- Category filtering in app

---

### 2. Priority & Display Order

**Purpose**: Control emergency number visibility priority

**Admin Can Set**:

- Priority value (1=highest, 10=lowest)
- Services displayed in priority order
- Top services show first in app

**Use Cases**:

- Place most used services first
- Prioritize local services
- Show specialized numbers based on location
- Customize order by frequency of use

**Data Field**: `priority` (integer, ascending)

**Example Order**:

```
Priority 1: "Ambulance (General)" - Most critical
Priority 2: "Police Emergency" - Critical
Priority 3: "Fire Department" - Critical
Priority 4: "Disaster Management" - Important
Priority 5: "Medical Hotline" - Useful
```

---

### 3. Service Availability Management

**Purpose**: Indicate whether service is currently active

**Admin Can Configure**:

- Mark service as active/inactive
- Set service availability status
- Indicate temporary closures
- Manage service lifecycle

**Status States**:

- **Active** (isActive = true): Service operational, shown to users
- **Inactive** (isActive = false): Service unavailable, hidden from users

**Use Cases**:

- Disable service during maintenance
- Hide consolidated services
- Mark services no longer available
- Manage phased service rollout

---

## Search & Display

### 1. Search by Service Name

**Purpose**: Find emergency numbers by service name

**Search Behavior**:

- Case-insensitive matching
- Partial name matching
- Real-time search as admin types
- Instant result filtering

**Query Example**:

```
Admin searches: "ambulance"
Results:
- "Ambulance (General)"
- "Ambulance (Private)"
- "Ambulance (Medical College)"
```

**Use Cases**:

- Find specific service quickly
- Verify service exists
- Check for duplicate names
- Locate number for editing

---

### 2. Filter by Service Category

**Purpose**: Group emergency numbers by type

**Available Filters**:

- Ambulance services
- Police services
- Fire services
- Disaster management
- Specialized medical
- General/multi-service

**Use Cases**:

- View all police numbers
- Check all ambulance services
- Verify disaster management contacts
- Identify category coverage

---

### 3. Filter by Status

**Purpose**: View active or inactive services

**Filter Options**:

- Active services only (currently available)
- Inactive services only (disabled)
- All services (regardless of status)

**Use Cases**:

- Monitor active emergency services
- Review inactive services
- Identify gaps in coverage
- Plan service activation/deactivation

---

## Admin Tasks & Workflows

### Workflow 1: Add New Emergency Service Number

**Scenario**: New ambulance service becomes available in region

**Admin Steps**:

1. Open "Add Emergency Number" form
2. Enter service name: "Ambulance (Central Hospital)"
3. Enter phone number: "+91-XXXXXXXXXX"
4. Select category: "Ambulance"
5. Enter description: "24/7 ambulance service from Central Hospital"
6. Set area of coverage: "Central District"
7. Set priority: 1 (high priority)
8. Mark as active (isActive = true)
9. Save to database
10. Verify number appears in app

**Data Created**:

```
emergency_numbers/{docId}
├── serviceName: "Ambulance (Central Hospital)"
├── phoneNumber: "+91-XXXXXXXXXX"
├── category: "ambulance"
├── description: "24/7 ambulance service from Central Hospital"
├── areaOfCoverage: "Central District"
├── priority: 1
├── isActive: true
├── createdAt: timestamp
└── updatedAt: timestamp
```

---

### Workflow 2: Update Emergency Number

**Scenario**: Service phone number changes

**Admin Steps**:

1. Locate service in admin dashboard
2. Open details view
3. Find phone number field
4. Update to new number
5. Verify format is correct
6. Save changes
7. Test call to verify working

**Timing**: Changes take effect immediately

---

### Workflow 3: Disable Problematic Service

**Scenario**: Service is currently unavailable due to issues

**Admin Steps**:

1. Find service in dashboard
2. Review current status
3. Toggle isActive from true to false
4. Save change
5. Service removed from user app
6. Monitor for resolution
7. Re-enable when service operational

**Recommendation**: Use deactivation instead of deletion

---

### Workflow 4: Organize Service Priority

**Scenario**: Reorganize emergency numbers by frequency of use

**Admin Steps**:

1. Review current priority order
2. Identify most-used services
3. Update priority values:
   - Frequently called → Priority 1-3
   - Sometimes called → Priority 4-6
   - Rarely called → Priority 7-10
4. Save all changes
5. Verify new order in app

**Use Cases**:

- Place most accessed services first
- Organize by local vs. regional
- Custom ordering by region

---

### Workflow 5: Verify Service Number Accuracy

**Scenario**: Periodic audit of emergency contact numbers

**Admin Steps**:

1. Fetch complete emergency numbers list
2. For each service:
   - Verify phone number format
   - Check service still exists
   - Confirm number still active
   - Review description accuracy
3. Update any changed numbers
4. Deactivate obsolete services
5. Add missing services if identified
6. Document audit completion

**Checklist**:

- [ ] All numbers in correct format
- [ ] All services still operational
- [ ] No duplicate entries
- [ ] Priority order still appropriate
- [ ] Descriptions accurate
- [ ] All active services working

---

## Admin Dashboard Components

### Recommended Dashboard Sections

1. **Emergency Numbers Overview Card**

   - Total emergency numbers
   - Active services count
   - Inactive services count
   - Recent additions/updates

2. **Emergency Numbers List Table**

   - Sortable columns: Service Name, Number, Category, Status
   - Action buttons: View, Edit, Call, Toggle Status, Delete
   - Search bar for quick lookup
   - Filter by category
   - Filter by status (active/inactive)

3. **Emergency Number Details View**

   - Full service information
   - Phone number display
   - Service category
   - Description
   - Area of coverage
   - Operating hours
   - Priority value
   - Status toggle (active/inactive)
   - Edit button
   - Delete button
   - Last modified info

4. **Add/Edit Emergency Number Form**

   - Service name input
   - Phone number input (with validation)
   - Category selector
   - Description text area
   - Area of coverage input
   - Operating hours input
   - Priority number input
   - Active/inactive toggle
   - Submit button
   - Cancel button

5. **Category Management View**

   - All categories with service counts
   - Filter by category
   - View services per category
   - Rearrange category order

6. **Service Testing Tools**
   - Quick call button (test number)
   - SMS capability (optional)
   - Contact verification

---

## Firestore Schema for Admin

### Emergency Numbers Collection (`emergency_numbers`)

**Collection Path**: `emergency_numbers/{docId}`

**Document Structure**:

```
emergency_numbers/
├── doc_1/
│   ├── id: "doc_1"
│   ├── serviceName: "Ambulance (General)"
│   ├── phoneNumber: "+91-9874563210"
│   ├── category: "ambulance"
│   ├── description: "24/7 general ambulance service"
│   ├── areaOfCoverage: "All Districts"
│   ├── operatingHours: "24/7"
│   ├── priority: 1
│   ├── isActive: true
│   ├── createdAt: Timestamp(2024-01-01)
│   └── updatedAt: Timestamp(2024-02-01)
│
├── doc_2/
│   ├── serviceName: "Police Emergency"
│   ├── phoneNumber: "+91-9876543210"
│   ├── category: "police"
│   ├── description: "Police emergency helpline"
│   ├── areaOfCoverage: "All Districts"
│   ├── operatingHours: "24/7"
│   ├── priority: 2
│   ├── isActive: true
│   ├── createdAt: Timestamp(2024-01-02)
│   └── updatedAt: Timestamp(2024-02-01)
│
├── doc_3/
│   ├── serviceName: "Fire Department"
│   ├── phoneNumber: "+91-9111111111"
│   ├── category: "fire"
│   ├── description: "Fire rescue and emergency"
│   ├── areaOfCoverage: "Central District"
│   ├── operatingHours: "24/7"
│   ├── priority: 3
│   ├── isActive: true
│   ├── createdAt: Timestamp(2024-01-03)
│   └── updatedAt: Timestamp(2024-02-01)
│
└── doc_N/
    └── ... (similar structure)
```

### Field Descriptions

**Core Fields**:

- `serviceName`: Display name of service (e.g., "Ambulance (General)")
- `phoneNumber`: Contact phone number (e.g., "+91-9874563210")
- `category`: Service type (ambulance/police/fire/disaster/specialized/general)
- `description`: Service details (24/7, location, specialization)
- `areaOfCoverage`: Geographic area served (e.g., "Central District")
- `operatingHours`: Hours of operation (e.g., "24/7" or "9 AM - 5 PM")
- `priority`: Display priority (ascending: 1=highest)
- `isActive`: Boolean - whether service is available to users
- `createdAt`: Creation timestamp (server-generated)
- `updatedAt`: Last modification timestamp (server-generated)

### Indexes Required

**Single Field Indexes**:

- `isActive`: For "active services only" queries
- `category`: For filtering by service type
- `priority`: For sorting by display order
- `createdAt`: For sorting by recency

**Composite Indexes**:

1. **(isActive, priority)**
   - For fetching active services in priority order (used by app)
2. **(category, isActive, priority)**
   - For filtered view by category
3. **(isActive, createdAt DESC)**
   - For recently added active services

---

## Access Control

### Admin Role Capabilities

**Admin Can**:

- ✅ View all emergency numbers
- ✅ Create new emergency numbers
- ✅ Edit emergency number information
- ✅ Toggle service status (active/inactive)
- ✅ Change display priority
- ✅ Delete emergency numbers (with confirmation)
- ✅ Search and filter services
- ✅ Test call emergency numbers
- ✅ View modification history

**Admin Cannot**:

- ❌ Modify system-level settings
- ❌ Change emergency number IDs
- ❌ Bypass emergency service restrictions
- ❌ Access user-level data
- ❌ Modify other admin roles

---

## Simple Security Guidelines

1. **Admin-Only Access**: Restrict admin dashboard to admin role only
2. **Status Enforcement**: Only active services shown in user app
3. **Activity Logging**: Log all admin actions with timestamp and admin ID
4. **Phone Number Validation**: Verify number format before saving
5. **Confirmation Required**: Delete operations need confirmation
6. **Priority Consistency**: Maintain proper ordering after updates
7. **Accuracy Verification**: Regular audits of number validity
8. **Data Backup**: Critical system - maintain regular backups

---

## Configuration & Setup

### Enable Firestore Indexes

Ensure these indexes exist for optimal performance:

1. **Index**: `isActive` + `priority` (ascending)

   - Used: App fetches active services in order
   - Purpose: Display services to users in priority sequence

2. **Index**: `category` + `isActive` + `priority`

   - Used: Filter by service type
   - Purpose: Category-specific emergency number display

3. **Index**: `isActive` + `createdAt` (descending)
   - Used: Admin view of recent additions
   - Purpose: Monitor latest emergency services

---

## Summary

This admin dashboard provides essential emergency number management:

- ✅ **View Services**: Complete visibility of all emergency numbers
- ✅ **Add Services**: Create new emergency service entries
- ✅ **Edit Information**: Update phone numbers and details
- ✅ **Manage Status**: Activate/deactivate services
- ✅ **Organize Priority**: Control display order
- ✅ **Search & Filter**: Find services by category or name
- ✅ **Safe Operations**: Deactivate instead of delete
- ✅ **Audit Trail**: Track all modifications

**What's NOT Included** (too complex for academic project):

- ❌ Complex emergency dispatch systems
- ❌ Automated emergency alerts/SMS
- ❌ Multi-region routing logic
- ❌ Emergency call recording
- ❌ Advanced analytics
- ❌ Integration with external emergency systems
- ❌ Complex permission hierarchies

This keeps admin functionality practical and implementable for an in-app admin dashboard suitable for a small academic project. Emergency numbers are critical resources that require clear, simple management.
