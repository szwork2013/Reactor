# 科室属性结构

# 身高、体重、腰围、臀围精确到整数厘米

# 科室编号
_id : "190000000000000000002000"
# 科室显示顺序
order            : 2
# 科室名称
name             : '血压'
# 科室类型（临床类型或者实验室类型）[clinic|laboratory]
category             : 'clinic'
# 图片所放位置
image_path:        './yibanqingkuang.svg'
# 门牌号
door_number: ['103']
# 房间名称
door_name: '血压'
# 项目
items         : [
  {
    # 项目编号
    _id : "190000000000000000000004"
    # 项目名称
    name : '血压'
    # 类型
    category: 'text'
    # 小结与建议
    conditions_string: """
                >> 收缩压大于140或舒张压大于90 -> 血压偏高

                >> 收缩压大于120或舒张压大于80 -> 正常高值血压

                >> 收缩压小于90或舒张压小于60 -> 低血压
                """
  }
]
