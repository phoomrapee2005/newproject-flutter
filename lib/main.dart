import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database and load data
  final productProvider = ProductProvider();
  final orderProvider = OrderProvider();

  await productProvider.loadProducts();
  await orderProvider.loadOrders();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => productProvider),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => orderProvider),
      ],
      child: const ClickClackApp(),
    ),
  );
}

class ClickClackApp extends StatelessWidget {
  const ClickClackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Click & Clack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A1C23), // Sleek Slate
          primary: const Color(0xFF1A1C23),
          secondary: const Color(0xFF4361EE), // Modern Indigo
          surface: Colors.white,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.promptTextTheme(),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: const Color(0xFFF8F9FA),
          foregroundColor: const Color(0xFF1A1C23),
          titleTextStyle: GoogleFonts.prompt(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A1C23),
            letterSpacing: -0.5,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.grey.withAlpha(20), width: 1),
          ),
          clipBehavior: Clip.antiAlias,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: const Color(0xFF1A1C23),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.withAlpha(30)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.withAlpha(30)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF1A1C23), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
