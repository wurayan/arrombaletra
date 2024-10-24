import 'utils.dart';

void main() {
  List<String> x = "paliçou".split("");
  List<String> res = generateCombinations(
    x,
    6,
    "l",
    // startWord: "polpa",
    endWord: "lupulo",
  );

  res.removeWhere((item) => item[0] == "l" && !Utils().isVowel(item[1]));
  res.removeWhere((item) => item.endsWith("p") || item.contains("plç") || item.contains("plp") || item.contains("lpl") ||item.contains("lpç") );
  res.forEach(print);
  print(res.length);

}

List<String> generateCombinations(
    List<String> iterable, int length, String required,
    {bool pangram = false, String? startWord, String? endWord}) {
  assert(_validWord(iterable, startWord),
      "Starting word is not valid because it contains characters outside from iterable");
  assert(_validWord(iterable, endWord),
      "End word is not valid because it contains characters outside from iterable");
  if ((startWord ?? "").length > length) startWord = null;
  if ((endWord ?? "").length > length) endWord = null;
  List<String> words = [];
  List<dynamic> res = _combinations(
    iterable,
    length,
    required,
    pangram,
  ).toList();
  res.forEach((element) => words.add((element as List<String>).join()));
  _replaceCedilha(words);
  words.sort();
  _recoverCedilha(words);
  if (startWord != null && words.indexOf(startWord) >= 0) {
    words.removeRange(0, words.indexOf(startWord));
  }
  if (endWord != null && words.indexOf(endWord) >= 0) {
    words.removeRange(words.indexOf(endWord), words.length);
  }

  return words;
}

_replaceCedilha(List<String> words) {
  for (var i = 0; i < words.length; i++) {
    String word = words[i];
    if (word.contains("ç")) {
      words[i] = word.replaceAll("ç", "c");
    }
  }
}

_recoverCedilha(List<String> words) {
  for (var i = 0; i < words.length; i++) {
    if (words[i].contains("c")) words[i] = words[i].replaceAll("c", "ç");
  }
}

_validWord(List<String> iterable, String? word) => word == null
    ? true
    : word.split("").every((element) => iterable.contains(element));

Iterable<List<String>> _combinations<T>(
    List<String> iterable, int length, String required, bool pangram) sync* {
  assert(
      iterable.contains(required), "$required (required) is not in $iterable");
  assert(pangram ? length >= iterable.length : true,
      "The length must be equal or bigger than quantity of chars to be a Pangram");
// Cria uma lista de índices, todos iniciando em zero
  List<int> indexes = List<int>.filled(length, 0);

// Função auxiliar para criar a combinação atual a partir dos índices
  List<String> currentCombination() =>
      List.generate(length, (index) => iterable[indexes[index]]);

  yield currentCombination();

  while (true) {
    int i = length - 1;

    while (i >= 0 && indexes[i] == iterable.length - 1) i--;

    if (i < 0) return;

    indexes[i]++;

    for (int j = i + 1; j < length; j++) {
      indexes[j] = 0;
    }

    if (pangram) {
      if (_checkValidity(currentCombination(), required) &&
          _isPangram(iterable, currentCombination())) {
        yield currentCombination();
      }
    } else {
      if (_checkValidity(currentCombination(), required)) {
        yield currentCombination();
      }
    }
  }
}

_checkValidity(List<String> combination, String required) {
  // print(combination);
  // print(_vowelless(combination));
  return combination.contains(required) &&
      _checkM(combination) &&
      _checkConsecutiveConsonant(combination) &&
      _vowelless(combination) &&
      _checkTrouple(combination) &&
      _endsWithdoubleConsonant(combination) &&
      _startsEndsCedilha(combination);
}

_checkM(List<String> combination) {
  if (!combination.contains("m")) return true;
  List validSequence = ["a", "e", "i", "o", "u", "p", "b"];
  for (int i = 0; i < combination.length - 1; i++) {
    String letter = combination[i];
    String sequence = combination[i + 1];
    if (letter == "m") return validSequence.contains(sequence);
  }
  return false;
}

bool _checkConsecutiveConsonant(List<String> combination) {
  if (combination.length < 5) return true;
  for (int i = 0; i <= combination.length - 5; i++) {
    List<String> segment = combination.sublist(i, i + 5);
    if (segment.every((char) => !Utils().isVowel(char))) return false;
    if (Utils().isRorS(combination[i]) &&
        Utils().isRorS(combination[i + 1]) &&
        !Utils().isVowel(combination[i + 2])) return false;
  }
  return true;
}

bool _isPangram(List<String> necessary, List<String> combination) =>
    necessary.toSet().every((item) => combination.contains(item));

bool _vowelless(List<String> combination) =>
    !(combination.every((element) => !Utils().isVowel(element)));

bool _checkTrouple(List<String> combination) {
  for (var i = 0; i < combination.length - 2; i++) {
    String first = combination[i];
    String second = combination[i + 1];
    String third = combination[i + 2];
    if (first == second && first == third) {
      return false;
    }
    if (first == second && !Utils().isRorS(first)) return false;
    if (second == third && !Utils().isRorS(second)) return false;
    if(!_checkCedilha(first, second)||!_checkCedilha(second, third)) return false;
  }
  return true;
}

bool _endsWithdoubleConsonant(List<String> combination) => !(combination
    .getRange(combination.length - 2, combination.length)
    .every((char) => !Utils().isVowel(char)));

bool _checkCedilha(String char1, String char2) {
  if (char1 != "ç") return true;
  List<String> validSequence = ["a", "o", "u"];
  if (!validSequence.contains(char2)) return false;
  return true;
}

bool _startsEndsCedilha(List<String> combination) =>
    combination.first == "ç" || combination.last == "ç" ? false : true;
// bool _checkCedilha(List<String> combination) {
//   // return true;
//   if (!combination.contains("ç")) return true;
//   if (combination.last == "ç" || combination.first == "ç") return false;
//   int sequence = combination.indexOf("ç") + 1;
//   List validSequence = ["a", "o", "u"];
//   if (!validSequence.contains(combination[sequence])) return false;
//   return true;
// }
