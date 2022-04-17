import 'package:flutter/material.dart';

class CustomCircularProgress extends StatelessWidget {
  late final AppBar? _appBar;
  CustomCircularProgress({
    Key? key,
    AppBar? appBar,
  }) : super(key: key) {
    _appBar = appBar;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
