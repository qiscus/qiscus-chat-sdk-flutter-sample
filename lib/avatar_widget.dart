import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  Avatar({@required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage: Image.network(
        url,
        errorBuilder: (_, __, ___) {
          return Image.asset('assets/ic-default-avatar.png');
        },
      ).image,
      onBackgroundImageError: (_, __) {},
    );
  }
}
