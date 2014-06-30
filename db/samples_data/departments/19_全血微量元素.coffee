# 科室属性结构

# 科室编号
_id : "240000000000000000000000"
# 科室显示顺序
order            : 20
# 科室名称
name             : '全血微量元素'
# 科室类型（临床类型或者实验室类型）[clinic|laboratory]
category             : 'laboratory'
# 图片所放位置
image_path:        './quanxueweiliangyuansu.svg'
# 门牌号
door_number: ['214']
# 房间名称
door_name: '检验室'
# 项目
items         : [
  {
    _id : "240000000000000000000004"
    name : '锌'
    abbr : 'Zn'
    lt   : "76.5"
    ut   : "150"
    unit : "μmol/L"
    category: 'number'
    conditions_string: """
      >> 偏低
      
      >> 偏高
    """
  }
  {
    _id : "240000000000000000000007"
    name : '铁'
    abbr : 'Fe'
    lt   : '7.52'
    ut   : '11.82'
    unit : "mmol/L"
    category: 'number'
    conditions_string: """
      >> 偏低
      
      >> 偏高
    """
  }
  {
    _id : "240000000000000000000003"
    name : '钙'
    abbr : 'Ca'
    lt   : "1.45"
    ut   : "2.10"
    unit : "mmol/L"
    category: 'number'
    conditions_string: """
      >> 偏低
      
      >> 偏高
    """
  }
  {
    _id : "240000000000000000000002"
    name : '铜'
    abbr : 'Cu'
    lt   : '11.8'
    ut   : '39.3'
    unit : "μmol/L"
    category: 'number'
    conditions_string: """
      >> 偏低
      
      >> 偏高
    """
  }
  {
    _id : "240000000000000000000001"
    name : '镁'
    abbr : 'Mg'
    lt   : "1.12"
    ut   : "2.06"
    unit : "mmol/L"
    category: 'number'
    conditions_string: """
      >> 偏低
      
      >> 偏高
    """
  }
  #{
  #  _id : "240000000000000000000006"
  #  name : '铬'
  #  abbr : 'Cr'
  #  lt   : '0.12'
  #  ut   : '2.10'
  #  unit : "μg/L"
  #  category: 'number'
  #  conditions_string: """
  #    >> 偏低
  #    
  #    >> 偏高
  #  """
  #}
  {
    _id : "240000000000000000000005"
    name : '铅'
    abbr : 'Pb'
    lt   : '0.00'
    ut   : '200.00'
    unit : "μg/L"
    category: 'number'
    conditions_string: """
      >> 偏低
      
      >> 偏高
    """
  }
]
