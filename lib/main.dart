import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_midi/flutter_midi.dart';
import 'package:piano/piano.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((value) => runApp(MyApp()));
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late FlutterMidi _flutterMidi;

  String _selectedInstrument = 'piano';
  String _selectedInstrumentSoundFont = 'assets/piano.sf2';

  void load(String asset) async {
    print('Loading File...');
    _flutterMidi.unmute();
    ByteData _byte = await rootBundle.load(asset);
    _flutterMidi.prepare(sf2: _byte, name: asset.replaceAll('assets/', ''));
  }

  void _changeInstrument(String instrument) {
    setState(() {
      _selectedInstrument = instrument;
      switch (instrument) {
        case 'piano':
          _selectedInstrumentSoundFont = 'assets/piano.sf2';
          break;
        case 'guitar':
          _selectedInstrumentSoundFont = 'assets/guitar.sf2';
          break;
        case 'flute':
          _selectedInstrumentSoundFont = 'assets/flute.sf2';
          break;
      }
      load(_selectedInstrumentSoundFont);
    });
  }

  void onNotePositionTapped(NotePosition position) {
    int midiNumber = position.pitch;
    print(midiNumber);
    // Use the MIDI note to play the sound
    _flutterMidi.playMidiNote(midi: midiNumber);
  }

  @override
  void initState() {
    _flutterMidi = FlutterMidi(); // Initialize _flutterMidi here
    if (!kIsWeb) {
      load(_selectedInstrumentSoundFont);
    } else {
      _flutterMidi.prepare(sf2: null);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: Center(child: Text('Multi Instrument')),
            actions: [
              DropdownButton(
                value: _selectedInstrument,
                onChanged: (String? newValue) {
                  _changeInstrument(newValue!);
                },
                items: ['piano', 'guitar', 'flute']
                    .map((value) =>
                        DropdownMenuItem(value: value, child: Text(value)))
                    .toList(),
              )
            ],
          ),
          body: InteractivePiano(
            highlightedNotes: [NotePosition(note: Note.D, octave: 3)],
            naturalColor: Colors.white,
            accidentalColor: Colors.black,
            keyWidth: 60,
            noteRange: NoteRange.forClefs([
              Clef.Treble,
            ]),
            onNotePositionTapped: onNotePositionTapped,
          ),
        ));
  }
}
