import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:robotech/res/custom_colors.dart';

class ProfileWidget extends StatelessWidget {
  final String imagePath;
  final bool isEdit;
  final VoidCallback onClicked;
  final String text;

  const ProfileWidget(
      {Key? key,
      required this.imagePath,
      this.isEdit = false,
      required this.onClicked,
      required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = kPrimaryColor;

    return Column(
      children: <Widget>[
        Center(
            child: Stack(
          children: [
            buildImage(),
            Positioned(
              bottom: 0,
              right: 4,
              child: buildEditIcon(color),
            ),
          ],
        )),
        Text(this.text, style: GoogleFonts.roboto(fontSize: 12))
      ],
    );
  }

  Widget buildImage() {
    final image = NetworkImage(imagePath);

    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: Ink.image(
          image: image,
          fit: BoxFit.cover,
          width: 80,
          height: 80,
          child: InkWell(onTap: onClicked),
        ),
      ),
    );
  }

  Widget buildEditIcon(Color color) => buildCircle(
        color: Colors.white,
        all: 3,
        child: buildCircle(
            color: color,
            all: 8,
            child: InkWell(
              onTap: onClicked,
              child: Icon(
                isEdit ? Icons.add_a_photo : Icons.edit,
                color: Colors.white,
                size: 15,
              ),
            )),
      );

  Widget buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );
}
