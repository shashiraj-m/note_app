enum NoteType { note, grocery, vegetable }

NoteType noteTypeFromString(String type) {
  switch (type.toLowerCase()) {
    case 'grocery':
      return NoteType.grocery;
    case 'vegetable':
      return NoteType.vegetable;
    default:
      return NoteType.note;
  }
}

String noteTypeToString(NoteType type) {
  switch (type) {
    case NoteType.grocery:
      return 'grocery';
    case NoteType.vegetable:
      return 'vegetable';
    default:
      return 'note';
  }
}
