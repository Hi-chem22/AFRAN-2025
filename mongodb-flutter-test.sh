#!/bin/bash

echo "============================"
echo "AFRAN 2025 MongoDB Atlas Test"
echo "============================"

echo "Updating Flutter dependencies..."
flutter pub get

echo "Building web app for Chrome..."
flutter run -d chrome 
