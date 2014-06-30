# 科室属性结构

# 科室编号
_id : "332013101100000000000000"
# 科室显示顺序
order            : 33
# 科室名称
name             : '白带常规'
# 科室类型（临床类型或者实验室类型）[clinic|laboratory]
category             : 'laboratory'

door_number: ['212']

door_name: '白带常规'

# 图片所放位置
image_path:        './tct.jpg'
# 项目
items         : [
  {
    _id : "332013101100000000000001"
    name : '清洁度'
    unit : ""
    sex : '女'
    category: 'number'
    conditions_string: """
        >> {白带常规清洁度Ⅲ度}Ⅲ
        >> {白带常规清洁度Ⅳ度}Ⅳ
    """
  }
  {
    _id : "332013101100000000000002"
    name : '阴道杆菌'
    unit : ""
    sex : '女'
    category: 'number'
    conditions_string: """
        >> 偏低
        >> 偏高

    """
  }
  {
    _id : "332013101100000000000003"
    name : '上皮细胞'
    unit : ""
    sex : '女'
    category: 'number'
    conditions_string: """
        >> 偏低
        >> 偏高
    """
  }
  {
    _id : "332013101100000000000004"
    name : '白细胞'
    lt   : '0'
    ut   : '15'
    unit : "/HP"
    sex : '女'
    category: 'number'
    conditions_string: """
        >> 偏低
        >> 偏高
    """
  }
  {
    _id : "332013101100000000000005"
    name : '霉菌'
    unit : ""
    sex : '女'
    category: 'number'
    conditions_string: """
        >> 偏低
        >> 偏高
    """
  }
  {
    _id : "332013101100000000000006"
    name : '滴虫'
    unit : ""
    sex : '女'
    category: 'number'
    conditions_string: """
        >> 偏低
        >> 偏高
    """
  }
]

