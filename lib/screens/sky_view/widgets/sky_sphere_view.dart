// lib/feature/sky_view/widgets/sky_sphere_view.dart
import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'package:three_dart/three_dart.dart' as THREE;

import 'simple_sky_view.dart'; // ⬅️ přidat

class SkySphereView extends StatefulWidget {
  const SkySphereView({super.key});

  @override
  State<SkySphereView> createState() => _SkySphereViewState();
}

class _SkySphereViewState extends State<SkySphereView> {
  late FlutterGlPlugin _glPlugin;
  late THREE.Scene _scene;
  late THREE.PerspectiveCamera _camera;
  late THREE.WebGLRenderer _renderer;

  bool _isInit = false;
  bool _isDisposed = false;
  Timer? _animationTimer;

  @override
  void dispose() {
    _isDisposed = true;
    _animationTimer?.cancel();
    _animationTimer = null;

    try {
      if (_isInit) {
        _glPlugin.dispose();
      }
    } catch (e) {
      debugPrint('Error disposing GL plugin: $e');
    }

    super.dispose();
  }

  Future<void> _initGl(Size size) async {
    if (_isDisposed || !mounted) return;

    try {
      await Future.delayed(const Duration(milliseconds: 100));

      if (_isDisposed || !mounted) return;

      _glPlugin = FlutterGlPlugin();

      await _glPlugin.initialize(
        options: {
          "antialias": false,
          "alpha": false,
          "width": size.width.toInt(),
          "height": size.height.toInt(),
          "dpr": 1.0,
        },
      );

      await Future.delayed(const Duration(milliseconds: 200));
      await _glPlugin.prepareContext();

      int retries = 0;
      while ((_glPlugin.gl == null || _glPlugin.element == null) &&
          retries < 30) {
        await Future.delayed(const Duration(milliseconds: 100));
        retries++;
        if (_isDisposed || !mounted) return;
      }

      if (_glPlugin.gl != null &&
          _glPlugin.element != null &&
          !_isDisposed &&
          mounted) {
        debugPrint('GL context ready, initializing scene...');
        _initScene(size);

        await Future.delayed(const Duration(milliseconds: 300));

        int textureRetries = 0;
        while (_glPlugin.textureId == null && textureRetries < 50) {
          await Future.delayed(const Duration(milliseconds: 100));
          textureRetries++;
          if (_isDisposed || !mounted) return;
        }

        if (_glPlugin.textureId != null) {
          debugPrint(
              'GL texture initialized successfully: ${_glPlugin.textureId}');
          _animate();

          if (mounted) {
            setState(() {
              _isInit = true;
            });
          }
        } else {
          debugPrint('GL texture failed to initialize after extended retries');
          if (mounted) {
            setState(() {
              _isInit = true; // zobrazíme fallback
            });
          }
        }
      } else {
        debugPrint('GL context failed to initialize properly');
        if (mounted) {
          setState(() {
            _isInit = true; // zobrazíme fallback
          });
        }
      }
    } catch (e) {
      debugPrint('Failed to initialize GL: $e');

      try {
        _glPlugin.dispose();
      } catch (disposeError) {
        debugPrint('Error disposing GL plugin: $disposeError');
      }

      if (mounted) {
        setState(() {
          _isInit = true; // zobrazíme fallback
        });
      }
    }
  }

  void _initScene(Size size) {
    _scene = THREE.Scene();

    _camera = THREE.PerspectiveCamera(
      60,
      size.width / size.height,
      0.1,
      1000,
    );
    _camera.position.set(0, 0, 0);
    _camera.lookAt(THREE.Vector3(0, 0, -1));

    _renderer = THREE.WebGLRenderer({
      "gl": _glPlugin.gl,
      "canvas": _glPlugin.element,
      "antialias": true,
      "alpha": false,
    });

    _renderer.setSize(size.width, size.height, false);

    _addSkyDome();
    _addStars();
  }

  void _addSkyDome() {
    final geo = THREE.SphereGeometry(50, 32, 32);
    final mat = THREE.MeshBasicMaterial({
      "color": 0x000814,
      "side": THREE.BackSide,
    });
    final mesh = THREE.Mesh(geo, mat);
    _scene.add(mesh);
  }

  void _addStars() {
    final positions = <double>[
      ..._pointOnSphere(0, 30),
      ..._pointOnSphere(60, 15),
      ..._pointOnSphere(140, 45),
      ..._pointOnSphere(220, 10),
      ..._pointOnSphere(310, 70),
    ];

    final geo = THREE.BufferGeometry();
    geo.setAttribute(
      'position',
      THREE.Float32BufferAttribute(
        Float32List.fromList(positions) as dynamic,
        3,
      ),
    );

    final mat = THREE.PointsMaterial({
      "color": 0xffffff,
      "size": 1.8,
      "sizeAttenuation": true,
    });

    final stars = THREE.Points(geo, mat);
    _scene.add(stars);
  }

  List<double> _pointOnSphere(double azDeg, double altDeg) {
    const radius = 50.5;
    final az = azDeg * math.pi / 180;
    final alt = altDeg * math.pi / 180;

    final x = math.cos(alt) * math.sin(az);
    final y = math.sin(alt);
    final z = math.cos(alt) * math.cos(az);

    return [x * radius, y * radius, z * radius];
  }

  /// 🔁 Animace 3D scény
  void _animate() {
    if (_isDisposed) return;

    _animationTimer = Timer(const Duration(milliseconds: 16), () {
      if (!_isDisposed && _isInit && _glPlugin.textureId != null) {
        try {
          _scene.rotation.y += 0.002;
          _renderer.render(_scene, _camera);
          _glPlugin.gl.flush();
          _animate();
        } catch (e) {
          debugPrint('Animation error: $e');
        }
      }
    });
  }

  /// 🌓 2D fallback – tady použijeme SimpleSkyView
  Widget _buildFallbackView() {
    return const SimpleSkyView();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        if (!_isInit &&
            size.width > 0 &&
            size.height > 0 &&
            !_isDisposed) {
          _initGl(size);
        }

        if (!_isInit) {
          // loading stav
          return Container(
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
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          );
        }

        // po inicializaci
        return _glPlugin.textureId != null
            ? Texture(textureId: _glPlugin.textureId!)
            : _buildFallbackView();
      },
    );
  }
}
