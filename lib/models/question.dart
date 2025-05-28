class Question {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;

  Question({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    if (json['correctAnswerIndex'] >= (json['options'] as List).length) {
      throw Exception('Index jawaban tidak valid');
    }

    return Question(
      question: json['question'] as String,
      options: (json['options'] as List).map((e) => e.toString()).toList(),
      correctAnswerIndex: json['correctAnswerIndex'] as int,
    );
  }
}
