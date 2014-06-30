# 科室属性结构

# 科室编号
_id : "332013102500000000000000"
# 科室显示顺序
order            : 34
# 科室名称
name             : '尿早早孕检测'
# 科室类型（临床类型或者实验室类型）[clinic|laboratory]
category             : 'laboratory'
door_number: ['212']
door_name: '尿早早孕检测'

# 项目
items         : [
  {
    _id      : "332013102500000000000001"
    name     : '尿早早孕检测'
    abbr     : 'HCG'
    sex      : '女'
    category : 'number'
    default  : '阴性'
    conditions_string: """
        >> 阳性
        >> 弱阳性
        >> {阳性}+
        >> {弱阳性}+-
    """
  }
]

