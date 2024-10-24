class Utils {
  final List _vowels = ["a", "e", "i", "o", "u", "ã"];

  isVowel(String char) => _vowels.contains(char.toLowerCase());

  isRorS(String char) => char.toLowerCase() == "r" || char.toLowerCase() == "s";
}
