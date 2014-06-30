# 科室属性结构

# 科室编号
_id : "340000000000000000000000"
# 科室显示顺序
order            : 19
# 科室名称
name             : '便潜血'
# 科室类型（临床类型或者实验室类型）[clinic|laboratory]
category             : 'laboratory'
# 图片所放位置
image_path:        './bianyinxue.svg'
# 项目
items         : [
  {
    # 项目编号
    _id : "340000000000000000000001"
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
