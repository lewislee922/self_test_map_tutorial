import 'package:flutter/material.dart';

class CountDownTile extends StatelessWidget {
  final VoidCallback onPressed;
  final Stream<int> stream;
  const CountDownTile(
      {super.key, required this.stream, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: stream,
      builder: (context, snapshot) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.white.withOpacity(0.75)
                : Colors.grey.withOpacity(0.75),
          ),
          child: Row(
            children: [
              Text("${snapshot.data ?? 0} 秒後更新"),
              const SizedBox(width: 4.0),
              IconButton(icon: const Icon(Icons.refresh), onPressed: onPressed)
            ],
          ),
        );
      },
    );
  }
}
