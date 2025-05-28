import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/quiz_service.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  List<Question> _questions = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _loadQuestions().then((_) {
      if (_questions.isNotEmpty) {
        _animationController.forward();
      }
    });
  }

  Future<void> _loadQuestions() async {
    try {
      _questions = await QuizService().loadQuestions();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print("Error loading questions: $e");
    }
  }

  void _handleAnswer(int selectedIndex) {
    final currentQuestion = _questions[_currentQuestionIndex];

    setState(() {
      _isAnswered = true;
      if (selectedIndex == currentQuestion.correctAnswerIndex) {
        _score++;
      }
    });

    _animationController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_currentQuestionIndex < _questions.length - 1) {
          setState(() {
            _currentQuestionIndex++;
            _isAnswered = false;
            _animationController.reset();
            _animationController.forward();
          });
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ResultScreen(
                    score: _score,
                    totalQuestions: _questions.length,
                  ),
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final progressValue = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Question ${_currentQuestionIndex + 1}/${_questions.length}",
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E3192), Color(0xFF1B1464)],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: progressValue,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E3192)),
            minHeight: 8,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      0,
                      100 *
                          (1 - _animationController.value) *
                          (_animationController.status ==
                                  AnimationStatus.forward
                              ? 1
                              : 0),
                    ),
                    child: Opacity(
                      opacity: _animationController.value,
                      child: child,
                    ),
                  );
                },
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          currentQuestion.question,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'OpenSans',
                          ),
                        ),
                        const SizedBox(height: 30),
                        ...currentQuestion.options.asMap().entries.map((entry) {
                          final index = entry.key;
                          final option = entry.value;
                          final isCorrect =
                              index == currentQuestion.correctAnswerIndex;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color:
                                    _isAnswered
                                        ? (isCorrect
                                            ? Colors.green.withOpacity(0.2)
                                            : Colors.red.withOpacity(0.2))
                                        : Colors.grey[100],
                                border: Border.all(
                                  color:
                                      _isAnswered
                                          ? (isCorrect
                                              ? Colors.green
                                              : Colors.red)
                                          : Colors.grey[300]!,
                                  width: 2,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                title: Text(
                                  option,
                                  style: TextStyle(
                                    color:
                                        _isAnswered
                                            ? (isCorrect
                                                ? Colors.green
                                                : Colors.red)
                                            : Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                trailing:
                                    _isAnswered && isCorrect
                                        ? const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                        )
                                        : null,
                                onTap:
                                    _isAnswered
                                        ? null
                                        : () => _handleAnswer(index),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Score: $_score",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3192),
                  ),
                ),
                Chip(
                  backgroundColor: Colors.amber.withOpacity(0.2),
                  label: Text(
                    "${(_score / _questions.length * 100).toStringAsFixed(1)}%",
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
