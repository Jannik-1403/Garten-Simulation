require 'json'

file_path = 'Garten_Simulation/Localizable.xcstrings'
data = JSON.parse(File.read(file_path))

key = 'settings.health.instruction'

translations = {
  "de" => "Profil > Datenschutz > Apps > Grovy, um alles zu aktivieren.",
  "en" => "Profile > Privacy > Apps > Grovy to enable everything.",
  "nl" => "Profiel > Privacy > Apps > Grovy om alles in te schakelen.",
  "fr" => "Profil > Confidentialité > Apps > Grovy pour tout activer.",
  "it" => "Profilo > Privacy > App > Grovy per attivare tutto.",
  "ja" => "プロフィール > プライバシー > アプリ > Grovy ですべてを有効にする。",
  "ko" => "프로필 > 개인정보 보호 > 앱 > Grovy 에서 모두 활성화하세요.",
  "pl" => "Profil > Prywatność > Aplikacje > Grovy, aby włączyć wszystko.",
  "pt" => "Perfil > Privacidade > Apps > Grovy para ativar tudo.",
  "es" => "Perfil > Privacidad > Apps > Grovy para activar todo.",
  "tr" => "Profil > Gizlilik > Uygulamalar > Grovy ile her şeyi etkinleştirin."
}

data["strings"][key] = {
  "extractionState" => "manual",
  "localizations" => {}
}

translations.each do |lang, text|
  data["strings"][key]["localizations"][lang] = {
    "stringUnit" => {
      "state" => "translated",
      "value" => text
    }
  }
end

File.write(file_path, JSON.pretty_generate(data))
puts "Added translation for #{key}"
