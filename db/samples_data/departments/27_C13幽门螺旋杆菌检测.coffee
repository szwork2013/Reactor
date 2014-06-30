# 科室属性结构

# 科室编号
_id : "100000000000000000000000"
# 科室显示顺序
order            : 28
# 科室名称
name             : 'C13幽门螺旋杆菌检测'
# 科室类型（临床类型或者实验室类型）[clinic|laboratory]
category             : 'laboratory'

door_name: 'C13幽门螺旋杆菌检测'

# 图片所放位置
image_path:        './c13youmenluoxuanganjunjiance.jpg'
# 项目
items         : [
  {
    # 项目编号
    _id : "100000000000000000000001"
    # 项目名称
    name : 'C13幽门螺旋杆菌检测'
    default: '阴性'
    # 类型
    category: 'text'
    # 小结与建议
    conditions_string: """
                >> 阳性
                >> {C13幽门螺旋杆菌检测阳性}++++
                >> {C13幽门螺旋杆菌检测阳性}+++
                >> {C13幽门螺旋杆菌检测阳性}++
                >> {C13幽门螺旋杆菌检测阳性}+
                >> {C13幽门螺旋杆菌检测弱阳性}+-
                """
  }
]
