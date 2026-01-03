#!/bin/bash

# Script para verificar la configuración de flavors en iOS
# Ejecutar desde la raíz del proyecto: ./ios/verify_flavors.sh

echo "🔍 Verificando configuración de flavors en iOS..."
echo ""

cd ios

echo "📋 Schemes disponibles:"
xcodebuild -list -workspace Runner.xcworkspace 2>/dev/null | grep -A 100 "Schemes:" | grep -v "Schemes:" | head -n 10

echo ""
echo "✅ Si ves 'dev', 'staging' y 'prod' arriba, los schemes están configurados correctamente."
echo ""
echo "Para ejecutar cada flavor:"
echo "  flutter run --flavor dev -t lib/main_dev.dart"
echo "  flutter run --flavor staging -t lib/main_staging.dart"
echo "  flutter run --flavor prod -t lib/main_prod.dart"
