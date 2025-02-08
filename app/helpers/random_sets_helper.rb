module RandomSetsHelper
  # data要素の表示用
  def get_Infomaion_conversion(string)
    case string
      # type
      when "mix"
        "通常-独立"
      when "mix-tip"
        "全ての抽選において、他の抽選結果が影響されません。"
      when "box"
        "ボックスガチャ-当選排除"
      when "box-tip"
        "ボックス容量が設定されており、抽選されるレアリティ・対象が固定されています。"

      when "pre"
        "事前選出"
      when "pre-tip"
        "当該レアリティが抽選された後、ピックアップ対象かそれ以外かの抽選を先に行います。"
      when "percent-ave"
        "単純当選率上昇-等分"
      when "当該レアリティが抽選された後、均等の抽選率に対してピックアップ対象の抽選率を決定します。<br>ピックアップ対象が複数の場合、確率が等分されて反映されます。"
      when "percent-fix"
        "単純当選率上昇-固定"
    end
  end
end
