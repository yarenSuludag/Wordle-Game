# A Wordle-Style Game in Flutter

A Flutter-based word game inspired by Wordle, integrated with Firebase for authentication and real-time data management. In this project, players can register, log in, and participate in game channels to challenge their word-guessing skills. The game provides visual feedback on each guess, calculates scores based on performance and time, and displays results in a competitive format.

---

## Table of Contents

- [Overview](#overview)
- [Introduction](#introduction)
- [System Architecture & Design](#system-architecture--design)
- [Methodology](#methodology)
  - [Database Design](#database-design)
  - [Multithreading & Concurrency](#multithreading--concurrency)
  - [Dynamic Priority Management](#dynamic-priority-management)
  - [Error Management & Logging](#error-management--logging)
  - [User Interface (UI) Integration](#user-interface-ui-integration)
  - [Software Architecture (MVC)](#software-architecture-mvc)
- [Experimental Results](#experimental-results)
- [Project Requirements](#project-requirements)
- [Documentation & References](#documentation--references)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

The **Word Game** project is a word-guessing game built with Flutter. It mimics the popular Wordle concept with a twist: players choose from different channels (based on fixed or variable letter settings) and compete in real time. The application uses Firebase for user authentication and Cloud Firestore to manage real-time data such as active user status, game requests, and match notifications.

Players are given a limited number of guesses and a countdown timer to determine the target word. The game evaluates each guess, providing color-coded feedback (green for correct letters in the right position, yellow for correct letters in the wrong position, and grey for incorrect letters). Scores are computed based on the number of correct and incorrect guesses, with a bonus for remaining time.

---

## Introduction

With the increasing prevalence of e-commerce platforms and interactive gaming experiences, handling real-time user interactions and providing immediate feedback has become critical. This project is developed to offer:
- Seamless user authentication and registration via Firebase.
- Dynamic channel selection based on fixed or variable letter game modes.
- Real-time gameplay with visual feedback and score calculations.
- A competitive environment where players can see detailed results and compare performances.

The app is implemented in Flutter using Dart and leverages Firebase services to manage data, user activity, and game state in real time.

---

## System Architecture & Design

The system is structured around a modular architecture that separates concerns into distinct layers. This design ensures scalability, maintainability, and ease of future enhancements.

- **Frontend/UI:**
  - Designed with a focus on user experience, offering separate panels for customers (players) and administrators.
  - Displays game channels, active user lists, game requests, and real-time notifications.
  
- **Backend:**
  - Developed in Flutter and integrated with Firebase services.
  - Implements Firebase Authentication for secure login and registration.
  - Uses Cloud Firestore to manage game data, user status, and real-time updates.

- **Database:**
  - Cloud Firestore is used as the backend database.
  - Data is structured into collections (e.g., `kullanici`, `kelimekanal`) to handle users, game channels, and game logs.

---

## Methodology

### Database Design

- **Users Collection (`kullanici`):**
  - Stores user information including `isim` (name), `sifre` (password), and `aktiflik` (active status).
  - Active status is updated based on authentication state.

- **Game Channels Collection (`kelimekanal`):**
  - Organized into subcollections based on channel type (e.g., fixed letters vs. variable letters).
  - Enables categorization by letter count (4, 5, 6, or 7 letters).

- **Logs and Requests:**
  - Additional data for game requests and match notifications are stored and updated in real time.

### Multithreading & Concurrency

- **Firebase Authentication Listener:**
  - Monitors user login state and updates active status accordingly.
  
- **Real-Time Updates:**
  - Cloud Firestore streams are used to update game channels and active user lists in real time.
  
- **Simultaneous Data Access:**
  - Concurrency control is managed by Firebase, ensuring that multiple users can update and read data without conflicts.

### Dynamic Priority Management

- **Channel Selection:**
  - Users select channels based on fixed or variable letter settings.
  
- **Real-Time Matching:**
  - Active users are listed in each channel, and game requests are sent to specific users.
  
- **Dynamic Updates:**
  - Game requests and user activity are dynamically updated in the UI, ensuring real-time interactivity.

### Error Management & Logging

- **Error Handling:**
  - Errors during login, registration, or game actions are caught and printed to the console.
  - Alerts are used to notify users of invalid inputs (e.g., repeated guesses or invalid word lengths).

- **Logging:**
  - Firebase Firestore stores logs of user actions (e.g., updating `aktiflik`, game requests).
  - Logs provide a basis for troubleshooting and performance monitoring.

### User Interface (UI) Integration

- **Login & Registration:**
  - Simple screens allow users to log in or register, updating their active status in real time.

- **Home Page & Channel Selection:**
  - Users can navigate to channels with either fixed or variable letter settings.
  - The UI displays available channels and active users within each channel.

- **Gameplay Screen:**
  - Core game logic including target word display, user input for guesses, visual feedback, and a countdown timer.
  - Guesses are evaluated, and each letter is color-coded (green, yellow, grey) based on correctness.

- **Result Screen:**
  - Detailed game outcomes are shown, including player scores, number of correct/incorrect guesses, and time bonus.
  - A comparison with an opponent’s performance is displayed.

### Software Architecture (MVC)

- **Model:**
  - Represents the data structure (user data, game data, logs) stored in Firebase.
  
- **View:**
  - Flutter widgets and UI components form the view, displaying game states, user inputs, and results.
  
- **Controller:**
  - Business logic for handling user actions, game mechanics, and navigation between screens.
  
This separation ensures maintainability and scalability as the project grows.

---

## Experimental Results

- **User Authentication:**
  - Successful registration and login update the user's active status in real time.
  - Firebase Authentication and Firestore integration ensure that only authenticated users access game channels.

- **Real-Time Channel Updates:**
  - Active users are dynamically displayed in each game channel.
  - Game requests and match notifications update instantly as users interact.

- **Gameplay Performance:**
  - The target word is generated randomly and compared to user inputs.
  - Visual feedback accurately reflects correct and incorrect guesses.
  - The countdown timer and guess limits provide a challenging game environment.

- **Score Calculation:**
  - Scores are computed based on correct and incorrect guesses, plus a bonus for remaining time.
  - The result screen clearly displays detailed player statistics and the final winner.

---

## Project Requirements

### User Management

- **Authentication:**
  - Users can log in or register using email and password.
  - User active status (`aktiflik`) is updated based on login state.

- **Data Storage:**
  - User data is stored in the `kullanici` collection in Firestore.
  
### Channel and Game Management

- **Channel Types:**
  - Fixed Letter Channels (Harf Sabiti Olan Kanallar) and Variable Letter Channels (Harf Sabiti Olmayan Kanallar) are provided.
  - Each channel is subdivided by the number of letters in the game (4, 5, 6, or 7 letters).

- **Game Mechanics:**
  - A random target word is selected from a predefined list.
  - Users have a limited number of guesses (e.g., 6) and a countdown timer (e.g., 60 seconds).
  - Visual feedback is provided for each guess (using color-coded boxes).

- **Score and Result Calculation:**
  - Correct guesses, incorrect guesses, and remaining time contribute to the final score.
  - Detailed results are shown on the Result Screen, with a comparison between players.

### Firebase Integration

- **Firebase Services:**
  - **Firebase Authentication:** Manages user login and registration.
  - **Cloud Firestore:** Manages real-time data for user activity, game channels, and logs.
  
- **Data Consistency:**
  - Real-time streams ensure that game state and user data are consistent across all devices.

---

## Documentation & References

- **Microsoft Learn:**  
  "Multithreading in C#: Managing Concurrency and Parallelism"  
  [https://learn.microsoft.com](https://learn.microsoft.com)
- **MySQL Documentation:**  
  "MySQL Reference Manual: The InnoDB Storage Engine"  
  [https://dev.mysql.com/doc/](https://dev.mysql.com/doc/)
- **Concurrency in Software Systems:**  
  John Doe, XYZ Publications, 2020, ISBN: 978-1-23456-789-0.
- **Effective Software Design Principles:**  
  Jane Smith, ABC Publications, 2018, ISBN: 978-9-87654-321-0.
- **C# Programming Guide:**  
  "Handling Events and Delegates in .NET Framework"  
  [https://docs.microsoft.com/en-us/dotnet](https://docs.microsoft.com/en-us/dotnet)

---

## Contributing

Contributions are welcome! If you have ideas, improvements, or bug fixes, please follow these steps:

1. **Fork the Repository:**  
   Create your own branch from the main project.

2. **Implement Changes:**  
   Make improvements or bug fixes in your branch.

3. **Submit a Pull Request:**  
   Provide detailed explanations for your changes in your pull request.

4. **Open an Issue:**  
   For major modifications, open an issue first to discuss the proposed changes.

---

## License

Distributed under the MIT License. See the [LICENSE](LICENSE) file for more details.
