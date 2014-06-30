# 科室属性结构

# 科室编号
_id : "220000000000000000000000"
# 科室显示顺序
order            : 16
# 科室名称
name             : '血常规'
# 科室类型（临床类型或者实验室类型）[clinic|laboratory]
category             : 'laboratory'
# 图片所放位置
image_path:        './xuechanggui.svg'
# 门牌号
door_number: ['102']
# 房间名称
door_name: '血常规室'
# 项目
items         : [
  {
    _id  : "220000000000000000000001"
    name : '白细胞'
    abbr : 'WBC'
    lt   : '4.00'
    ut   : '10.00'
    unit : '10<sup>9</sup>/L'
    category: 'number'
    # 偏高偏低都是箭头；
    # 偏高建议，偏低不建议。
    conditions_string: """
    >> 值大于14 -> 血常规白细胞升高
    
    >> {血常规白细胞偏低}偏低

    >> {血常规白细胞偏高}偏高
    """
  }
  {
    _id  : "220000000000000000000002"
    name : '红细胞'
    abbr : 'RBC'
    lt   : "if sex is '男' then 4.00 else 3.50"
    ut   : "if sex is '男' then 5.50 else 5.00"
    unit : '10<sup>12</sup>/L'
    category: 'number'
    # 偏低偏高都箭头。
    # 偏低建议，偏高不建议。
    conditions_string: """
    >> 值小于2.5 -> 血常规红细胞降低

    >> {血常规红细胞偏低}偏低

    >> {血常规红细胞偏高}偏高
    """
  }
  {
    _id  : "220000000000000000000003"
    name : '血红蛋白'
    abbr : 'HGB'
    lt   : "if sex is '男' then 110 else 100"
    ut   : "if sex is '男' then 160 else 150"
    unit : 'g/L'
    category: 'number'
    # 偏高偏低都箭头。
    # 偏低建议，偏高不建议。
    conditions_string: """
    >> 性别等于男并且值大于170 或者 性别等于女并且值大于160 -> 血红蛋白升高

    >> 值小于60 -> 血红蛋白降低
    
    >> 偏高
    
    >> 偏低
    """
  }
  {
    _id  : "220000000000000000000004"
    name : '红细胞压积'
    abbr : 'HCT'
    lt   : '37.0'
    ut   : '54.0'
    unit : '%'
    category: 'number'
    # 偏低偏高都箭头。
    # 偏低建议，偏高不建议。
    conditions_string: """
    >> {血常规红细胞压积偏低}偏低

    >> {血常规红细胞压积偏高}偏高
    """
  }
  {
    _id  : "220000000000000000000005"
    name : '血小板'
    abbr : 'PLT'
    lt   : '100'
    ut   : '300'
    unit : '10<sup>9</sup>/L'
    category: 'number'
    # 偏高偏低均箭头。
    # 问：哪个建议。
    conditions_string: """
    >> 值大于350 -> 血小板升高

    >> 值小于50 -> 血小板降低
    
    >> 偏高

    >> 偏低
    """
  }
  {
    _id  : "220000000000000000000006"
    name : '红细胞平均体积'
    abbr : 'MCV'
    lt   : '80.0'
    ut   : '100.0'
    unit : 'fL'
    category: 'number'
    # 偏高偏低均箭头，项目不变红。
    conditions_string: """
    >> 偏高

    >> 偏低
    """
  }
  {
    _id  : "220000000000000000000007"
    name : '红细胞平均血红蛋白含量'
    abbr : 'MCH'
    lt   : '27.0'
    ut   : '34.0'
    unit : 'pg'
    category: 'number'
    # 偏高偏低均箭头，项目不变红，偏高偏低均箭头，项目不变红。
    conditions_string: """
    >> 偏高

    >> 偏低
    """
  }
  {
    _id  : "220000000000000000000008"
    name : '红细胞平均血红蛋白浓度'
    abbr : 'MCHC'
    lt   : '320'
    ut   : '360'
    unit : 'g/L'
    category: 'number'
    # 偏高偏低均箭头，项目不变红，不建议。
    conditions_string: """
    >> 偏高

    >> 偏低
    """
  }
  {
    _id  : "220000000000000000000009"
    name : '红细胞体积分布宽度-SD'
    abbr : 'RDW-SD'
    lt   : '35.0'
    ut   : '56.0'
    unit : 'f/L'
    category: 'number'
    # 偏高偏低均建议，项目不变红，不建议。
    conditions_string: """
    >> 偏高

    >> 偏低
    """
  }
  {
    _id  : "220000000000000000000010"
    name : '红细胞体积分布宽度-CV'
    abbr : 'RDW-CV'
    lt   : '11.0'
    ut   : '16.0'
    unit : '%'
    category: 'number'
    conditions_string: """
    >> 偏高

    >> 偏低
    """
  }
  {
    _id : "220000000000000000000011"
    name : '血小板压积'
    abbr : 'PCT'
    lt   : '0.108'
    ut   : '0.282'
    unit : '%'
    category: 'number'
    conditions_string: """
    >> 偏高

    >> 偏低
    """
  }
  {
    _id  : "220000000000000000000012"
    name : '平均血小板体积'
    abbr : 'MPV'
    lt   : '6.5'
    ut   : '12.0'
    unit : 'fL'
    category: 'number'
    conditions_string: """
    >> 偏高

    >> 偏低
    """
  }
  {
    _id  : "220000000000000000000013"
    name : '血小板体积分布宽度'
    abbr : 'PDW'
    lt   : '9.0'
    ut   : '17.0'
    unit : '%'
    category: 'number'
    conditions_string: """
    >> 偏高

    >> 偏低
    """
  }
  {
    _id  : "220000000000000000000014"
    name : '中性粒细胞百分比'
    abbr : 'NEU%'
    lt   : '50.0'
    ut   : '70.0'
    unit : '%'
    category: 'number'
    conditions_string: """
    >> 偏高

    >> 偏低
    """
  }
  {
    _id : "220000000000000000000015"
    name : '淋巴细胞百分比'
    abbr : 'LYM%'
    lt   : '20.0'
    ut   : '40.0'
    unit : '%'
    category: 'number'
    conditions_string: """
    >> 偏高

    >> 偏低
    """
  }
  {
    _id  : "220000000000000000000016"
    name : '单核细胞百分比'
    abbr : 'MON%'
    lt   : '3.0'
    ut   : '12.0'
    unit : '%'
    category: 'number'
    conditions_string: """
    >> 偏高

    >> 偏低
    """
  }
  {
    _id : "220000000000000000000017"
    name : '嗜酸性粒细胞百分比'
    abbr : 'EOS%'
    lt   : '0.5'
    ut   : '5.0'
    unit : '%'
    category: 'number'
    conditions_string: """
    >> 偏高

    >> 偏低
    """
  }
  {
    _id  : "220000000000000000000018"
    name : '嗜碱性粒细胞百分比'
    abbr : 'BAS%'
    lt   : '0.0'
    ut   : '1.0'
    unit : '%'
    category: 'number'
    conditions_string: """
    >> 偏高

    >> 偏低
    """
  }
  {
    _id : "220000000000000000000019"
    name : '中性粒细胞绝对值'
    abbr : 'NEU#'
    lt   : '2.00'
    ut   : '7.00'
    unit : '10<sup>9</sup>/L'
    category: 'number'
    conditions_string: """
    >> 偏高

    >> 偏低
    """
  }
  {
    _id  : "220000000000000000000020"
    name : '淋巴细胞绝对值'
    abbr : 'LYM#'
    lt   : '0.80'
    ut   : '4.00'
    unit : '10<sup>9</sup>/L'
    category: 'number'
    conditions_string: """
    >> 偏高

    >> 偏低
    """
  }
  {
    _id : "220000000000000000000021"
    name : '单核细胞绝对值'
    abbr : 'MON#'
    lt   : '0.12'
    ut   : '1.20'
    unit : '10<sup>9</sup>/L'
    category: 'number'
    conditions_string: """
    >> 偏高

    >> 偏低
    """
  }
  {
    _id  : "220000000000000000000022"
    name : '嗜酸性粒细胞绝对值'
    abbr : 'EOS#'
    lt   : '0.02'
    ut   : '0.50'
    unit : '10<sup>9</sup>/L'
    category: 'number'
    conditions_string: """
    >> 偏高

    >> 偏低
    """
  }
  {
    _id  : "220000000000000000000023"
    name : '嗜碱性粒细胞绝对值'
    abbr : 'BAS#'
    lt   : '0.00'
    ut   : '0.10'
    unit : '10<sup>9</sup>/L'
    category: 'number'
    conditions_string: """
    >> 偏高

    >> 偏低
    """
  }
]

# 项目变红的规则：
# 取决于是否有建议涉及该项目。如果A＋B出建议X，则A、B均变红；
# 如果A＋B合并后没有建议，则A、B均不变红；
# 如果A单项出建议，则A变红。

# 建议汇总：
#
# 
