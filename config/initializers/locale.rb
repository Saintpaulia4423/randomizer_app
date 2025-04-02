# 訳文指定
I18n.load_path += Dir[Rails.root.join("lib", "locale", "*.{rb,yml}")]

# アプリケーションで利用できるロケール
I18n.available_locales = :ja

# ロケールのデフォルト指定
I18n.default_locale = :ja
