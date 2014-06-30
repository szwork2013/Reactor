# 科室属性结构

# 身高、体重、腰围、臀围精确到整数厘米

# 科室编号
_id : "190000000000000000000000"
# 科室显示顺序
order            : 1
# 科室名称
name             : '身高体重'
# 科室类型（临床类型或者实验室类型）[clinic|laboratory]
category             : 'clinic'
# 图片所放位置
image_path:        './yibanqingkuang.svg'
# 门牌号
door_number: ['103']
# 房间名称
door_name: '身高体重'
# 项目
items         : [
  {
    # 项目编号
    _id : "190000000000000000000001"
    name : '身高'
    unit : 'cm'
    category: 'text'
    conditions_string: ''
  }
  {
    _id : "190000000000000000000002"
    name : '体重'
    unit : 'kg'
    category: 'text'
    conditions_string: ''
  }
  {
    _id : "190000000000000000000003"
    name : '体重指数'
    # 正常范围：18.5-24
    category: 'text'
    conditions_string: """
                >> 值大于28 -> 体重严重超重

                >> 值大于24.0 -> 体重超重

                >> 值小于18.5 -> 体重过低
                """
  }
]
