
import 'package:aroundu/utils/logger.utils.dart';
import 'package:aroundu/views/scanner/admin_qr_screen.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/material.dart';

class OpenScanner extends StatefulWidget {
  const OpenScanner({super.key, required this.lobbyId});
  final String lobbyId;

  @override
  State<OpenScanner> createState() => _OpenScannerState();
}

class _OpenScannerState extends State<OpenScanner> with WidgetsBindingObserver {
  Barcode? _barcode;
  bool _isNavigating = false;
  bool _isFlashlightOn = false;
  MobileScannerController? _controller;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeScanner();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes to properly manage camera resources
    if (state == AppLifecycleState.resumed) {
      _controller?.start();
    } else if (state == AppLifecycleState.inactive) {
      _controller?.stop();
    }
  }

  void _initializeScanner() {
    try {
      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        torchEnabled: _isFlashlightOn,
      );
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to initialize camera: $e';
      });
    }
  }

  void _toggleFlashlight() {
    setState(() {
      _isFlashlightOn = !_isFlashlightOn;
      _controller?.toggleTorch();
    });
  }

  Widget _buildBarcode(Barcode? value) {
    kLogger.trace(value.toString());
    if (value == null) {
      return const Text(
        'Position QR code in the scanning area',
        overflow: TextOverflow.fade,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    return Text(
      "Position QR code in the scanning area",
      // value.displayValue ?? "No display value",
      overflow: TextOverflow.fade,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void _handleBarcode(BarcodeCapture barcodes) {
    if (mounted) {
      final barcodeValue = barcodes.barcodes.firstOrNull?.displayValue;

      if (barcodeValue != null && !_isNavigating) {
        setState(() {
          _barcode = barcodes.barcodes.firstOrNull;
          _isNavigating = true;
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminQrScreen(url: barcodeValue,lobbyId: widget.lobbyId,),
          ),
        ).then((_) {
          // Reset navigation state when returning from result screen
          if (mounted) {
            setState(() {
              _isNavigating = false;
            });
          }
        });
      }
    }
  }

  Widget _buildScannerOverlay() {
    return Center(
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              height: 50,
              child: const Icon(
                Icons.qr_code_scanner,
                color: Colors.white54,
                size: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Scanner
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
            errorBuilder: (context, error, child) {
              return Center(
                child: Text(
                  'Scanner error: ${error.errorDetails?.message ?? 'Unknown error'}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            },
          ),

          // Scanning overlay
          _buildScannerOverlay(),

          // Bottom info bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              alignment: Alignment.bottomCenter,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Center(child: _buildBarcode(_barcode)),
                  ),
                ],
              ),
            ),
          ),

          // Top bar with back button and flashlight toggle
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(
                  top: 40, left: 10, right: 10, bottom: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Text(
                    'Scan QR Code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isFlashlightOn ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                    ),
                    onPressed: _toggleFlashlight,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScanResultScreen extends StatelessWidget {
  final String result;

  const ScanResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Result'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 60,
              ),
              const SizedBox(height: 24),
              const Text(
                'Successfully Scanned',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Scanned Value: $result',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


//=======================================================================================

// import 'package:aroundu/views/scanner/view/admin_qr_screen.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:flutter/material.dart';

// class OpenScanner extends StatefulWidget {
//   const OpenScanner({super.key});

//   @override
//   State<OpenScanner> createState() => _OpenScannerState();
// }

// class _OpenScannerState extends State<OpenScanner> {
//   Barcode? _barcode;
//   bool _isNavigating = false;

//   Widget _buildBarcode(Barcode? value) {
//     if (value == null) {
//       return const Text(
//         'Scan something',
//         overflow: TextOverflow.fade,
//         style: TextStyle(color: Colors.white),
//       );
//     }
//     return Text(
//       value.displayValue ?? "No display value",
//       overflow: TextOverflow.fade,
//       style: const TextStyle(color: Colors.white),
//     );
//   }

//   void _handleBarcode(BarcodeCapture barcodes) {
//     if (mounted) {
//       final barcodeValue = barcodes.barcodes.firstOrNull?.displayValue;

//       if (barcodeValue != null && !_isNavigating) {
//         setState(() {
//           _barcode = barcodes.barcodes.firstOrNull;
//           _isNavigating = true;
//         });

//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => AdminQrScreen(url: barcodeValue),
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           MobileScanner(
//             onDetect: _handleBarcode,
//           ),
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Container(
//               alignment: Alignment.bottomCenter,
//               height: 100,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   Expanded(
//                     child: Center(child: _buildBarcode(_barcode)),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Positioned(
//             top: 40,
//             left: 10,
//             child: InkWell(
//               onTap: () {
//                 Navigator.pop(context);
//               },
//               child: Icon(Icons.arrow_back, color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ScanResultScreen extends StatelessWidget {
//   final String result;

//   const ScanResultScreen({super.key, required this.result});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Scan Result'),
//       ),
//       body: Center(
//         child: Text(
//           'Scanned Value: $result',
//           style: TextStyle(fontSize: 20),
//           textAlign: TextAlign.center,
//         ),
//       ),
//     );
//   }
// }

