class MCQ {
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  final String explanation;

  MCQ({
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
  });

  factory MCQ.fromJson(Map<String, dynamic> json) {
    return MCQ(
      questionText: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['answer'] ?? '',
      explanation: json['explanation'] ?? '',
    );
  }
}
