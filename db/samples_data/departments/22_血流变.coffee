# 科室属性结构

# 科室编号
_id : "210000000000000000000000"
# 科室显示顺序
order            : 23
# 科室名称
name             : '血流变'
# 科室类型（临床类型或者实验室类型）[clinic|laboratory]
category             : 'laboratory'
# 图片所放位置
image_path:        './xueliubian.svg'
# 门牌号
door_number: ['214']
# 房间名称
door_name: '血流变室'
# 项目
items         : [
  {
    _id : "210000000000000000000001"
    name : '低切（10）'
    abbr : ''
    lt   : "if sex is '男' then 6.8 else 6.5"
    ut   : "if sex is '男' then 9.58 else 9.25"
    unit : 'mPa.s'
    category: 'number'
    conditions_string: """
    >> 偏低
    
    >> 偏高
    """
  }
  {
    _id : "210000000000000000000002"
    name : '中切（60）'
    abbr : ''
    lt   : "if sex is '男' then 4.15 else 4.35"
    ut   : "if sex is '男' then 5.57 else 5.45"
    unit : 'mPa.s'
    category: 'number'
    conditions_string:  """
    >> 偏低
    
    >> 偏高
    """
  }
  {
    _id : "210000000000000000000003"
    name : '高切（150）'
    abbr : ''
    lt   : "if sex is '男' then 3.73 else 3.65"
    ut   : "if sex is '男' then 4.60 else 4.40"
    unit : 'mPa.s'
    category: 'number'
    conditions_string:  """
    >> 偏低
    
    >> 偏高
    """
  }
  {
    _id : "210000000000000000000004"
    name : '血浆粘度'
    abbr : ''
    lt   : "1.05"
    ut   : "1.51"
    unit : 'mPa.s'
    category: 'number'
    conditions_string:  """
    >> 偏低
    
    >> 偏高
    """
  }
  {
    _id : "210000000000000000000005"
    name : '压积'
    abbr : ''
    lt   : "if sex is '男' then 43.0 else 36.0"
    ut   : "if sex is '男' then 48.0 else 44.0"
    unit : ''
    category: 'number'
    conditions_string: """
    >> 偏低
    
    >> 偏高
    """
  }
  {
    _id : "210000000000000000000006"
    name : '还原粘度（低切）'
    abbr : ''
    lt   : "if sex is '男' then 11.02 else 11.34"
    ut   : "if sex is '男' then 19.84 else 22.78"
    unit : ''
    category: 'number'
    conditions_string: """
    >> 偏低
    
    >> 偏高
    """
  }
  {
    _id : "210000000000000000000007"
    name : '还原粘度（中切）'
    abbr : ''
    lt   : "if sex is '男' then 6.25 else 6.46"
    ut   : "if sex is '男' then 10.51 else 12.22"
    unit : ''
    category: 'number'
    conditions_string: """
    >> 偏低
    
    >> 偏高
    """
  }
  {
    _id : "210000000000000000000008"
    name : '还原粘度（高切）'
    abbr : ''
    lt   : "if sex is '男' then 4.63 else 4.86"
    ut   : "if sex is '男' then 8.26 else 9.31"
    unit : ''
    category: 'number'
    conditions_string: """
    >> 偏低
    
    >> 偏高
    """
  }
  {
    _id : "210000000000000000000009"
    name : '红细胞聚集指数'
    abbr : ''
    lt   : "1.48"
    ut   : "if sex is '男' then 2.57 else 2.53"
    unit : ''
    category: 'number'
    conditions_string: """
    >> 偏低
    
    >> 偏高
    """
  }
  {
    _id : "210000000000000000000010"
    name : '红细胞刚性指数'
    abbr : ''
    lt   : "if sex is '男' then 3.06 else 3.22"
    ut   : "if sex is '男' then 7.86 else 8.86"
    unit : ''
    category: 'number'
    conditions_string: """
    >> 偏低
    
    >> 偏高
    """
  }
  {
    _id : "210000000000000000000011"
    name : '红细胞变形指数'
    abbr : ''
    lt   : "if sex is '男' then 0.63 else 0.68"
    ut   : "if sex is '男' then 1.04 else 1.21"
    unit : ''
    category: 'number'
    conditions_string: """
    >> 偏低
    
    >> 偏高
    """
  }
  {
    _id : "210000000000000000000012"
    name : '红细胞电泳指数'
    abbr : ''
    lt   : "if sex is '男' then 3.08 else 3.36"
    ut   : "if sex is '男' then 5.97 else 7.04"
    unit : ''
    category: 'number'
    conditions_string: """
    >> 偏低
    
    >> 偏高
    """
  }
]

