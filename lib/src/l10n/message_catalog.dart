import 'app_language.dart';
export 'app_language.dart';
import 'message_key.dart';
export 'message_key.dart';
part 'messages/zh_1.dart';
part 'messages/zh_2.dart';
part 'messages/zh_3.dart';
part 'messages/zh_4.dart';
part 'messages/zh_5.dart';
part 'messages/zh_6.dart';
part 'messages/en_1.dart';
part 'messages/en_2.dart';
part 'messages/en_3.dart';
part 'messages/en_4.dart';
part 'messages/en_5.dart';
part 'messages/en_6.dart';
part 'messages/zh_hant_1.dart';
part 'messages/zh_hant_2.dart';
part 'messages/zh_hant_3.dart';
part 'messages/zh_hant_4.dart';
part 'messages/ja_1.dart';
part 'messages/ja_2.dart';
part 'messages/ja_3.dart';
part 'messages/ja_4.dart';
part 'messages/ko_1.dart';
part 'messages/ko_2.dart';
part 'messages/ko_3.dart';
part 'messages/ko_4.dart';
part 'messages/de_1.dart';
part 'messages/de_2.dart';
part 'messages/de_3.dart';
part 'messages/de_4.dart';
part 'messages/fr_1.dart';
part 'messages/fr_2.dart';
part 'messages/fr_3.dart';
part 'messages/fr_4.dart';
part 'messages/es_1.dart';
part 'messages/es_2.dart';
part 'messages/es_3.dart';
part 'messages/es_4.dart';
part 'messages/pt_br_1.dart';
part 'messages/pt_br_2.dart';
part 'messages/pt_br_3.dart';
part 'messages/pt_br_4.dart';
part 'messages/it_1.dart';
part 'messages/it_2.dart';
part 'messages/it_3.dart';
part 'messages/it_4.dart';
part 'messages/ru_1.dart';
part 'messages/ru_2.dart';
part 'messages/ru_3.dart';
part 'messages/ru_4.dart';
part 'messages/tr_1.dart';
part 'messages/tr_2.dart';
part 'messages/tr_3.dart';
part 'messages/tr_4.dart';
part 'messages/pl_1.dart';
part 'messages/pl_2.dart';
part 'messages/pl_3.dart';
part 'messages/pl_4.dart';
part 'messages/id_1.dart';
part 'messages/id_2.dart';
part 'messages/id_3.dart';
part 'messages/id_4.dart';

const zhMessages = <AppMessage, String>{
  ..._zh1,
  ..._zh2,
  ..._zh3,
  ..._zh4,
  ..._zh5,
  ..._zh6,
};
const enMessages = <AppMessage, String>{
  ..._en1,
  ..._en2,
  ..._en3,
  ..._en4,
  ..._en5,
  ..._en6,
};

final supportedLanguageCodes = List<String>.unmodifiable(
  appLanguages.map((l) => l.tag),
);
const messageCatalogs = <String, Map<AppMessage, String>>{
  'en': enMessages,
  'zh-Hans': zhMessages,
  'zh-Hant': zhHantMessages,
  'ja': jaMessages,
  'ko': koMessages,
  'de': deMessages,
  'fr': frMessages,
  'es': esMessages,
  'pt-BR': ptBRMessages,
  'it': itMessages,
  'ru': ruMessages,
  'tr': trMessages,
  'pl': plMessages,
  'id': idMessages,
};
final _messageParameters = RegExp(r'\{(p\d+)\}');

String localizedMessage(
  String languageCode,
  AppMessage key, [
  Map<String, Object?> arguments = const {},
]) {
  final tag = normalizeLanguageTag(languageCode);
  final catalog = messageCatalogs[tag] ?? enMessages;
  final template = catalog[key] ?? enMessages[key];
  if (template == null) {
    throw StateError('Missing translation: ${key.name}');
  }
  if (!template.contains('{p')) return template;
  return template.replaceAllMapped(_messageParameters, (match) {
    final name = match[1]!;
    if (!arguments.containsKey(name)) {
      throw ArgumentError('Missing $name for ${key.name}');
    }
    return '${arguments[name]}';
  });
}

/// Compatibility for widgets whose public API still accepts the language flag.
String messageForLanguage(
  Object language,
  AppMessage key, [
  Map<String, Object?> arguments = const {},
]) => localizedMessage(languageTagFrom(language), key, arguments);

/// Typed, localized diagnostics retain StateError compatibility for renderers.
class LocalizedMessageError extends StateError {
  LocalizedMessageError(this.key, [this.arguments = const {}])
    : super(localizedMessage('en', key, arguments));
  final AppMessage key;
  final Map<String, Object?> arguments;
  String localize(String code) => localizedMessage(code, key, arguments);
}

const zhHantMessages = <AppMessage, String>{
  ..._zhHant1,
  ..._zhHant2,
  ..._zhHant3,
  ..._zhHant4,
};
const jaMessages = <AppMessage, String>{..._ja1, ..._ja2, ..._ja3, ..._ja4};
const koMessages = <AppMessage, String>{..._ko1, ..._ko2, ..._ko3, ..._ko4};
const deMessages = <AppMessage, String>{..._de1, ..._de2, ..._de3, ..._de4};
const frMessages = <AppMessage, String>{..._fr1, ..._fr2, ..._fr3, ..._fr4};
const esMessages = <AppMessage, String>{..._es1, ..._es2, ..._es3, ..._es4};
const ptBRMessages = <AppMessage, String>{
  ..._ptBR1,
  ..._ptBR2,
  ..._ptBR3,
  ..._ptBR4,
};
const itMessages = <AppMessage, String>{..._it1, ..._it2, ..._it3, ..._it4};
const ruMessages = <AppMessage, String>{..._ru1, ..._ru2, ..._ru3, ..._ru4};
const trMessages = <AppMessage, String>{..._tr1, ..._tr2, ..._tr3, ..._tr4};
const plMessages = <AppMessage, String>{..._pl1, ..._pl2, ..._pl3, ..._pl4};
const idMessages = <AppMessage, String>{..._id1, ..._id2, ..._id3, ..._id4};
