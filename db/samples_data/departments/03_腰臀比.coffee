# 科室属性结构

# 身高、体重、腰围、臀围精确到整数厘米

# 科室编号
_id : "190000000000000000003000"
# 科室显示顺序
order            : 3
# 科室名称
name             : '腰臀比'
# 科室类型（临床类型或者实验室类型）[clinic|laboratory]
category             : 'clinic'
# 图片所放位置
image_path:        './yibanqingkuang.svg'
# 门牌号
door_number: ['103']
# 房间名称
door_name: '腰臀比'
# 项目
items         : [
  {
    _id : "190000000000000000000005"
    name : '腰围'
    unit : 'cm'
    category: 'text'
    # 男性大于等于85cm，女性大于等于80为腹部脂肪积聚
    conditions_string: """
                """
  }
  {
    _id : "190000000000000000000006"
    name : '臀围'
    unit : 'cm'
    category: 'text'
    conditions_string: """
                """
  }
  {
    _id : "190000000000000000000007"
    name : '腰臀比'
    # lt : 'if sex is '男' then 0.67 else 0.80'
    # ut : 'if sex is '男' then 0.85 else 0.95'
    category: 'text'
    conditions_string: """
                >> 男性且值小于0.67 或者 女性且值小于0.85 -> 下半身肥胖

                >> 男性且值大于0.80 或者 女性且值大于0.95 -> 上半身肥胖
                """
  }
]
