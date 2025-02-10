module LotteriesHelper
  def get_realityname_list()
    return (0..20).to_a + (100..107).to_a + (200..205).to_a + (300..311).to_a
  end
  def get_realityname(realiry_int)
    case realiry_int
      when 0..20
        "★" + realiry_int.to_s

      when 100
        "コモン"
      when 101
        "アンコモン"
      when 102
        "レア"
      when 103
        "スーパーレア"
      when 104
        "ウルトラレア"
      when 105
        "ユニーク"
      when 106
        "エピック"
      when 107
        "ミシック"
      
      when 200
        "C"
      when 201
        "UC"
      when 202
        "R"
      when 203
        "SR"
      when 204
        "SSR"
      when 205
        "UR"

      when 300
        "♠"
      when 301
        "♦"
      when 302
        "♥"
      when 303
        "♣"
      when 304
        "⚔"
      when 305
        "🏆"
      when 306
        "〇"
      when 307
        "◎"
      when 308
        "△"
      when 309
        "▽"
      when 310
        "□"
      when 311
        "◇"
      
    end
  end
end
