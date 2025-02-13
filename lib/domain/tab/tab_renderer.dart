import 'tab_template.dart';

/// Renders a tab template in Ultimate Guitar visual format
class TabRenderer {
  /// Converts a tab template to visual string format
  static String renderTab(TabTemplate template) {
    print('\n🎸🎸🎸 STARTING TAB RENDER 🎸🎸🎸');
    print('Title: ${template.songInfo.title}');
    print('Content: ${template.content}');
    print('Number of measures: ${template.content.measures.length}');
    
    final buffer = StringBuffer();
    
    // Add title with indentation
    buffer.writeln('  [${template.songInfo.title}]');
    buffer.writeln();

    // Add tuning with indentation
    buffer.writeln('  Tuning: ${template.songInfo.tuning.join(' ')}');
    buffer.writeln();

    // Process each measure
    var currentSection = '';
    var measuresInSection = 0;
    
    for (var i = 0; i < template.content.measures.length; i++) {
      final measure = template.content.measures[i];
      print('Processing measure $i of ${template.content.measures.length}');
      
      // Add section header if needed
      final section = _getSectionForMeasure(measure.index);
      if (section != currentSection) {
        // Add clear section separator
        if (currentSection.isNotEmpty) {
          buffer.writeln();
          buffer.writeln('  ' + '-' * 40); // Add visual separator
          buffer.writeln();
        }
        currentSection = section;
        measuresInSection = 0;
        buffer.writeln('  [$section]');
        buffer.writeln();
      }
      
      // Convert measure to visual format and add indentation
      final visualMeasure = _renderMeasure(measure);
      final indentedMeasure = visualMeasure.split('\n').map((line) => '  $line').join('\n');
      buffer.write(indentedMeasure);
      
      // Add line break after measure
      buffer.writeln();
      
      // Add extra spacing every 4 measures within a section
      measuresInSection++;
      if (measuresInSection % 4 == 0) {
        buffer.writeln();
      }
    }
    
    final result = buffer.toString();
    print('Final tab length: ${result.split('\n').length} lines');
    return result;
  }

  /// Renders a single measure in visual format
  static String _renderMeasure(Measure measure) {
    print('\n🎸 Rendering measure:');
    print('📊 Measure data: $measure');
    
    // Initialize string buffers with correct string numbers (6 = low E, 1 = high e)
    final stringBuffers = {
      1: StringBuffer('e|'),  // High e
      2: StringBuffer('B|'),
      3: StringBuffer('G|'),
      4: StringBuffer('D|'),
      5: StringBuffer('A|'),
      6: StringBuffer('E|'),  // Low E
    };
    
    // Initialize with dashes
    final measureWidth = _calculateMeasureWidth(measure);
    print('📏 Measure width: $measureWidth');
    
    // Add dashes to fill the width (using em dash)
    for (var string = 1; string <= 6; string++) {
      stringBuffers[string]!.write('—' * (measureWidth - 2)); // Using em dash instead of hyphen
    }
    
    // Place notes in correct positions
    for (var tabString in measure.strings) {
      print('🎵 Processing string ${tabString.string}:');
      
      // Sort notes by position to ensure proper order
      final sortedNotes = tabString.notes.toList()
        ..sort((a, b) => a.position.compareTo(b.position));
      
      for (var note in sortedNotes) {
        // Get the correct string buffer based on the note's string number
        final buffer = stringBuffers[note.string]!;
        
        // Scale the position to fit our wider measure
        final position = _calculateVisualPosition(note.position, measureWidth);
        print('  - Note: fret ${note.fret} at position $position on string ${note.string}');
        _placeNote(buffer, note.fret, position);
      }
    }
    
    // Add measure ending bar
    for (var string = 1; string <= 6; string++) {
      stringBuffers[string]!.write('|');
    }
    
    // Combine all strings in correct order (high e to low E)
    final result = StringBuffer();
    for (var string = 1; string <= 6; string++) {
      result.writeln(stringBuffers[string]!.toString());
    }
    
    print('📝 Final rendered measure:');
    print(result.toString());
    return result.toString();
  }

  /// Places a note in the string buffer at the correct position
  static void _placeNote(StringBuffer buffer, int fret, int position) {
    final fretStr = fret.toString();
    print('  - Placing note $fretStr at position $position');
    print('  - Buffer before: ${buffer.toString()}');
    
    // Get current content
    final content = buffer.toString();
    
    // Clear the buffer
    buffer.clear();
    
    // Write the updated content
    final newContent = content.replaceRange(
      position,
      position + 1, // Replace just one character
      fretStr,
    );
    buffer.write(newContent);
    
    print('  - Buffer after: ${buffer.toString()}');
  }

  /// Calculates the width needed for a measure
  static int _calculateMeasureWidth(Measure measure) {
    // Use a width that matches Ultimate Guitar's style (about 25 characters)
    return 27; // This will give us about 22 em dashes plus string label and bars
  }

  /// Calculates the visual position for a note
  static int _calculateVisualPosition(int position, int measureWidth) {
    // Map position to 0-(measureWidth-2) range, then add 1 to get 1-(measureWidth-1)
    // This ensures the position never exceeds measureWidth-1, preventing buffer overflow
    return (position % (measureWidth - 1)) + 1;
  }

  /// Determines section name based on measure index
  static String _getSectionForMeasure(int measureIndex) {
    return 'Measure ${measureIndex + 1}';
  }

  /// Checks if tuning is standard EADGBE
  static bool _isStandardTuning(List<String> tuning) {
    // Add two spaces of indentation to each line
    const standardTuning = [
      '  E',
      '  A',
      '  D',
      '  G',
      '  B',
      '  e'
    ];
    if (tuning.length != standardTuning.length) return false;
    for (var i = 0; i < tuning.length; i++) {
      if (tuning[i] != standardTuning[i].trim()) return false;
    }
    return true;
  }
}

/// Extension methods for tab template
extension TabTemplateVisual on TabTemplate {
  /// Converts this tab template to visual format
  String toVisualTab() {
    return TabRenderer.renderTab(this);
  }
} 