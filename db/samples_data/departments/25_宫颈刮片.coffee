# 科室属性结构

# 科室编号
_id : "320000000000000000000000"
# 科室显示顺序
order            : 26
# 科室名称
name             : '宫颈刮片'
# 科室类型（临床类型或者实验室类型）[clinic|laboratory]
category             : 'laboratory'

door_number: ['212']

door_name: '宫颈刮片'

# 图片所放位置
image_path:        './tct.jpg'
# 项目
items         : [
  {
    _id : "320000000000000000000001"
    name : '宫颈刮片'
    unit : "级"
    sex : '女'
    category: 'text'
    conditions_string: """
    >> value is 'Ⅱ'->宫颈刮片巴氏染色Ⅱ级

    >> value is 'Ⅲ'->宫颈刮片巴氏染色Ⅲ级
    """
  }
]

