module LotteriesHelper
  def get_realityname(realiry_int)
    case realiry_int
    when 1
      "★１"
    when 2
      "★２"
    when 3
      "★３"
    when 4
      "★４"
    when 5
      "★５"
    when 6
      "★６"
    when 7
      "★７"
    when 8
      "★８"
    when 9
      "★９"

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
    end
  end
end
