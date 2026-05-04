# Task Manager App – Flutter & Back4App (BaaS)

A fully functional, modern Flutter application demonstrating CRUD operations and user authentication utilizing Back4App (Parse Server) as a Backend-as-a-Service (BaaS). 

## Recordings:
* Recording 1: Registration & Login + CRUD Operations
    Link: https://youtu.be/hxXE85SxR1k
* Recording 2: Login + CRUD Operation
    Link: https://youtu.be/6bRhI1d5G_A


## Features

###  Authentication & Profile
*   **Secure Registration & Login:** Email and password authentication enforced by Back4App.
*   **Custom Usernames:** Users can register with a custom username displayed across the app.
*   **Form Validation:** Includes confirm-password matching and required-field checks.
*   **Profile Dashboard:** A dedicated profile screen displaying the user's avatar, custom username, registered email, and total task count.
*   **Secure Logout:** Crash-proof logout flow with a destructive confirmation dialog that safely clears the navigation stack.

### Task Management (CRUD)
*   **Create:** Add new tasks via a sleek, keyboard-responsive bottom sheet.
*   **Read:** Fetch tasks dynamically from the cloud, displaying the newest tasks first. Data is strictly isolated to the logged-in user via Parse Pointers.
*   **Update:** Edit existing task titles and descriptions using the bottom sheet.
*   **Delete:** Intuitive swipe-to-delete gesture on task cards with visual red-background feedback and snackbar confirmation.

### UI/UX Enhancements
*   **Modern Aesthetics:** Edge-to-edge deep purple gradient backgrounds.
*   **Material Design:** Rounded input fields with inner padding and floating hint text.
*   **Custom Theming:** Green gradient save buttons and custom application bar headers greeting the user by name.

## Tech Stack
*   **Frontend:** Flutter (Dart)
*   **Backend/Database:** Back4App (Parse Server Cloud Database)
*   **SDK Dependency:** `parse_server_sdk_flutter: ^8.0.0`

---

## 📋 Prerequisites

Before you begin, ensure you have the following installed and set up:
1.  **Flutter SDK:** Installed and configured on your machine. (Run `flutter doctor` in your terminal to verify).
2.  **Code Editor:** Visual Studio Code, Android Studio, or IntelliJ.
3.  **Back4App Account:** A free account created at [back4app.com](https://www.back4app.com/).

---

## Setup & Installation Instructions

### Step 1: Clone the Repository
Clone this repository to your local machine and navigate into the project directory:
```bash
git clone [https://github.com/sharanraj6/flutter-task-manager-baas.git](https://github.com/sharanraj6/flutter-task-manager-baas.git)
cd flutter-task-manager-baas
```

## ⚙️ Setup Instructions
1. Clone the repository.
2. Run `flutter pub get` to install dependencies.
3. In `main.dart`, replace `YOUR_APPLICATION_ID` and `YOUR_CLIENT_KEY` with your project keys from the Back4App dashboard.
4. Run the app using an emulator or local device: `flutter run`.

## Screenshots:
### Login Screen:
<img width="500" height="500" alt="Screenshot 2026-05-02 at 20 13 49" src="https://github.com/user-attachments/assets/1fdc6df6-93e7-4814-bb25-51b52682f270" />

### My Tasks & Task Creation Screens:
<p>
<img width="200" height="400" alt="Simulator Screenshot - iPhone 17 - 2026-05-02 at 20 16 20" src="https://github.com/user-attachments/assets/60e8097d-0ae9-46a2-ab23-648399a4144d" /> <img width="200" height="400" alt="Simulator Screenshot - iPhone 17 - 2026-05-02 at 20 16 24" src="https://github.com/user-attachments/assets/efbc86a3-e7c6-4319-ac48-f5ae6d624f08" />
</p>

### Profile Screen:
<img width="200" height="400" alt="Simulator Screenshot - iPhone 17 - 2026-05-02 at 20 16 27" src="https://github.com/user-attachments/assets/b2c8a2f9-f84a-4596-9eca-840943586c77" />



