# Halisi CRM

Halisi CRM is a customer relationship management (CRM) product that also functions as an invoice and sales tracker. Built with Flutter, this application allows businesses to follow up with customers, monitor sales and orders, manage customers, and track expenses.

## Features

- **Customer Follow-Up:** Keep track of customer interactions and follow-ups.
- **Sales and Orders Monitoring:** Monitor sales and order status in real-time.
- **Customer Management:** Manage customer information and details efficiently.
- **Expense Tracking:** Track and manage company expenses.

## Getting Started

### Prerequisites

Ensure you have the following installed on your machine:

- Flutter SDK: [Installation Guide](https://flutter.dev/docs/get-started/install)
- Dart SDK: Included with Flutter
- Hive: A lightweight and fast key-value database written in pure Dart.

### Installation

1. **Clone the repository:**

    ```sh
    git clone https://github.com/yourusername/halisicrm.git
    cd halisicrm
    ```

2. **Install dependencies:**

    ```sh
    flutter pub get
    ```

3. **Build Hive files:**

    ```sh
    flutter pub run build_runner build
    ```

### Running the Application

Run the app on your preferred device or emulator:

```sh
flutter run

### Project Structure
lib
├── components      # Reusable UI components
|-- Utils           # Utilities in the application
├── database        # Hive database models and functions
├── pages           # Screens and pages of the application
├── main.dart       # Main entry point of the application


The project utilizes several dependencies for various functionalities:

fl_chart: ^0.68.0
hive: ^2.0.4
hive_flutter: ^1.1.0
path_provider: ^2.0.2
cupertino_icons: ^1.0.6
intl: ^0.19.0
google_fonts: ^6.2.1
hive_generator: ^2.0.1
build_runner: ^2.1.2
flutter_lints: ^4.0.0
Development
To contribute to this project, follow these steps:

Fork the repository.
Create a new branch (git checkout -b feature/YourFeature).
Make your changes.
Commit your changes (git commit -am 'Add some feature').
Push to the branch (git push origin feature/YourFeature).
Create a new Pull Request.
License
This project is licensed under the MIT License - see the LICENSE file for details.

Acknowledgements
Flutter: https://flutter.dev/
Hive: https://hivedb.dev/
Contact# halisicrm
