(when (require 'plantuml-mode nil t)
  ;; あなたのplantuml.jarファイルの絶対パスをかく
  (setq plantuml-jar-path "/usr/local/var/homebrew/linked/plantuml/libexec/plantuml.jar")
  ;; javaにオプションを渡したい場合はここにかく
  ;; (setq plantuml-java-options "")
  ;; plantumlのプレビューをsvg, pngにしたい場合はここをコメントイン
  ;; デフォルトでアスキーアート
  ;;(setq plantuml-output-type "svg")
  ;; 日本語を含むUMLを書く場合はUTF-8を指定
  ;; (setq plantuml-options "-charset UTF-8")
  )
