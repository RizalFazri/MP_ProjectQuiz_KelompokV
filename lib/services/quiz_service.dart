import 'package:flutter/services.dart';
import 'dart:convert';
import '../models/question.dart';

class QuizService {
  Future<List<Question>> loadQuestions() async {
    await Future.delayed(Duration(seconds: 1));

    try {
      final String response = await rootBundle.loadString(
        'assets/questions.json',
      );
      final List<dynamic> data = await json.decode(response);
      return data.map((question) => Question.fromJson(question)).toList();
    } catch (e) {
      throw Exception('Gagal memuat pertanyaan: $e');
    }
  }
}
