# 科室属性结构

# 科室编号
_id : "3400000000000000bbbbaaaa"
# 科室显示顺序
order            : 19
# 科室名称
name             : '便常规'
# 科室类型（临床类型或者实验室类型）[clinic|laboratory]
category             : 'laboratory'
# 图片所放位置
image_path:        './bianyinxue.svg'
# 项目
items         : [
  {
    # 项目编号
    _id : "34000000000000000000aaa6"
    # 项目名称
    name : '颜色'
    abbr : 'OB'
    # 类型
    category: 'text'
    # 小结与建议
    conditions_string: """
    """
  }
  {
    # 项目编号
    _id : "34000000000000000000aaa5"
    # 项目名称
    name : '性状'
    # 类型
    category: 'text'
    # 小结与建议
    conditions_string: """
    """
  }
  {
    # 项目编号
    _id : "34000000000000000000aaa4"
    # 项目名称
    name : '白细胞'
    abbr : 'WBC'
    default:'阴性'
    # 类型
    category: 'text'
    # 小结与建议
    conditions_string: """
    >> 弱阳性
    >> 阳性
    >> {白细胞阳性}++++
    >> {白细胞阳性}+++
    >> {白细胞阳性}++
    >> {白细胞阳性}+
    >> {白细胞弱阳性}+-
    """
  }
  {
    # 项目编号
    _id : "34000000000000000000aaa3"
    # 项目名称
    name : '红细胞'
    abbr : 'RBC'
    default:'阴性'
    # 类型
    category: 'text'
    # 小结与建议
    conditions_string: """
    >> 弱阳性
    >> 阳性
    >> {红细胞阳性}++++
    >> {红细胞阳性}+++
    >> {红细胞阳性}++
    >> {红细胞阳性}+
    >> {红细胞弱阳性}+-
    """
  }
  {
    # 项目编号
    _id : "34000000000000000000aaa2"
    # 项目名称
    name : '虫卵'
    default:'阴性'
    # 类型
    category: 'text'
    # 小结与建议
    conditions_string: """
    >> 弱阳性
    >> 阳性
    >> {虫卵阳性}++++
    >> {虫卵阳性}+++
    >> {虫卵阳性}++
    >> {虫卵阳性}+
    >> {虫卵弱阳性}+-
    """
  }
  {
    # 项目编号
    _id : "34000000000000000000aaa1"
    # 项目名称
    name : '便潜血'
    abbr : 'OB'
    default:'阴性'
    # 类型
    category: 'text'
    # 小结与建议
    conditions_string: """
    >> 弱阳性
    >> 阳性
    >> {便潜血阳性}++++
    >> {便潜血阳性}+++
    >> {便潜血阳性}++
    >> {便潜血阳性}+
    >> {便潜血弱阳性}+-
    """
  }
]
