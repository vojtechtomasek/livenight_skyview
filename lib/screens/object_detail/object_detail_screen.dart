import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'widgets/object_header.dart';
import 'widgets/object_basic_info.dart';
import 'widgets/object_description.dart';

@RoutePage()
class ObjectDetailScreen extends StatelessWidget {
  final String? objectName;

  const ObjectDetailScreen({super.key, this.objectName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0F2C),
        elevation: 0,
        title: Text(
          objectName ?? "Object Detail",
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0F2C),
              Color(0xFF0E1B47),
            ],
          ),
        ),
        child: const SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ObjectHeader(),
              SizedBox(height: 24),
              ObjectBasicInfo(),
              SizedBox(height: 24),
              ObjectDescription(),
            ],
          ),
        ),
      ),
    );
  }
}