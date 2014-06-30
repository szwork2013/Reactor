# 科室属性结构

# 身高、体重、腰围、臀围精确到整数厘米

# 科室编号
_id : "190000000000000000004000"
# 科室显示顺序
order            : 4
# 科室名称
name             : '体脂率'
# 科室类型（临床类型或者实验室类型）[clinic|laboratory]
category             : 'clinic'
# 图片所放位置
image_path:        './yibanqingkuang.svg'
# 门牌号
door_number: ['103']
# 房间名称
door_name: '体脂率'
# 项目
items         : [
  {
    _id : "190000000000000000000008"
    name : '体脂率'
    # 计算公式
    # 体脂率 =[（ 腰围 × 0.74 ）- （体重 × 0.082 + if sex is '男' then 44.74 else 34.89）] / 体重 × 100%
    category: 'text'
    conditions_string: """
                >> 体脂率偏高

                >> 体脂率偏低
                """
  }
]
