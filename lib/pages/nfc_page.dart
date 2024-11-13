import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'dart:typed_data';
import '../services/api_service.dart'; // Importar el servicio de API

class NfcPage extends StatefulWidget {
  const NfcPage({Key? key}) : super(key: key);

  @override
  _NfcPageState createState() => _NfcPageState();
}

class _NfcPageState extends State<NfcPage> {
  String _nfcData = 'Acerca tu dispositivo a una etiqueta NFC';
  final ApiService _apiService = ApiService(); // Instancia del servicio de API

  @override
  void initState() {
    super.initState();
    _checkNfcAvailability();
  }

  /// Verifica si el NFC está disponible en el dispositivo
  Future<void> _checkNfcAvailability() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      setState(() {
        _nfcData = 'El NFC no está disponible en este dispositivo';
      });
    }
  }

  /// Inicia la sesión NFC y maneja la lectura de etiquetas
  void _startNfcSession() {
    setState(() {
      _nfcData = 'Esperando una etiqueta NFC...';
    });

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          String data = '';
          Uint8List? identifier;

          // Intentamos obtener el identificador de diferentes tecnologías
          if (tag.data.containsKey('nfca')) {
            identifier = tag.data['nfca']['identifier'] as Uint8List?;
          } else if (tag.data.containsKey('nfcf')) {
            identifier = tag.data['nfcf']['identifier'] as Uint8List?;
          } else if (tag.data.containsKey('nfcv')) {
            identifier = tag.data['nfcv']['identifier'] as Uint8List?;
          } else if (tag.data.containsKey('isodep')) {
            identifier = tag.data['isodep']['identifier'] as Uint8List?;
          } else if (tag.data.containsKey('mifareclassic')) {
            identifier = tag.data['mifareclassic']['identifier'] as Uint8List?;
          } else if (tag.data.containsKey('mifareultralight')) {
            identifier = tag.data['mifareultralight']['identifier'] as Uint8List?;
          }

          if (identifier != null && identifier.isNotEmpty) {
            final uid = identifier.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
            data += 'UID: $uid';

            // Intentar guardar el UID en el backend
            final success = await _apiService.saveNfcUid(uid);
            if (success) {
              data += '\nUID almacenado correctamente.';
            } else {
              data += '\nNo se pudo guardar el UID (puede que ya exista).';
            }
          } else {
            data += 'No se pudo obtener el UID de la etiqueta.';
          }

          setState(() {
            _nfcData = data;
          });

          // Detener la sesión después de leer la etiqueta
          await NfcManager.instance.stopSession();
        } catch (e) {
          setState(() {
            _nfcData = 'Error al leer la etiqueta: $e';
          });
          await NfcManager.instance.stopSession(errorMessage: e.toString());
        }
      },
    );
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lectura de Etiquetas NFC'),
        backgroundColor: const Color.fromARGB(255, 26, 28, 36),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _nfcData,
            style: const TextStyle(fontSize: 16, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startNfcSession,
        backgroundColor: const Color.fromARGB(255, 26, 28, 36),
        child: const Icon(Icons.nfc, color: Colors.white),
      ),
    );
  }
}
