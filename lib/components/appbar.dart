import 'package:flutter/material.dart';
import 'package:halisicrm/utils/appbar_util.dart';
import 'package:google_fonts/google_fonts.dart';

class MyAppBar extends StatelessWidget {
  const MyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: AppBarClipper(),
      child: Container(
        color: Colors.lightBlue, // Light blue background color
        child: AppBar(
          backgroundColor: Colors.blue[500],
          centerTitle: true,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    greeting,
                    style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold, // Bold greetings
                          color: Colors.white),
                    ),
                  ),
                  Text(
                    '$emoji ',
                    style: GoogleFonts.lato(
                      textStyle: TextStyle(
                        fontSize: 20,
                        color: emojiColor, // Dynamic emoji color
                      ),
                    ),
                  ),
                ],
              ),

              Text(
                'Today is $formattedDate',
                style: GoogleFonts.lato(
                    textStyle: const TextStyle(
                        fontFamily: 'RobotoMono',
                        fontSize: 18,
                        fontWeight: FontWeight.bold, // Bold greetings
                        color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    const double curveHeight = 20.0;

    // Move to the start point of the bottom left corner
    path.moveTo(0, size.height);

    // Draw a quadratic bezier curve to the bottom left corner
    path.quadraticBezierTo(
        0, size.height - curveHeight, curveHeight, size.height - curveHeight);

    // Draw a straight line to the bottom right corner
    path.lineTo(size.width - curveHeight, size.height - curveHeight);

    // Draw a quadratic bezier curve to the end point of the bottom right corner
    path.quadraticBezierTo(
        size.width, size.height - curveHeight, size.width, size.height);

    // Draw a straight line to the top right corner
    path.lineTo(size.width, 0);

    // Draw a straight line to the top left corner
    path.lineTo(0, 0);

    // Close the path to create a closed shape
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
