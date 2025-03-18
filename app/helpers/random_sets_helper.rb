module RandomSetsHelper
  # data要素の表示用
  def get_infomation_conversion(string)
    case string
      # type
      when "mix"
        "通常-独立"
      when "mix-tip"
        "個数の影響を無視します。個数の影響を受けません。"
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
      when "percent-ave-tip"
        "当該レアリティが抽選された後、均等の抽選率に対してピックアップ対象の抽選率を決定します。ピックアップ対象が複数の場合、確率が等分されて反映されます。"
      when "percent-fix"
        "単純当選率上昇-固定"
    end
  end
  def chk_parameter(set)
    if set.pick_type.present? \
        && set&.rate != [] \
        && set&.pickup_rate != []
      true
    else
      false
    end
  end
  def get_list_parameter(random_set)
    case random_set
      when "reality_list"
        {
          "list" => "reality",
          "list_icon" => "bi-eyedropper",
          "list_name" => "レアリティ抽選率",
          "quantity" => "%",
          "tooltip_message" => "設定されていないレアリティは余ってる確率を等分します。",
          "target_list" => @random_set.rate,
          "turbo_name" => "pickList",
          "min_value" => false,
          "new_path" => new_list_path(id: @random_set, target_list: "reality_list"),
          "create_path" => create_list_path(id: @random_set, target_list: "reality_list"),
          "edit_path" => edit_list_path(id: @random_set, target_list: "reality_list"),
          "update_path" => update_list_path(id: @random_set, target_list: "reality_list"),
          "destroy_path" => destroy_list_path(id: @random_set, target_list: "reality_list")
        }
      when "pickup_list"
        {
          "list" => "pickup",
          "list_icon" => "bi-star-fill",
          "list_name" => "ピックアップ確率",
          "quantity" => "%",
          "tooltip_message" => "ピックアップ判定において利用されます。挙動については「ピックアップ抽選方式」を確認してください。",
          "target_list" => @random_set.pickup_rate,
          "turbo_name" => "pickupList",
          "min_value" => false,
          "new_path" => new_list_path(id: @random_set, target_list: "pickup_list"),
          "create_path" => create_list_path(id: @random_set, target_list: "pickup_list"),
          "edit_path" => edit_list_path(id: @random_set, target_list: "pickup_list"),
          "update_path" => update_list_path(id: @random_set, target_list: "pickup_list"),
          "destroy_path" => destroy_list_path(id: @random_set, target_list: "pickup_list")
        }
      when "value_list"
        {
          "list" => "value",
          "list_icon" => "bi-briefcase-fill",
          "list_name" => "レアリティ別個数",
          "quantity" => "個",
          "tooltip_message" => "レアリティ事態の抽選個数の制限です。",
          "target_list" => @random_set.value_list,
          "turbo_name" => "valueList",
          "min_value" => true,
          "new_path" => new_list_path(id: @random_set, target_list: "value_list"),
          "create_path" => create_list_path(id: @random_set, target_list: "value_list"),
          "edit_path" => edit_list_path(id: @random_set, target_list: "value_list"),
          "update_path" => update_list_path(id: @random_set, target_list: "value_list"),
          "destroy_path" => destroy_list_path(id: @random_set, target_list: "value_list")
        }
    end
  end
  def list_edit_action
    ["edit", "update", "create_list", "update_list", "destroy_list"]
  end
end
