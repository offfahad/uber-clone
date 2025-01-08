# Ride-Sharing Application

This repository contains a ride-sharing platform similar to Uber, developed with Flutter and Firebase. It consists of three applications:

1. **User App** – For customers to book rides.
2. **Driver App** – For drivers to accept ride requests and manage trips.
3. **Admin Panel** – For managing platform operations and monitoring activities.

## Note
- The project is missing some state management features, which can be added as a contribution.

4. ## Features

### **User App**
- Book rides with multiple options: car, bike, or rickshaw.
- Add custom bids for rides and notify nearby drivers.
- Track rides in real-time with Google Maps integration.
- Authentication with Firebase and Google Sign-In.
- Option for users to become drivers by submitting required documents for verification:
  - CNIC (National Identity Card)  
  - Vehicle pictures and details  
  - Vehicle registration license  
  - Driving license
- Payment integration using Flutter Stripe.

### **Driver App**
- Receive ride requests with real-time notifications.
- Accept or decline ride offers based on user bids.
- Start and end trips with live location tracking.
- Driver authentication with Firebase, ensuring only verified drivers can accept rides.
  
### **Admin Panel**
- Manage users, drivers, and ride details.
- Monitor system activity and handle operational issues.
- Verify and approve driver applications by reviewing submitted documents.

- ## Technologies Used

- **Frontend Framework:** Flutter
- **Backend & Database:** Firebase (Firestore, Realtime Database, Firebase Auth, Firebase Storage)
- **State Management:** Provider
- **Mapping & Location Services:**  
  - Google Maps API (`google_maps_flutter`)  
  - Geolocator  
  - Flutter Geofire  
  - Polyline generation with `flutter_polyline_points`
- **Networking & Utilities:**  
  - HTTP requests (`http`)  
  - URL launcher (`url_launcher`)  
  - Permissions management (`permission_handler`)  
  - Restarting apps (`restart_app`)
- **Authentication:**  
  - Firebase Authentication  
  - Google Sign-In (`google_sign_in`)  
  - Document uploads for driver verification (CNIC, Vehicle Registration, Driving License, etc.)
- **Payment Gateway:** Flutter Stripe (`flutter_stripe`)
- **UI/UX Enhancements:**  
  - Loading animations (`loading_animation_widget`, `rounded_loading_button`)  
  - Shimmer effects for placeholders
- **Miscellaneous:**  
  - Country picker for region selection (`country_picker`)  
  - Connectivity check (`connectivity_plus`)

5. ## Future Enhancements
- Add state management in the project.
- Add in-app chat functionality between users and drivers.
- Support for multi-language localization.
- Advanced analytics dashboard for the admin panel.
  
6. ## Contributions
- Contributions are welcome! Please create a pull request with a detailed explanation of your changes.

7. ## Contact
- For any queries or suggestions, please reach out at mughalfahad544email@example.com.

