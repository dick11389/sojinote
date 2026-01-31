import '../entities/bible_reference.dart';

class BibleReferenceParser {
  // Comprehensive list of Bible book names and their variations
  static final Map<String, String> _bookNames = {
    // Old Testament
    'genesis': 'Genesis',
    'gen': 'Genesis',
    'gn': 'Genesis',
    'exodus': 'Exodus',
    'exod': 'Exodus',
    'ex': 'Exodus',
    'exo': 'Exodus',
    'leviticus': 'Leviticus',
    'lev': 'Leviticus',
    'lv': 'Leviticus',
    'numbers': 'Numbers',
    'num': 'Numbers',
    'nm': 'Numbers',
    'nb': 'Numbers',
    'deuteronomy': 'Deuteronomy',
    'deut': 'Deuteronomy',
    'dt': 'Deuteronomy',
    'joshua': 'Joshua',
    'josh': 'Joshua',
    'jsh': 'Joshua',
    'judges': 'Judges',
    'judg': 'Judges',
    'jdg': 'Judges',
    'ruth': 'Ruth',
    'rth': 'Ruth',
    'ru': 'Ruth',
    '1 samuel': '1 Samuel',
    '1samuel': '1 Samuel',
    '1sam': '1 Samuel',
    '1sm': '1 Samuel',
    '1sa': '1 Samuel',
    '1s': '1 Samuel',
    'i samuel': '1 Samuel',
    'first samuel': '1 Samuel',
    '2 samuel': '2 Samuel',
    '2samuel': '2 Samuel',
    '2sam': '2 Samuel',
    '2sm': '2 Samuel',
    '2sa': '2 Samuel',
    '2s': '2 Samuel',
    'ii samuel': '2 Samuel',
    'second samuel': '2 Samuel',
    '1 kings': '1 Kings',
    '1kings': '1 Kings',
    '1kgs': '1 Kings',
    '1ki': '1 Kings',
    '1k': '1 Kings',
    'i kings': '1 Kings',
    'first kings': '1 Kings',
    '2 kings': '2 Kings',
    '2kings': '2 Kings',
    '2kgs': '2 Kings',
    '2ki': '2 Kings',
    '2k': '2 Kings',
    'ii kings': '2 Kings',
    'second kings': '2 Kings',
    '1 chronicles': '1 Chronicles',
    '1chronicles': '1 Chronicles',
    '1chron': '1 Chronicles',
    '1chr': '1 Chronicles',
    '1ch': '1 Chronicles',
    'i chronicles': '1 Chronicles',
    '2 chronicles': '2 Chronicles',
    '2chronicles': '2 Chronicles',
    '2chron': '2 Chronicles',
    '2chr': '2 Chronicles',
    '2ch': '2 Chronicles',
    'ii chronicles': '2 Chronicles',
    'ezra': 'Ezra',
    'ezr': 'Ezra',
    'nehemiah': 'Nehemiah',
    'neh': 'Nehemiah',
    'ne': 'Nehemiah',
    'esther': 'Esther',
    'esth': 'Esther',
    'es': 'Esther',
    'job': 'Job',
    'jb': 'Job',
    'psalm': 'Psalms',
    'psalms': 'Psalms',
    'ps': 'Psalms',
    'psa': 'Psalms',
    'psm': 'Psalms',
    'pss': 'Psalms',
    'proverbs': 'Proverbs',
    'prov': 'Proverbs',
    'prv': 'Proverbs',
    'pr': 'Proverbs',
    'ecclesiastes': 'Ecclesiastes',
    'eccles': 'Ecclesiastes',
    'eccle': 'Ecclesiastes',
    'ecc': 'Ecclesiastes',
    'ec': 'Ecclesiastes',
    'song of solomon': 'Song of Solomon',
    'song': 'Song of Solomon',
    'sos': 'Song of Solomon',
    'so': 'Song of Solomon',
    'isaiah': 'Isaiah',
    'isa': 'Isaiah',
    'is': 'Isaiah',
    'jeremiah': 'Jeremiah',
    'jer': 'Jeremiah',
    'jr': 'Jeremiah',
    'lamentations': 'Lamentations',
    'lam': 'Lamentations',
    'la': 'Lamentations',
    'ezekiel': 'Ezekiel',
    'ezek': 'Ezekiel',
    'eze': 'Ezekiel',
    'ezk': 'Ezekiel',
    'daniel': 'Daniel',
    'dan': 'Daniel',
    'dn': 'Daniel',
    'hosea': 'Hosea',
    'hos': 'Hosea',
    'ho': 'Hosea',
    'joel': 'Joel',
    'jol': 'Joel',
    'jl': 'Joel',
    'amos': 'Amos',
    'amo': 'Amos',
    'am': 'Amos',
    'obadiah': 'Obadiah',
    'obad': 'Obadiah',
    'ob': 'Obadiah',
    'jonah': 'Jonah',
    'jnh': 'Jonah',
    'jon': 'Jonah',
    'micah': 'Micah',
    'mic': 'Micah',
    'mc': 'Micah',
    'nahum': 'Nahum',
    'nah': 'Nahum',
    'na': 'Nahum',
    'habakkuk': 'Habakkuk',
    'hab': 'Habakkuk',
    'hb': 'Habakkuk',
    'zephaniah': 'Zephaniah',
    'zeph': 'Zephaniah',
    'zep': 'Zephaniah',
    'zp': 'Zephaniah',
    'haggai': 'Haggai',
    'hag': 'Haggai',
    'hg': 'Haggai',
    'zechariah': 'Zechariah',
    'zech': 'Zechariah',
    'zec': 'Zechariah',
    'zc': 'Zechariah',
    'malachi': 'Malachi',
    'mal': 'Malachi',
    'ml': 'Malachi',
    
    // New Testament
    'matthew': 'Matthew',
    'matt': 'Matthew',
    'mat': 'Matthew',
    'mt': 'Matthew',
    'mark': 'Mark',
    'mrk': 'Mark',
    'mar': 'Mark',
    'mk': 'Mark',
    'mr': 'Mark',
    'luke': 'Luke',
    'luk': 'Luke',
    'lk': 'Luke',
    'john': 'John',
    'jhn': 'John',
    'joh': 'John',
    'jn': 'John',
    'acts': 'Acts',
    'act': 'Acts',
    'ac': 'Acts',
    'romans': 'Romans',
    'rom': 'Romans',
    'rm': 'Romans',
    'ro': 'Romans',
    '1 corinthians': '1 Corinthians',
    '1corinthians': '1 Corinthians',
    '1cor': '1 Corinthians',
    '1co': '1 Corinthians',
    '1c': '1 Corinthians',
    'i corinthians': '1 Corinthians',
    'first corinthians': '1 Corinthians',
    '2 corinthians': '2 Corinthians',
    '2corinthians': '2 Corinthians',
    '2cor': '2 Corinthians',
    '2co': '2 Corinthians',
    '2c': '2 Corinthians',
    'ii corinthians': '2 Corinthians',
    'second corinthians': '2 Corinthians',
    'galatians': 'Galatians',
    'gal': 'Galatians',
    'ga': 'Galatians',
    'ephesians': 'Ephesians',
    'eph': 'Ephesians',
    'ephes': 'Ephesians',
    'philippians': 'Philippians',
    'phil': 'Philippians',
    'php': 'Philippians',
    'pp': 'Philippians',
    'colossians': 'Colossians',
    'col': 'Colossians',
    '1 thessalonians': '1 Thessalonians',
    '1thessalonians': '1 Thessalonians',
    '1thess': '1 Thessalonians',
    '1thes': '1 Thessalonians',
    '1th': '1 Thessalonians',
    'i thessalonians': '1 Thessalonians',
    '2 thessalonians': '2 Thessalonians',
    '2thessalonians': '2 Thessalonians',
    '2thess': '2 Thessalonians',
    '2thes': '2 Thessalonians',
    '2th': '2 Thessalonians',
    'ii thessalonians': '2 Thessalonians',
    '1 timothy': '1 Timothy',
    '1timothy': '1 Timothy',
    '1tim': '1 Timothy',
    '1ti': '1 Timothy',
    '1t': '1 Timothy',
    'i timothy': '1 Timothy',
    '2 timothy': '2 Timothy',
    '2timothy': '2 Timothy',
    '2tim': '2 Timothy',
    '2ti': '2 Timothy',
    '2t': '2 Timothy',
    'ii timothy': '2 Timothy',
    'titus': 'Titus',
    'tit': 'Titus',
    'ti': 'Titus',
    'philemon': 'Philemon',
    'philem': 'Philemon',
    'phm': 'Philemon',
    'pm': 'Philemon',
    'hebrews': 'Hebrews',
    'heb': 'Hebrews',
    'he': 'Hebrews',
    'james': 'James',
    'jas': 'James',
    'jam': 'James',
    'jm': 'James',
    '1 peter': '1 Peter',
    '1peter': '1 Peter',
    '1pet': '1 Peter',
    '1pe': '1 Peter',
    '1pt': '1 Peter',
    '1p': '1 Peter',
    'i peter': '1 Peter',
    '2 peter': '2 Peter',
    '2peter': '2 Peter',
    '2pet': '2 Peter',
    '2pe': '2 Peter',
    '2pt': '2 Peter',
    '2p': '2 Peter',
    'ii peter': '2 Peter',
    '1 john': '1 John',
    '1john': '1 John',
    '1jhn': '1 John',
    '1joh': '1 John',
    '1jn': '1 John',
    '1j': '1 John',
    'i john': '1 John',
    '2 john': '2 John',
    '2john': '2 John',
    '2jhn': '2 John',
    '2joh': '2 John',
    '2jn': '2 John',
    '2j': '2 John',
    'ii john': '2 John',
    '3 john': '3 John',
    '3john': '3 John',
    '3jhn': '3 John',
    '3joh': '3 John',
    '3jn': '3 John',
    '3j': '3 John',
    'iii john': '3 John',
    'jude': 'Jude',
    'jud': 'Jude',
    'jd': 'Jude',
    'revelation': 'Revelation',
    'revelations': 'Revelation',
    'rev': 'Revelation',
    'revel': 'Revelation',
    're': 'Revelation',
  };

  /// Regex pattern that matches Bible references
  /// Supports formats like:
  /// - John 3:16
  /// - 1 Cor 13:4-7
  /// - Gen 1:1
  /// - 2 Kings 4vs12
  /// - Mark 1:1-5
  /// 
  /// Strict enough to avoid matching "Mark said hello" or "John walked"
  static final RegExp _versePattern = RegExp(
    r'\b(?:(?:1|2|3|I|II|III|i|ii|iii|First|Second|Third|1st|2nd|3rd)\s+)?'  // Optional book number
    r'([A-Z][a-z]+(?:\s+of\s+[A-Z][a-z]+)?)'  // Book name (capitalized)
    r'\s+'  // Required space
    r'(\d+)'  // Chapter number (required)
    r'(?:\s*[:v]\s*|\s+vs?\.?\s+)'  // Separator: colon, 'v', or 'vs'
    r'(\d+)'  // Start verse (required)
    r'(?:\s*[-–—]\s*(\d+))?'  // Optional end verse with dash
    r'\b',
    caseSensitive: true,
    multiLine: true,
  );

  /// Additional pattern for chapter-only references (e.g., "1 Cor 13")
  static final RegExp _chapterOnlyPattern = RegExp(
    r'\b(?:(?:1|2|3|I|II|III|i|ii|iii|First|Second|Third|1st|2nd|3rd)\s+)?'  // Optional book number
    r'([A-Z][a-z]+(?:\s+of\s+[A-Z][a-z]+)?)'  // Book name (capitalized)
    r'\s+'  // Required space
    r'(\d+)'  // Chapter number
    r'(?:\s|[,;.]|$)',  // Must be followed by space, punctuation, or end
    caseSensitive: true,
    multiLine: true,
  );

  /// Parses a text string and returns a list of Bible references found
  static List<BibleReference> parse(String text) {
    final List<BibleReference> references = [];

    // First, try to match verse references (e.g., John 3:16)
    final verseMatches = _versePattern.allMatches(text);
    for (final match in verseMatches) {
      final fullMatch = match.group(0)!;
      final bookPart = _extractBookName(fullMatch);
      final chapterStr = match.group(2)!;
      final startVerseStr = match.group(3)!;
      final endVerseStr = match.group(4);

      // Validate that the book name is actually a Bible book
      final normalizedBook = _normalizeBookName(bookPart);
      if (normalizedBook == null) continue;

      final chapter = int.parse(chapterStr);
      final startVerse = int.parse(startVerseStr);
      final endVerse = endVerseStr != null ? int.parse(endVerseStr) : startVerse;

      references.add(BibleReference(
        book: normalizedBook,
        chapter: chapter,
        startVerse: startVerse,
        endVerse: endVerse,
        originalText: fullMatch,
      ));
    }

    // Then, try to match chapter-only references (e.g., 1 Cor 13)
    // But only if they don't overlap with verse references
    final chapterMatches = _chapterOnlyPattern.allMatches(text);
    for (final match in chapterMatches) {
      final matchStart = match.start;
      final matchEnd = match.end;

      // Skip if this overlaps with any verse reference
      final overlaps = references.any((ref) {
        final refStart = text.indexOf(ref.originalText);
        final refEnd = refStart + ref.originalText.length;
        return (matchStart >= refStart && matchStart < refEnd) ||
               (matchEnd > refStart && matchEnd <= refEnd);
      });

      if (overlaps) continue;

      final fullMatch = match.group(0)!.trim();
      final bookPart = _extractBookName(fullMatch);
      final chapterStr = match.group(2)!;

      // Validate that the book name is actually a Bible book
      final normalizedBook = _normalizeBookName(bookPart);
      if (normalizedBook == null) continue;

      final chapter = int.parse(chapterStr);

      references.add(BibleReference(
        book: normalizedBook,
        chapter: chapter,
        startVerse: null,
        endVerse: null,
        originalText: fullMatch,
      ));
    }

    return references;
  }

  /// Extracts the book name from a matched reference
  static String _extractBookName(String reference) {
    final bookMatch = RegExp(
      r'^(?:(?:1|2|3|I|II|III|i|ii|iii|First|Second|Third|1st|2nd|3rd)\s+)?([A-Z][a-z]+(?:\s+of\s+[A-Z][a-z]+)?)',
    ).firstMatch(reference);
    
    if (bookMatch == null) return '';
    
    final bookPrefix = reference.substring(0, bookMatch.end).trim();
    return bookPrefix;
  }

  /// Normalizes a book name to its canonical form
  /// Returns null if the book name is not recognized
  static String? _normalizeBookName(String bookName) {
    final normalized = bookName.toLowerCase().trim();
    return _bookNames[normalized];
  }

  /// Checks if a given string is a valid Bible book name
  static bool isValidBookName(String bookName) {
    return _normalizeBookName(bookName) != null;
  }
}
