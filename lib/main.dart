import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://xkyhuboqxtrgflmumczu.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhreWh1Ym9xeHRyZ2ZsbXVtY3p1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY2MDYxNTQsImV4cCI6MjA5MjE4MjE1NH0.ekStgsHpUPmagb_D5og_EGfI2BHBui5q8XZ4wAkzczc',
  );

  runApp(
    const ProviderScope(
      child: BikiBookApp(),
    ),
  );
}
