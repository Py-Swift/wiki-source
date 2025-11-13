# AudioKit Arpeggiator

This example demonstrates wrapping an AudioKit-based arpeggiator that automatically plays held notes in ascending and descending patterns. It shows how to wrap audio engine components, MIDI instruments, sequencers, and real-time tempo/note length controls.

## Getting Started

An arpeggiator takes a set of held notes and plays them sequentially in a pattern. This example uses:

- **AppleSampler** - AudioKit's sampler instrument for playback
- **SequencerTrack** - For timing and triggering arpeggio steps
- **CallbackInstrument** - For MIDI event handling
- **AudioEngine** - AudioKit's audio processing engine

## Part 1: Basic Swift Implementation

First, here's a basic Swift implementation without PySwiftKit:

```swift
import AudioKit
import AudioKitEX
import AVFoundation

class ArpeggiatorWrapper {
    let engine = AudioEngine()
    var instrument = AppleSampler()
    var sequencer: SequencerTrack!
    var midiCallback: CallbackInstrument!
    
    var heldNotes = [Int]()
    var isArpDescending = false
    var currentNote = 0
    var sequencerNoteLength = 1.0
    var tempo: Float = 120.0
    
    init() {
        midiCallback = CallbackInstrument { status, note, vel in
            if status == 144 { // Note On
                self.fireTimer()
            } else if status == 128 { // Note Off
                // All notes off
                for i in 0...127 {
                    self.instrument.stop(noteNumber: UInt8(i), channel: 0)
                }
            }
        }
        
        engine.output = PeakLimiter(Mixer(instrument, midiCallback), 
                                    attackTime: 0.001, 
                                    decayTime: 0.001, 
                                    preGain: 0)
        
        // Load instrument
        if let fileURL = Bundle.main.url(forResource: "sawPiano1", withExtension: "exs") {
            try? instrument.loadInstrument(url: fileURL)
        }
        
        sequencer = SequencerTrack(targetNode: midiCallback)
        sequencer.length = 0.25
        sequencer.loopEnabled = true
        sequencer.add(noteNumber: 60, position: 0.0, duration: 0.24)
        sequencer.tempo = 120.0
        sequencer.playFromStart()
    }
    
    func addNote(_ pitch: Int) {
        heldNotes.append(max(0, pitch))
    }
    
    func removeNote(_ pitch: Int) {
        heldNotes = heldNotes.filter { $0 != pitch }
    }
    
    func fireTimer() {
        // Stop all playing notes
        for i in 0...127 {
            instrument.stop(noteNumber: UInt8(i), channel: 0)
        }
        
        if heldNotes.count < 1 {
            return
        }
        
        // Arpeggiator algorithm
        if !isArpDescending {
            if heldNotes.max() != currentNote {
                currentNote = heldNotes.filter { $0 > currentNote }.min() ?? heldNotes.min()!
            } else {
                isArpDescending = true
                currentNote = heldNotes.filter { $0 < currentNote }.max() ?? heldNotes.max()!
            }
        } else {
            if heldNotes.min() != currentNote {
                currentNote = heldNotes.filter { $0 < currentNote }.max() ?? heldNotes.max()!
            } else {
                isArpDescending = false
                currentNote = heldNotes.filter { $0 > currentNote }.min() ?? heldNotes.min()!
            }
        }
        
        instrument.play(noteNumber: UInt8(currentNote), velocity: 120, channel: 0)
    }
    
    func setTempo(_ bpm: Float) {
        tempo = bpm
        sequencer.tempo = Double(bpm)
    }
    
    func setNoteLength(_ length: Float) {
        sequencerNoteLength = Double(length)
        sequencer.clear()
        sequencer.add(noteNumber: 60, position: 0.0, duration: max(0.05, sequencerNoteLength * 0.24))
    }
    
    func start() {
        try? engine.start()
        sequencer.playFromStart()
    }
    
    func stop() {
        engine.stop()
        sequencer.stop()
    }
}
```

This implementation handles note input, arpeggio pattern generation, tempo control, and MIDI timing.

## Part 2: Swift with PySwiftKit

Now let's wrap it with PySwiftKit decorators to expose it to Python:

```swift
import AudioKit
import AudioKitEX
import AVFoundation
import PythonSwiftLink

@PyClass
class AudioArpeggiator {
    let engine = AudioEngine()
    var instrument = AppleSampler()
    var sequencer: SequencerTrack!
    var midiCallback: CallbackInstrument!
    
    var heldNotes = [Int]()
    var isArpDescending = false
    var currentNote = 0
    var sequencerNoteLength = 1.0
    var tempo: Float = 120.0
    
    @PyInit
    init() {
        midiCallback = CallbackInstrument { [weak self] status, note, vel in
            guard let self = self else { return }
            if status == 144 { // Note On
                self.fireTimer()
            } else if status == 128 { // Note Off
                // All notes off
                for i in 0...127 {
                    self.instrument.stop(noteNumber: UInt8(i), channel: 0)
                }
            }
        }
        
        engine.output = PeakLimiter(Mixer(instrument, midiCallback), 
                                    attackTime: 0.001, 
                                    decayTime: 0.001, 
                                    preGain: 0)
        
        // Load instrument from bundle
        if let fileURL = Bundle.main.url(forResource: "sawPiano1", withExtension: "exs") {
            try? instrument.loadInstrument(url: fileURL)
        }
        
        sequencer = SequencerTrack(targetNode: midiCallback)
        sequencer.length = 0.25
        sequencer.loopEnabled = true
        sequencer.add(noteNumber: 60, position: 0.0, duration: 0.24)
        sequencer.tempo = 120.0
        sequencer.playFromStart()
    }
    
    @PyMethod
    func add_note(_ pitch: Int) {
        heldNotes.append(max(0, pitch))
    }
    
    @PyMethod
    func remove_note(_ pitch: Int) {
        heldNotes = heldNotes.filter { $0 != pitch }
    }
    
    @PyMethod
    func clear_notes() {
        heldNotes.removeAll()
    }
    
    @PyMethod
    func get_held_notes() -> [Int] {
        return heldNotes
    }
    
    func fireTimer() {
        // Stop all playing notes
        for i in 0...127 {
            instrument.stop(noteNumber: UInt8(i), channel: 0)
        }
        
        if heldNotes.count < 1 {
            return
        }
        
        // Arpeggiator algorithm - ascending then descending
        if !isArpDescending {
            if heldNotes.max() != currentNote {
                currentNote = heldNotes.filter { $0 > currentNote }.min() ?? heldNotes.min()!
            } else {
                isArpDescending = true
                currentNote = heldNotes.filter { $0 < currentNote }.max() ?? heldNotes.max()!
            }
        } else {
            if heldNotes.min() != currentNote {
                currentNote = heldNotes.filter { $0 < currentNote }.max() ?? heldNotes.max()!
            } else {
                isArpDescending = false
                currentNote = heldNotes.filter { $0 > currentNote }.min() ?? heldNotes.min()!
            }
        }
        
        instrument.play(noteNumber: UInt8(currentNote), velocity: 120, channel: 0)
    }
    
    @PyMethod
    func set_tempo(_ bpm: Float) {
        tempo = max(20.0, min(250.0, bpm))  // Clamp to reasonable range
        sequencer.tempo = Double(tempo)
    }
    
    @PyMethod
    func get_tempo() -> Float {
        return tempo
    }
    
    @PyMethod
    func set_note_length(_ length: Float) {
        sequencerNoteLength = Double(max(0.0, min(1.0, length)))  // Clamp 0-1
        sequencer.clear()
        sequencer.add(noteNumber: 60, position: 0.0, duration: max(0.05, sequencerNoteLength * 0.24))
    }
    
    @PyMethod
    func get_note_length() -> Float {
        return Float(sequencerNoteLength)
    }
    
    @PyMethod
    func start() {
        do {
            try engine.start()
            sequencer.playFromStart()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    @PyMethod
    func stop() {
        engine.stop()
        sequencer.stop()
    }
    
    @PyMethod
    func pause() {
        sequencer.stop()
    }
    
    @PyMethod
    func resume() {
        sequencer.playFromStart()
    }
}

@PyModule
class ArpeggiatorModule {
    static func registerTypes() {
        AudioArpeggiator.register()
    }
}
```

!!! note "Key AudioKit Components"
    - **AppleSampler**: Loads and plays sampled instruments (.exs, .sf2, .wav files)
    - **SequencerTrack**: Provides timing for arpeggio steps with tempo control
    - **CallbackInstrument**: Receives MIDI events for triggering notes
    - **AudioEngine**: Manages the audio processing graph
    - **PeakLimiter/Mixer**: Audio processing nodes for output management

## Part 3: Python Interface

Define the Python interface to interact with the arpeggiator:

```python
from typing import List

class AudioArpeggiator:
    """AudioKit-based arpeggiator with tempo and note length controls."""
    
    def __init__(self) -> None:
        """Initialize the arpeggiator with default settings (120 BPM, note length 1.0)."""
        ...
    
    def add_note(self, pitch: int) -> None:
        """
        Add a note to the arpeggiator.
        
        Args:
            pitch: MIDI note number (0-127)
        """
        ...
    
    def remove_note(self, pitch: int) -> None:
        """
        Remove a note from the arpeggiator.
        
        Args:
            pitch: MIDI note number to remove
        """
        ...
    
    def clear_notes(self) -> None:
        """Clear all held notes."""
        ...
    
    def get_held_notes(self) -> List[int]:
        """
        Get the list of currently held notes.
        
        Returns:
            List of MIDI note numbers
        """
        ...
    
    def set_tempo(self, bpm: float) -> None:
        """
        Set the arpeggiator tempo.
        
        Args:
            bpm: Beats per minute (20-250)
        """
        ...
    
    def get_tempo(self) -> float:
        """
        Get the current tempo.
        
        Returns:
            Current BPM
        """
        ...
    
    def set_note_length(self, length: float) -> None:
        """
        Set the note length parameter.
        
        Args:
            length: Note length (0.0-1.0, where 1.0 is full note duration)
        """
        ...
    
    def get_note_length(self) -> float:
        """
        Get the current note length.
        
        Returns:
            Current note length (0.0-1.0)
        """
        ...
    
    def start(self) -> None:
        """Start the audio engine and sequencer."""
        ...
    
    def stop(self) -> None:
        """Stop the audio engine and sequencer."""
        ...
    
    def pause(self) -> None:
        """Pause the sequencer (keeps audio engine running)."""
        ...
    
    def resume(self) -> None:
        """Resume the sequencer."""
        ...
```

## Usage Example

```python
from audio_arpeggiator import AudioArpeggiator
import time

# Create and start arpeggiator
arp = AudioArpeggiator()
arp.start()

# Play a C major chord arpeggiated
arp.add_note(60)  # C
arp.add_note(64)  # E
arp.add_note(67)  # G

# Let it play for a bit
time.sleep(4)

# Change tempo
arp.set_tempo(180.0)  # Speed up to 180 BPM
time.sleep(2)

# Adjust note length (shorter, more staccato)
arp.set_note_length(0.3)
time.sleep(2)

# Add more notes (C major 7th)
arp.add_note(71)  # B
time.sleep(2)

# Remove a note
arp.remove_note(64)  # Remove E
time.sleep(2)

# Check what's playing
print(f"Held notes: {arp.get_held_notes()}")
print(f"Current tempo: {arp.get_tempo()} BPM")
print(f"Note length: {arp.get_note_length()}")

# Clear and play new pattern
arp.clear_notes()
arp.add_note(57)  # A
arp.add_note(60)  # C
arp.add_note(64)  # E
arp.add_note(69)  # A (octave)

time.sleep(4)

# Pause and resume
arp.pause()
time.sleep(1)
arp.resume()
time.sleep(2)

# Clean up
arp.stop()
```

## Advanced Usage: Interactive Music App

```python
from audio_arpeggiator import AudioArpeggiator
import time

class ArpeggioMusicBox:
    """Interactive music box with multiple arpeggiator patterns."""
    
    def __init__(self):
        self.arp = AudioArpeggiator()
        self.arp.start()
        self.patterns = {
            'c_major': [60, 64, 67, 72],
            'a_minor': [57, 60, 64, 69],
            'f_major': [53, 57, 60, 65],
            'g_major': [55, 59, 62, 67],
        }
    
    def play_pattern(self, name: str, duration: float = 4.0):
        """Play a chord pattern."""
        if name not in self.patterns:
            print(f"Unknown pattern: {name}")
            return
        
        # Clear previous notes
        self.arp.clear_notes()
        
        # Add new pattern
        for note in self.patterns[name]:
            self.arp.add_note(note)
        
        print(f"Playing {name}: {self.arp.get_held_notes()}")
        time.sleep(duration)
    
    def play_progression(self, tempo: float = 120.0):
        """Play a chord progression."""
        self.arp.set_tempo(tempo)
        self.arp.set_note_length(0.8)
        
        progression = ['c_major', 'a_minor', 'f_major', 'g_major']
        
        for chord in progression:
            self.play_pattern(chord, duration=4.0)
    
    def improvise(self, duration: float = 10.0):
        """Create improvised patterns with tempo changes."""
        import random
        
        start_time = time.time()
        
        while time.time() - start_time < duration:
            # Random tempo change
            tempo = random.uniform(80, 180)
            self.arp.set_tempo(tempo)
            
            # Random note length
            note_length = random.uniform(0.2, 1.0)
            self.arp.set_note_length(note_length)
            
            # Random pattern
            pattern = random.choice(list(self.patterns.keys()))
            self.play_pattern(pattern, duration=2.0)
    
    def stop(self):
        """Stop the arpeggiator."""
        self.arp.stop()

# Example usage
music_box = ArpeggioMusicBox()

print("Playing chord progression...")
music_box.play_progression(tempo=140)

print("\nImprovising...")
music_box.improvise(duration=10)

print("\nCleaning up...")
music_box.stop()
```

!!! tip "MIDI Note Numbers"
    - **C4 (Middle C)**: 60
    - **Each octave**: +/- 12 semitones
    - **Range**: 0-127 (MIDI standard)
    - Common chords:
        - C Major: [60, 64, 67]
        - A minor: [57, 60, 64]
        - G Major: [55, 59, 62]

!!! warning "Audio Resources"
    The AppleSampler requires an instrument file to be loaded. Make sure to:
    
    - Include `.exs` (Logic/GarageBand instrument) or `.sf2` (SoundFont) files in your app bundle
    - Update the file path in `loadInstrument(url:)` to match your resources
    - Handle errors when loading fails
    
    ```swift
    if let fileURL = Bundle.main.url(forResource: "yourInstrument", withExtension: "exs") {
        try instrument.loadInstrument(url: fileURL)
    }
    ```

!!! info "Arpeggiator Algorithm"
    The arpeggiator uses an ascending-descending pattern:
    
    1. Plays notes in ascending order until reaching the highest note
    2. Switches to descending order
    3. Plays down to the lowest note
    4. Switches back to ascending
    5. Repeats continuously
    
    This creates a smooth, musical pattern that's common in synthesizers and sequencers.

!!! note "Performance Considerations"
    - The SequencerTrack runs on a separate thread for accurate timing
    - CallbackInstrument events are triggered at each sequencer step
    - AudioEngine should be started before adding notes for immediate playback
    - Use `pause()`/`resume()` instead of `stop()`/`start()` to avoid audio glitches

## Use Cases

**Music Production Tools**
```python
# Create a music sketching app
from audio_arpeggiator import AudioArpeggiator

class MusicSketchpad:
    def __init__(self):
        self.arp = AudioArpeggiator()
        self.arp.set_tempo(120)
        self.arp.start()
    
    def sketch_idea(self, notes, tempo=120, length=0.8):
        """Quickly sketch a musical idea."""
        self.arp.set_tempo(tempo)
        self.arp.set_note_length(length)
        self.arp.clear_notes()
        for note in notes:
            self.arp.add_note(note)
```

**Educational Apps**
```python
# Teach music theory with interactive arpeggios
class MusicTheoryTeacher:
    def __init__(self):
        self.arp = AudioArpeggiator()
        self.arp.start()
    
    def demonstrate_chord(self, root, chord_type):
        """Demonstrate a chord by arpeggiation."""
        intervals = {
            'major': [0, 4, 7],
            'minor': [0, 3, 7],
            'dim': [0, 3, 6],
            'aug': [0, 4, 8],
        }
        
        self.arp.clear_notes()
        for interval in intervals[chord_type]:
            self.arp.add_note(root + interval)
```

**Generative Music**
```python
# Create evolving ambient soundscapes
import random
import time

class AmbientGenerator:
    def __init__(self):
        self.arp = AudioArpeggiator()
        self.arp.set_tempo(60)  # Slow, ambient tempo
        self.arp.set_note_length(0.9)  # Long, flowing notes
        self.arp.start()
    
    def evolve(self, duration=30):
        """Generate evolving ambient patterns."""
        scale = [60, 62, 64, 67, 69, 72]  # Pentatonic scale
        
        start = time.time()
        while time.time() - start < duration:
            # Randomly add or remove notes
            if random.random() > 0.5 and len(self.arp.get_held_notes()) < 5:
                note = random.choice(scale)
                self.arp.add_note(note)
            elif self.arp.get_held_notes():
                note = random.choice(self.arp.get_held_notes())
                self.arp.remove_note(note)
            
            time.sleep(random.uniform(2, 5))
```
