# 科室属性结构

# 科室编号
_id : "270000000000000000000000"
# 科室显示顺序
order            : 21
# 科室名称
name             : '生化检验'
# 科室类型（临床类型或者实验室类型）[clinic|laboratory]
category             : 'laboratory'
# 图片所放位置
image_path:        './shenghuajianyan.svg'
# 门牌号
door_number: ['214']
# 房间名称
door_name: '生化室'
# 项目
items: [
  {
    # 编号
    _id  : "270000000000000000000001"
    # 项目名称
    name : '谷丙转氨酶'
    # 简写
    abbr : 'ALT'
    # 下限
    lt   : '0'
    # 上限
    ut   : '40'
    # 单位
    unit : 'U/L'
    # 类型
    category : 'number'
    # 症状
    conditions_string : """
        >> 值大于200 -> 谷丙转氨酶严重升高

        >> 偏高
    """
  }
  {
    _id  : "270000000000000000000002"
    name : '谷草转氨酶'
    abbr : 'AST'
    lt   : '0'
    ut   : '40'
    unit : 'U/L'
    category : 'number'
    conditions_string : """
        >> 值大于200 -> 谷草转氨酶严重升高

        >> 偏高
    """
  }
  {
    _id  : "270000000000000000000003"
    name : '总蛋白'
    abbr : 'TP'
    lt   : '62'
    ut   : '85'
    unit : 'g/L'
    category : 'number'
    conditions_string : """
        >> 偏低

        >> 偏高
    """
  }
  {
    _id  : "270000000000000000000004"
    name : '白蛋白'
    abbr : 'ALB'
    lt   : '35'
    ut   : '54'
    unit : 'g/L'
    category : 'number'
    conditions_string: """
        >> 偏低

        >> 偏高
    """
  }
  {
    _id  : "270000000000000000000005"
    name : '球蛋白'
    abbr : 'GLB'
    lt   : '25'
    ut   : '45'
    unit : 'g/L'
    expression : '总蛋白 - 白蛋白'
    category: 'number'
    conditions_string: """
        >> 偏低

        >> 偏高
    """
  }
  {
    _id  : "270000000000000000000014"
    name : '白球比'
    abbr : 'A/G'
    lt   : '1.5'
    ut   : '2.5'
    expression : '白蛋白 / 球蛋白'
    category: 'number'
    conditions_string: """
        >> 偏低

        >> 偏高
    """
  }
  {
    _id  : "270000000000000000000006"
    name : '总胆红素'
    abbr : 'TBIL'
    lt   : '3.40'
    ut   : '25.40'
    unit : 'µmol/L'
    category: 'number'
    conditions_string: """
        >> 偏低

        >> 偏高
    """
  }
  {
    _id  : "270000000000000000000007"
    name : '直接胆红素'
    abbr : 'DBIL'
    lt   : '0.00'
    ut   : '6.84'
    unit : 'µmol/L'
    category: 'number'
    conditions_string: """
        >> 偏高
    """
  }
  {
    _id  : "270000000000000000000008"
    name : '间接胆红素'
    abbr : 'IBIL'
    lt   : '0.00'
    ut   : '20.00'
    unit : 'µmol/L'
    expression : '总胆红素 - 直接胆红素'
    category: 'number'
    conditions_string: """
        >> 偏高
    """
  }
  {
    _id  : "270000000000000000000009"
    name : 'γ-谷氨酰转肽酶'
    abbr : 'GGT'
    lt   : '0.0'
    ut   : '50.0'
    unit : 'U/L'
    category: 'number'
    conditions_string: """
        >> 值大于100.0 -> γ-谷氨酰转肽酶严重升高        

        >> 偏高
    """
  }
  {
    _id  : "270000000000000000000010"
    name : '碱性磷酸酶'
    abbr : 'ALP'
    lt   : '40.0'
    ut   : '150.0'
    unit : 'U/L'
    category: 'number'
    conditions_string: """
        >> 偏低

        >> 偏高
    """
  }
  {
    _id  : "270000000000000000000011"
    name : '胆碱酯酶'
    abbr : 'CHE'
    lt   : '4000'
    ut   : '13000'
    unit : 'U/L'
    category: 'number'
    conditions_string: """
        >> 偏低

        >> 偏高
    """
  }
  {
    _id  : "270000000000000000000012"
    name : '总胆汁酸'
    abbr : 'TBA'
    lt   : '0'
    ut   : '10'
    unit : 'µmol/L'
    category: 'number'
    conditions_string: """
        >> 偏高
    """
  }
  {
    _id  : "270000000000000000000013"
    name : '同型半胱氨酸'
    abbr : 'HCY'
    lt   : '4.0'
    ut   : '15.4'
    unit : 'µmol/L'
    category: 'number'
    conditions_string: """
        >> 偏低

        >> 偏高
    """
  }
  {
    _id  : "270000000000000000000015"
    name : '甘油三酯'
    abbr : 'TG'
    lt   : '0.40'
    ut   : '1.86'
    unit : 'mmol/L'
    category: 'number'
    conditions_string: """
        >> 偏低

        >> 偏高
    """
  }
  {
    _id  : "270000000000000000000016"
    name : '胆固醇'
    abbr : 'CHO'
    lt   : '0.00'
    ut   : '6.19'
    unit : 'mmol/L'
    category : 'number'
    conditions_string : """
        >> 偏高
    """
  }
  {
    _id  : "270000000000000000000017"
    name : '高密度脂蛋白'
    abbr : 'HDL'
    lt   : '1.20'
    ut   : '1.68'
    unit : 'mmol/L'
    category : 'number'
    conditions_string : """
        >> 偏低

        >> 偏高
    """
  }
  {
    _id  : "270000000000000000000018"
    name : '低密度脂蛋白'
    abbr : 'LDL'
    lt   : '2.07'
    ut   : '3.10'
    unit : 'mmol/L'
    category : 'number'
    conditions_string : """
        >> 偏低

        >> 偏高
    """
  }
  {
    _id  : "270000000000000000000019"
    name : '脂蛋白a'
    abbr : 'Lp-a'
    lt   : '0'
    ut   : '300'
    unit : 'mg/L'
    category: 'number'
    conditions_string: """
        >> 偏高
    """
  }
  {
    _id  : "270000000000000000000020"
    name : '载脂蛋白A1'
    abbr : 'ApoA1'
    lt   : '1.00'
    ut   : '1.60'
    unit : 'g/L'
    category: 'number'
    conditions_string: """
        >> 偏低

        >> 偏高
    """
  }
  {
    _id  : "270000000000000000000021"
    name : '载脂蛋白B'
    abbr : 'ApoB'
    lt   : '0.60'
    ut   : '1.14'
    unit : 'g/L'
    category : 'number'
    conditions_string : """
        >> 偏低

        >> 偏高
    """
  }
  {
    _id  : "270000000000000000000022"
    name : '尿素氮'
    abbr : 'BUN'
    lt   : '2.89'
    ut   : '8.20'
    unit : 'mmol/L'
    category: 'number'
    conditions_string: """
        >> 值大于10 -> 尿素氮升高

        >> 偏低

        >> 偏高
    """
  }
  {
    _id  : "270000000000000000000023"
    name : '肌酐'
    abbr : 'CRE'
    lt   : "if sex is '男' then 44 else 40"
    ut   : "if sex is '男' then 133 else 106"
    unit : 'µmol/L'
    category : 'number'
    conditions_string : """
        >> 性别等于男并且值大于133 或者 性别等于女并且值大于106 -> 肌酐严重升高

        >> 偏低

        >> 偏高
    """
  }
  {
    _id  : "270000000000000000000024"
    name : '尿酸'
    abbr : 'UA'
    lt   : "if sex is '男' then 208 else 155"
    ut   : "if sex is '男' then 428 else 357"
    unit : 'µmol/L'
    category: 'number'
    conditions_string: """
        >> 偏低

        >> {高尿酸血症}偏高
    """
  }
  {
    _id  : "270000000000000000000030"
    name : '肌酸激酶'
    abbr : 'CK'
    lt   : '26'
    ut   : '174'
    unit : 'U/L'
    category : 'number'
    conditions_string : """
        >> 偏低

        >> 偏高
    """
  }
  {
    _id  : "270000000000000000000031"
    name : 'α-羟基丁酸脱氢酶'
    abbr : 'HBDH'
    lt   : '74'
    ut   : '230'
    unit : 'U/L'
    category : 'number'
    conditions_string : """
        >> 偏低

        >> 偏高
    """
  }
  {
    _id : "270000000000000000000032"
    name : '乳酸脱氢酶'
    abbr : 'LDH'
    lt   : "if sex is '男' then 80 else 103"
    ut   : "if sex is '男' then 285 else 227"
    unit : 'U/L'
    category: 'number'
    conditions_string: """
        >> 偏低

        >> 偏高
    """
  }
  {
    _id  : "270000000000000000000033"
    name : '肌酸激酶同工酶'
    abbr : 'CKMB'
    lt   : '0'
    ut   : '24'
    unit : 'U/L'
    category: 'number'
    conditions_string: """
        >> 值大于60 -> 肌酸激酶同工酶升高

        >> 偏高
    """
  }
  {
    _id  : "270000000000000000000034"
    name : '空腹血糖'
    abbr : 'GLU'
    lt   : '3.90'
    ut   : '6.10'
    unit : 'mmol/L'
    category: 'number'
    conditions_string: """
        >> 值大于7.0 -> 空腹血糖高于诊断标准

        >> 偏低

        >> 偏高
    """
  }
  {
    _id  : "270000000000000000000036"
    name : '糖化血红蛋白'
    abbr : 'HbA1c'
    lt   : '3.5'
    ut   : '5.8'
    unit : '%'
    category: 'number'
    conditions_string: """
        >> 值大于6.5 -> 糖化血红蛋白高于诊断标准

        >> 偏低

        >> 偏高
    """
  }
  {
    _id  : "270000000000000000000037"
    name : '餐后两小时血糖'
    abbr : 'GLU120'
    lt   : '4.4'
    ut   : '7.8'
    unit : 'mmol/L'
    category : 'number'
    conditions_string : """
        >> 偏低

        >> 偏高
    """
  }
  {
    _id  : "270000000000000000000038"
    name : '类风湿因子'
    abbr : 'RF'
    lt   : '0'
    ut   : '20'
    unit : 'IU/mL'
    category: 'number'
    conditions_string: """
        >> 偏高
    """
  }
  {
    _id  : "270000000000000000000039"
    name : '抗“O”'
    abbr : 'ASO'
    lt   : '0'
    ut   : '250'
    unit : 'IUmol/L'
    category: 'number'
    conditions_string: """
        >> 偏高
    """
  }
  {
    _id  : "270000000000000000000040"
    name : 'C-反应蛋白'
    abbr : 'CRP'
    lt   : '0'
    ut   : '10'
    unit : 'mg/L'
    category: 'number'
    conditions_string: """
        >> 偏高
    """
  }
  {
    _id : "330000000000000000000002"
    name : '钙'
    abbr : 'Ca'
    lt   : '2.00'
    ut   : '2.75'
    unit : "mmol/L"
    category: 'number'
    conditions_string: """
      >> 偏低

      >> 偏高

    """
  }
  {
    _id : "330000000000000000000004"
    name : '磷'
    abbr : 'PHOS'
    lt   : '0.96'
    ut   : '2.1'
    unit : "mmol/L"
    category: 'number'
    conditions_string: """
      >> 偏高

      >> 偏低

    """
  }
  {
    _id : "330000000000000000000001"
    name : '镁'
    abbr : 'Mg'
    lt   : '0.7'
    ut   : '1.1'
    unit : "mmol/L"
    category: 'number'
    conditions_string: """
      >> 偏低

      >> 偏高

    """
  }
  {
    _id : "330000000000000000000005"
    name : '铁'
    abbr : 'Fe'
    lt   : "if sex is '男' then 9 else 7"
    ut   : "if sex is '男' then 32 else 30"
    unit : "umol/L"
    category: 'number'
    conditions_string: """
      >> 偏低

      >> 偏高

    """
  }
  {
    _id : "330000000000000000000003"
    name : '锌'
    abbr : 'Zn'
    lt   : "if sex is '男' then 11.1 else 10.7"
    ut   : "if sex is '男' then 19.5 else 17.5"
    unit : "umol/L"
    category: 'number'
    conditions_string: """
      >> 偏低

      >> 偏高

    """
  }
  {
    _id : "330000000000000000000050"
    name : '尿微量白蛋白'
    abbr : 'mAlb'
    lt   : "0.49"
    ut   : "2.05"
    unit : "mg/mmol"
    category: 'number'
    conditions_string: """
      >> 偏低

      >> 偏高

    """
  }
  {
    _id : "330000000000000000000051"
    name : 'C-肽'
    abbr : 'C-PR'
    lt   : "1.4"
    ut   : "5.5"
    unit : "ng/ml"
    category: 'number'
    conditions_string: """
      >> 偏低

      >> 偏高

    """
  }
  {
    _id : "330000000000000000000052"
    name : '胰岛素'
    abbr : ''
    lt   : "3.3"
    ut   : "19.5"
    unit : "mIU/L"
    category: 'number'
    conditions_string: """
      >> 偏低

      >> 偏高

    """
  }
  {
    _id : "330000000000000000000053"
    name : '血清胱抑素'
    abbr : ''
    lt   : "0"
    ut   : "1.16"
    unit : ""
    category: 'number'
    conditions_string: """
      >> 偏低

      >> 偏高

    """
  }
]
