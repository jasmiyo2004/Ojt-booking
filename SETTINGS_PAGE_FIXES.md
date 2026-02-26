# Settings Page UI Redesign

## Overview

The settings page has been completely redesigned to match the consistent UI style used across the application (home page, booking page, etc.).

## UI Design Pattern

### Yellow Header Section
- Background: `Color(0xFFFFEB3B)` (bright yellow)
- Contains company branding with logo
- Company name: "Gothong Southern" in green (`Color(0xFF1B5E20)`)
- Tagline: "Transport & Logistics"
- Consistent with home page and other pages

### White Content Area
- Background: White
- Rounded top corners (32px radius)
- Elevated above yellow header
- Contains all settings content

### Content Sections

#### 1. Profile Section
- **Profile Card**: Green gradient background (`Color(0xFF1B5E20)` to `Color(0xFF2E7D32)`)
- User avatar with initials in white circle
- User full name displayed prominently
- User type badge (yellow background)
- Status badge (green for active, red for inactive)
- Clickable to view full profile
- Shadow effect for depth

#### 2. Management Section
- **User Management Card**: White background with subtle shadow
- Yellow icon background (`Color(0xFFFFEB3B)` with opacity)
- Green icon (`Color(0xFF1B5E20)`)
- Title: "User Management"
- Description: "Manage users and permissions"
- Navigates to UserManagementPage

#### 3. Session Section
- **Logout Card**: Red tinted background (`Colors.red[50]`)
- Red icon background (`Colors.red[100]`)
- Red icon and text
- Title: "Logout"
- Description: "Sign out of your account"
- Shows confirmation dialog on tap

### Section Titles
- Icon in yellow background circle
- Bold text in dark gray
- Consistent spacing and alignment

### Version Info
- Centered at bottom
- Light gray text
- Shows app name and version number

## Color Scheme

- Primary Yellow: `Color(0xFFFFEB3B)`
- Primary Green: `Color(0xFF1B5E20)`
- Secondary Green: `Color(0xFF2E7D32)`
- Text Dark: `Color(0xFF212121)`
- Text Light: `Colors.grey[500]`
- Background: `Color(0xFFF5F5F5)`
- Card Background: `Colors.white`

## Functionality

### Profile Card
- Displays logged-in user information
- Shows user initials, name, type, and status
- Clickable to open view profile dialog
- View profile dialog shows complete user details
- Edit profile button in view dialog

### User Management Card
- Navigates to user management page
- Shows user masterlist
- Allows creating, editing, viewing, and managing users

### Logout Card
- Shows confirmation dialog
- TODO: Implement actual logout logic (clear session, redirect to login)

## Changes from Previous Design

### Before
- Gold/brown header (`Color(0xFFD4AF37)`)
- Flat white background
- Simple bordered cards
- Inconsistent with other pages

### After
- Bright yellow header (`Color(0xFFFFEB3B)`)
- Rounded white content area
- Modern gradient and shadow effects
- Matches home page and booking page design
- Better visual hierarchy
- More engaging and professional appearance

## Files Modified

- `ojt_booking_web/lib/views/settings_page.dart` - Complete UI redesign
- `ojt_booking_web/lib/models/user_model.dart` - Added helper properties (unchanged)

## Testing

1. Navigate to Settings tab
2. Verify yellow header matches home page
3. Check profile card displays user data correctly
4. Click profile card to view profile dialog
5. Click edit profile to update information
6. Click user management to navigate to user list
7. Click logout to see confirmation dialog

## Notes

- Loading state shows spinner with "Loading settings..." message
- All cards have hover effects (InkWell)
- Consistent spacing and padding throughout
- Responsive to different screen sizes
- Matches the modern, clean design of other pages
