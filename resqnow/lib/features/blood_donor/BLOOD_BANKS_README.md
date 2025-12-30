# Blood Donor Module - Blood Banks Reference

## Overview

This document clarifies the **Blood Banks feature** in the ResQnow Blood Donor Module.

**Important**: Blood Banks functionality uses **Google Places API** as an external service. Blood bank data is fetched directly from Google's database in real-time. This is an **integrated third-party service**, not app-managed data.

**Result**: **No admin functionalities are required** for Blood Banks management.

---

## Why No Admin Functions?

### Data Source

- Blood bank information comes from **Google Places API**
- Data is maintained by **Google**, not by ResQnow
- Banks are discovered via GPS location + search query
- Real-time updates handled by Google

### App Responsibility

- **Only integration point**: Fetch and display Google's data
- **No storage**: Blood banks are not stored in app database
- **No management**: Admins cannot add, edit, or delete blood banks
- **No moderation**: No content to moderate or review

### What This Means

- ❌ Admins cannot add blood banks to the system
- ❌ Admins cannot edit blood bank information
- ❌ Admins cannot delete blood banks
- ❌ Admins cannot manage bank operations
- ❌ No admin dashboard needed for blood banks

---

## Technical Summary

**Technology**: Google Places Text Search API + Google Maps

**Flow**:

```
User Location (GPS)
    ↓
BloodBankService (API Call)
    ↓
Google Places API Returns Results
    ↓
Display to User
    ↓
User Navigates/Calls (via native apps)
```

**Scope**: Read-only integration - no data management

---

## For Administrators

If you need to manage blood bank data (e.g., verify accuracy, add partnerships), you would need to:

1. Contact those blood banks directly
2. Request they update their Google Business Profile
3. Verify changes appear in Google Places API
4. Changes reflect automatically in the app

**The app is simply a mirror of Google's data.**

---

## Conclusion

Blood Banks is a **user-facing feature only**, powered by external data. No admin functionalities apply.

For admin functionalities in ResQnow, see [BLOOD_DONORS_README.md](BLOOD_DONORS_README.md) which documents admin management of registered blood donors.
