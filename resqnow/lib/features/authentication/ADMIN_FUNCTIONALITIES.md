# Authentication Module - Admin Functionalities Reference

## Overview

This document outlines the **Admin Dashboard capabilities** for the Authentication module in ResQnow. Since this is an academic project with a small user base (max ~10 users), the admin features focus on **practical, essential operations** rather than complex enterprise-level functionality.

**Supported Authentication**: Email and Password authentication only

---

## Table of Contents

1. [User Account Management](#user-account-management)
2. [Authentication Management](#authentication-management)
3. [Role & Permission Control](#role--permission-control)
4. [Basic Security](#basic-security)
5. [Analytics & Monitoring](#analytics--monitoring)
6. [Admin Tasks & Workflows](#admin-tasks--workflows)

---

## 1. User Account Management

### 1.1 User Search & Lookup

**Responsibility**: AuthService (auth_service.dart)

**Admin Actions**:

- Search users by UID (User ID)
- Search users by email address
- View list of all registered users
- Filter users by role or account status

**Use Cases**:

- Find a specific user's account
- Verify user registration
- Check duplicate accounts
- Look up user information for support

**Permissions Required**:

- Read access to `users` collection in Firestore

---

### 1.2 View User Profile

**Responsibility**: Firestore user document

**Admin Can View**:

- User's name
- Email address
- Account creation date
- Last login timestamp
- Assigned role
- Account status (active/suspended)

**Use Cases**:

- Verify user account details
- Check account creation date
- See user's role assignments

**Permissions Required**:

- Read access to user documents

---

### 1.3 Suspend/Deactivate User Account

**Responsibility**: AuthService + Firestore

**Admin Actions**:

- **Suspend Account**: Temporarily disable login
- **Reactivate Account**: Re-enable a suspended account
- **Add Suspension Reason**: Document why account was suspended

**Data Fields**:

- `accountStatus`: active | suspended
- `suspendedAt`: When suspended
- `suspendedBy`: Admin UID who suspended
- `suspensionReason`: Simple text reason

**Use Cases**:

- User violates app rules
- Suspicious activity detected
- User requests temporary deactivation
- Cleanup of test accounts

**Permissions Required**:

- Update access to user `accountStatus` field
- Audit logging of suspension actions

---

### 1.4 Delete User Account

**Responsibility**: Firebase Auth + Firestore cleanup

**Admin Actions**:

- Delete user from Firebase Auth
- Delete user document from Firestore
- Remove user data from related collections

**Use Cases**:

- User requests account deletion
- Remove fraudulent/spam account
- Cleanup test accounts
- GDPR user deletion requests

**Permissions Required**:

- Delete access to Firebase Auth
- Delete access to Firestore user documents
- Confirmation required to prevent accidental deletion

---

### 1.5 Edit User Profile (Basic)

**Responsibility**: Firestore user document

**Admin Can Edit**:

- Display name
- Email address (with re-verification)
- Account metadata/notes

**Use Cases**:

- Correct user information errors
- Update name based on user request
- Add internal notes about user

**Permissions Required**:

- Update access to specific user fields
- Change audit trail for modifications

---

## 2. Authentication Management

### 2.1 Email & Password Management

**Responsibility**: AuthService.sendPasswordResetEmail()

**Admin Actions**:

- Trigger password reset email for user
- Verify email verification status
- View user's email address

**Use Cases**:

- User forgot password
- User locked out of account
- Support assisting with account recovery
- Security incident - force password reset

**Permissions Required**:

- Ability to send password reset emails
- View email verification status

---

## 3. Role & Permission Control

### 3.1 User Role Assignment

**Responsibility**: AuthService (Firestore `role` field), AuthController

**Available Roles**:

- `user`: Standard registered user
- `admin`: Full platform access and admin capabilities
- `support`: Support staff for user assistance
- `moderator`: Can moderate user content (if needed)

**Admin Actions**:

- Assign role to user
- Change user's role
- Remove role from user

**Data Fields**:

- `role`: User's current role
- `roleAssignedAt`: When role was assigned
- `roleAssignedBy`: Admin UID who assigned role

**Use Cases**:

- Promote user to admin
- Assign support staff role
- Revoke admin access from compromised account
- Change user role after contract end

**Permissions Required**:

- Update access to user `role` field
- Only super-admin can assign/change admin roles
- Audit trail for role changes

---

### 3.2 Feature Access Control

**Responsibility**: AuthController + Role-based checks

**Admin Actions**:

- Enable/disable features for specific roles
- Grant temporary feature access
- Block features for specific users

**Permission Categories**:

- Authentication: Login, signup, password reset
- User Profile: View/edit own profile, delete account
- Admin Features: User management, view analytics
- Support Features: View user info, assist with account

**Use Cases**:

- New user role needs feature access
- Disable problematic feature temporarily
- Give support staff limited user access
- Feature rollout to specific users

**Permissions Required**:

- Feature flag management
- Per-user feature toggle capability

---

## 4. Basic Security

### 4.1 Account Security Monitoring

**Responsibility**: AuthService + Firestore logging

**Admin Can Monitor**:

- Last login timestamp for each user
- Last login IP address
- Failed login attempts (counter)
- Suspicious login activity flag

**Data Fields**:

- `lastLoginAt`: Last successful login time
- `lastLoginIP`: IP of last login
- `failedLoginCount`: Number of recent failed attempts
- `suspiciousActivityFlag`: Boolean if flagged

**Use Cases**:

- Identify inactive accounts
- Detect unusual login patterns
- Check for account takeover attempts
- Monitor authentication issues

**Permissions Required**:

- Read access to login history
- Ability to flag suspicious accounts

---

### 4.2 Account Recovery Assistance

**Responsibility**: AuthService.sendPasswordResetEmail()

**Admin Actions**:

- Send password reset email to user
- Verify user identity before account actions
- Document account recovery attempts

**Use Cases**:

- User forgot password
- User lost account access
- Admin-assisted account recovery
- User locked out due to failed attempts

**Permissions Required**:

- Send password reset emails
- Identity verification workflow access

---

## 5. Analytics & Monitoring

### 5.1 User Growth Analytics

**Responsibility**: Firestore queries on user collection

**Metrics to Track**:

- **Total registered users**: Count of all users
- **New users this month**: Users created in current month
- **Active users**: Users who logged in recently
- **User growth trend**: How many users added over time
- **Account status breakdown**: Active vs. suspended accounts

**Data Available**:

- `createdAt`: User creation timestamp
- `lastLoginAt`: Last login timestamp
- `role`: User's role
- `accountStatus`: Current status

**Use Cases**:

- Monitor app adoption
- Track user growth trends
- Identify inactive users
- Capacity planning

**Permissions Required**:

- Read access to user timestamps
- Dashboard/reporting access

---

### 5.2 Login Activity Analytics

**Responsibility**: Firestore login logs

**Metrics to Track**:

- **Daily active users**: How many users logged in today/this week
- **Peak login times**: When most users log in
- **Login success rate**: Percentage of successful logins
- **Authentication failures**: Number of failed login attempts
- **User engagement**: Average logins per user per week

**Data Available**:

- Login timestamps
- Success/failure status
- User UID
- IP address (optional)

**Use Cases**:

- Identify peak usage times
- Detect authentication issues
- Monitor user engagement
- Troubleshoot login problems
- Performance planning

**Permissions Required**:

- Read access to login events
- Aggregation/reporting capability

---

### 5.3 Account Status Overview

**Responsibility**: Firestore user collection

**Dashboard Metrics**:

- **Active accounts**: Users with status "active"
- **Suspended accounts**: Users with status "suspended"
- **Role distribution**: Breakdown of users by role
- **Inactive users**: No login in X days

**Use Cases**:

- Get system health snapshot
- Identify accounts needing attention
- Monitor role assignments
- Track account lifecycle

**Permissions Required**:

- Read access to user documents

---

## 6. Admin Tasks & Workflows

### 6.1 New User Onboarding (Admin Support)

**Scenario**: New user signs up and needs to be set up

**Admin Steps**:

1. Verify user successfully created account
2. Confirm email in user record
3. Assign appropriate role (if not 'user')
4. Add admin notes if needed
5. Monitor first login

---

### 6.2 User Account Support

**Scenario**: User reports account access issue

**Admin Steps**:

1. Search and find user account
2. Verify user identity (ask security questions)
3. Check last login and account status
4. Trigger password reset email
5. Monitor account for next login
6. Document issue in admin notes

---

### 6.3 Account Suspension for Rule Violation

**Scenario**: User violates app terms of service

**Admin Steps**:

1. Search user account
2. Review user activity/reports
3. Suspend account with reason
4. Document violation in admin notes
5. Notify user (via separate notification system)
6. Monitor if user appeals

---

### 6.4 Account Cleanup (Test/Spam)

**Scenario**: Remove test or spam accounts

**Admin Steps**:

1. Identify test/spam accounts
2. Verify they should be deleted
3. Delete accounts
4. Log deletion with reason
5. Verify complete removal

---

### 6.5 Role Assignment/Update

**Scenario**: Promote user to support staff or admin

**Admin Steps**:

1. Find user account
2. Verify user eligibility (account age, trust level)
3. Change user role
4. Document role change with reason
5. Notify user of new permissions
6. Monitor user actions in new role

---

### 6.6 Suspicious Activity Investigation

**Scenario**: Admin notices suspicious login activity

**Admin Steps**:

1. Find the user account
2. Check login history and IP addresses
3. Review account status and changes
4. Flag account if needed
5. Contact user to verify if legitimate
6. Suspend if confirmed compromise

---

## Admin Dashboard Components

### Recommended Dashboard Sections

1. **User Management**

   - User search/filter
   - View all users list
   - Quick status: Active/Suspended counts
   - Bulk actions: Select multiple users

2. **User Details View**

   - Profile information
   - Account status and history
   - Login activity
   - Role assignment
   - Admin notes
   - Actions: Suspend, Delete, Reset Password, Change Role

3. **Analytics Dashboard**

   - Total users count
   - New users this month
   - Daily active users
   - Login success rate
   - Role distribution chart
   - User growth trend chart

4. **Quick Actions**

   - Send password reset
   - Suspend account
   - View recent logins
   - Add admin note
   - Change user role

5. **Activity Log**

   - Recent role changes
   - Account suspensions
   - Password resets initiated
   - Admin actions with timestamp
   - Who performed each action

6. **Alerts**
   - Suspicious login attempts
   - Multiple failed logins from same IP
   - Accounts not logged in for X days
   - Flagged accounts

---

## Firestore Schema for Admin Functions

### Users Collection (`users`)

**Core Fields** (Already Implemented):

- `uid`: User ID
- `email`: Email address
- `name`: Display name
- `role`: Role (user | admin | support | moderator)
- `createdAt`: Account creation timestamp

**Admin-Required Fields** (To be Added):

- `accountStatus`: active | suspended
- `suspendedAt`: Suspension timestamp (if suspended)
- `suspendedBy`: Admin UID who suspended
- `suspensionReason`: Text reason for suspension
- `lastLoginAt`: Last successful login timestamp
- `lastLoginIP`: IP address of last login
- `failedLoginCount`: Counter for failed attempts
- `suspiciousActivityFlag`: Boolean if flagged
- `adminNotes`: Text notes added by admin
- `roleAssignedAt`: When current role was assigned
- `roleAssignedBy`: Admin UID who assigned role

### Authentication Logs Collection (New)

Track important auth events:

- `uid`: User ID
- `eventType`: signup | login | password_reset | role_change | suspend
- `timestamp`: Event time
- `status`: success | failed
- `performedBy`: Admin UID (if admin-initiated)
- `sourceIP`: IP address

---

## Access Control for Admin Functions

**Super Admin** (only you initially):

- All admin functions
- Assign/remove other admins
- Delete users
- Suspend/unsuspend accounts
- View all analytics

**Admin** (promoted users):

- User management (suspend, delete, reset password)
- View all user information
- Change user roles (except admin role)
- View analytics
- Add admin notes

**Support Staff**:

- View user information
- Send password reset emails
- Add notes to user accounts
- View basic analytics
- Cannot delete or suspend

**Moderator** (if needed):

- View user information
- Flag suspicious accounts
- Cannot delete or suspend
- Limited to analytics view

---

## Simple Security Guidelines

1. **Audit Logging**: Log all admin actions (who, what, when)
2. **Admin-Only Access**: Restrict admin dashboard to admin users only
3. **Password Reset**: Always verify user identity before resetting password
4. **Account Suspension**: Document reason and keep history
5. **Data Access**: Only admins can view user data
6. **Role Changes**: Log all role assignments with admin name and timestamp

---

## Summary

This simplified admin dashboard focuses on:

- ✅ Managing user accounts (view, suspend, delete)
- ✅ Resetting passwords and account recovery
- ✅ Assigning and managing user roles
- ✅ Basic security monitoring (suspicious activity, failed logins)
- ✅ User analytics (growth, engagement, activity)
- ✅ Common admin workflows (onboarding, support, cleanup)

What's NOT included (too complex for this project):

- ❌ Complex fraud detection systems
- ❌ IP blocking and rate limiting
- ❌ Geographic location tracking
- ❌ Device management
- ❌ Multi-factor authentication management
- ❌ Complex compliance workflows (GDPR)
- ❌ Mass action workflows
- ❌ Incident response procedures

This keeps the admin functionality practical and implementable for an in-app admin dashboard suitable for a small academic project.
