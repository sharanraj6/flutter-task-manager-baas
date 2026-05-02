# Task Manager App - Flutter & Back4App (BaaS)

A fully functional Flutter application demonstrating CRUD operations and user authentication utilizing Back4App (Parse Server) as a Backend-as-a-Service (BaaS).

## 🚀 Features
- **User Authentication:** Secure registration and login using student email IDs.
- **Task Management (CRUD):** 
  - **C**reate new tasks with titles and descriptions.
  - **R**ead and fetch personal tasks dynamically.
  - **U**pdate existing task details.
  - **D**elete completed or unwanted tasks.
- **BaaS Integration:** Built entirely without a custom backend using Back4App.
- **Data Isolation:** Tasks are securely tied to the currently logged-in user via Parse Pointers.
- **Secure Logout:** Safely invalidates the user session.

## 🛠 Tech Stack
- **Frontend:** Flutter (Dart)
- **Backend/Database:** Back4App (Parse Server Cloud Database)
- **SDK:** `parse_server_sdk_flutter`

## ⚙️ Setup Instructions
1. Clone the repository.
2. Run `flutter pub get` to install dependencies.
3. In `main.dart`, replace `YOUR_APPLICATION_ID` and `YOUR_CLIENT_KEY` with your project keys from the Back4App dashboard.
4. Run the app using an emulator or local device: `flutter run`.