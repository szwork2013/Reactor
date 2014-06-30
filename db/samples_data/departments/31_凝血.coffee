# 科室属性结构

# 科室编号
_id : "31000000a1a100000000bbbb"
# 科室显示顺序
order            : 31
# 科室名称
name             : '凝血'
# 科室类型（临床类型或者实验室类型）[clinic|laboratory]
category             : 'laboratory'

door_name: '凝血'

# 图片所放位置
image_path:        './c13youmenluoxuanganjunjiance.jpg'
# 项目
items         : [
  {
    _id : "31000000a1a10000aaaabbb1"
    name : '国际标准化比值'
    byname : ['国际标准化比值（INR）']
    abbr : 'INR'
    category: 'number'
    lt   : '0.80'
    ut   : '1.20'
    unit : ''
    conditions_string: """
        >> 偏高

        >> 偏低
    """
  }
  {
    _id : "31000000a1a100000000bbb2"
    name : '活化部分凝血活酶时间'
    abbr : 'APTT'
    category: 'number'
    lt   : '28.0'
    ut   : '42.0'
    unit : 's'
    conditions_string: """
        >> 偏高

        >> 偏低
    """
  }
  {
    _id : "31000000a1a100000000bbb3"
    name : '凝血酶时间'
    abbr : 'TT'
    category: 'number'
    lt   : '12.0'
    ut   : '18.0'
    unit : 's'
    conditions_string: """
        >> 偏高

        >> 偏低
    """
  }
  {
    _id : "31000000a1a100000000bbb4"
    name : '纤维蛋白原'
    byname : ['纤维蛋白原[FIB]']
    abbr : 'FIB'
    category: 'number'
    lt   : '2.00'
    ut   : '4.40'
    unit : 'g/L'
    conditions_string: """
        >> 偏高

        >> 偏低
    """
  }
  {
    _id : "31000000a1a100000000bbb5"
    name : '凝血酶原时间'
    abbr : 'PT'
    category: 'number'
    lt   : '8.80'
    ut   : '12.80'
    unit : 's'
    conditions_string: """
        >> 偏高

        >> 偏低
    """
  }
]
