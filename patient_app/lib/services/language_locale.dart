class LanguageLocale {

  static String getLocale(String language) {

    switch(language) {

      case "Hindi":
        return "hi_IN";

      case "Marathi":
        return "mr_IN";

      case "Telugu":
        return "te_IN";

      default:
        return "en_IN";
    }
  }
}