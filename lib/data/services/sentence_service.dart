import 'dart:convert';

import 'package:first_flutter/data/models/sentence.dart';
import 'package:http/http.dart' as http;

abstract class ISentenceService {
  Future<Sentence> getNext();

  Future<Sentence> createSentence(String text);
}

class SentenceService implements ISentenceService {
  var count = 0;
  @override
  Future<Sentence> getNext() async {
    count++;
    var response = await http.get(
      Uri.parse('https://dummyjson.com/quotes/$count'),
    );

    if (response.statusCode == 200) {
      return Sentence.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to load album');
    }
  }

  @override
  Future<Sentence> createSentence(String sentenceText) async {
    var response = await http.post(
      Uri.parse('https://dummyjson.com/quotes/add'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'quote': sentenceText}),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create album.');
    }
    return Sentence.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
