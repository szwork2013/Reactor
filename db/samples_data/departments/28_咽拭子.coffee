# 科室属性结构

# 科室编号
_id : "28000000a1a1000000000000"
# 科室显示顺序
order            : 28
# 科室名称
name             : '咽拭子'
# 科室类型（临床类型或者实验室类型）[clinic|laboratory]
category             : 'laboratory'

door_name: '咽拭子'

# 图片所放位置
image_path:        './c13youmenluoxuanganjunjiance.jpg'
# 项目
items         : [
  {
    # 项目编号
    _id : "28000000a1a1000000000001"
    # 项目名称
    name : '幽门螺杆菌'
    # 类型
    category: 'text'
    # 小结与建议
    conditions_string: """
                >> 阳性
                >> 弱阳性
                >> {幽门螺杆菌阳性}++++
                >> {幽门螺杆菌阳性}+++
                >> {幽门螺杆菌阳性}++
                >> {幽门螺杆菌阳性}+
                >> {弱阳性}+-
                """
  }
]
