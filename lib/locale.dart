import 'package:flutter/material.dart';

enum LanguageOverride {
  none,
  english,
  arabic,
  russian,
  hungarian,
}

const Map<LanguageOverride, String> languageNames = {
  LanguageOverride.none: "System Default",
  LanguageOverride.english: "English",
  LanguageOverride.arabic: "العربية",
  LanguageOverride.russian: "Русский",
  LanguageOverride.hungarian: "Magyar",
};

const Map<LanguageOverride, Locale?> supportedLanguages = {
  LanguageOverride.none: null,
  LanguageOverride.english: Locale("en"),
  LanguageOverride.arabic: Locale("ar"),
  LanguageOverride.russian: Locale("ru"),
  LanguageOverride.hungarian: Locale("hu"),
};
