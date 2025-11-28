📱 Number Guessing Game – Flutter
Mobile App Development Assignment

Instructor: Sir Abrar
Student: Huzaifa Ihsan
Registration Number: FA22-BCS-057

📘 Overview

This project is a simple and interactive Number Guessing Game built using Flutter as part of the Mobile Application Development assignment.

The game randomly generates a number, and the user attempts to guess it. After submitting a guess, the app provides feedback such as Too Low, Too High, or Correct. The user can also review all previous attempts through a dedicated history screen.

🎯 Features

🎲 Random Number Generation for each game round

🔢 User Guess Input with instant feedback

📉 Displays whether the guess is Too Low, Too High, or Correct

🧾 History Screen for viewing all previous guesses

🔄 Try Again button to restart the game

🎨 Clean & responsive UI suitable for both mobile and web

🌐 Fully functional on Flutter Web (Chrome/Edge)

📂 Project Structure
lib/
│
├── main.dart
│
├── models/
│   └── game_result.dart
│
├── database/
│   └── (history storage logic if used)
│
├── screens/
│   ├── home_screen.dart
│   ├── result_screen.dart
│   └── history_screen.dart
│
└── widgets/
    └── (custom widgets if any)

🛠️ Technologies Used

Flutter (Dart)

Material UI Components

Flutter Web Renderer

VS Code / Android Studio

▶️ How to Run the Project

Follow these steps to run the game:

Install Flutter SDK

Clone/download the project

Open terminal in the project root folder

Run commands:

flutter pub get
flutter run -d chrome


The game will launch in your default browser.

📸 Screenshot
Game Result Screen (Flutter Web Output)

<img width="1920" height="1028" alt="image" src="https://github.com/user-attachments/assets/0c0a65ea-ee88-48ae-b91a-1c5b17938845" />
<img width="1918" height="1033" alt="image" src="https://github.com/user-attachments/assets/58e8b9a6-db5a-45e2-b394-b7673fbd12b6" />
<img width="1915" height="1027" alt="image" src="https://github.com/user-attachments/assets/fad1b75d-d687-4129-b21c-4d79769a5568" />
<img width="1920" height="1031" alt="image" src="https://github.com/user-attachments/assets/bc263363-c42b-47b4-8c87-d903765c4cb7" />


🧑‍🎓 Student Information

Name: Huzaifa Ihsan
Registration Number: FA22-BCS-057
Course: Mobile Application Development
Instructor: Sir Abrar

📝 Purpose of the Assignment

This project was developed to demonstrate understanding of:

Flutter widget hierarchy

Screen navigation and routing

Stateful widgets & state management

Input handling

Basic game logic

UI/UX design for mobile & web

📌 Future Enhancements

Add animations for correct/incorrect guesses

Add difficulty levels

Save history using local storage / database

Add sound effects

Add theme customization

✔️ Conclusion

The Number Guessing Game successfully demonstrates fundamental Flutter development concepts, including UI design, state management, and navigation. It fulfills the requirements of the Mobile App Development assignment under the guidance of Sir Abrar.
