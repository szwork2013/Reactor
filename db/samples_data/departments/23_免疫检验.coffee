# 科室属性结构

# 科室编号
_id : "280000000000000000000000"
# 科室显示顺序
order            : 24
# 科室名称
name             : '免疫检验'
# 科室类型（临床类型或者实验室类型）[clinic|laboratory]
category             : 'laboratory'
# 图片所放位置
image_path:        './mianyi.svg'
# 门牌号
door_number: ['214']
# 房间名称
door_name: '免疫室'
# 项目
items         : [
  # 两对半建议单独出具
  {
    _id  : "280000000000000000000001"
    name : '乙肝病毒表面抗原'
    abbr : 'HBsAg'
    category: 'number'
    # 可单独提示，但仅限于只做该项检查的。
    conditions_string: """
    >> 阴性
    >> {乙肝病毒表面抗原阴性}-

    >> 阳性
    >> {乙肝病毒表面抗原阳性}+
    """
  }
  {
    _id  : "280000000000000000000002"
    name : '乙肝病毒表面抗体'
    abbr : 'HBsAb'
    category: 'number'
    conditions_string: """
    >> 阴性
    >> {乙肝病毒表面抗体阴性}-

    >> 阳性
    >> {乙肝病毒表面抗体阳性}+
    """
  }
  {
    _id : "280000000000000000000003"
    name : '乙肝病毒e抗原'
    abbr : 'HBeAg'
    category: 'number'
    conditions_string: """
    >> 阴性
    >> {乙肝病毒e抗原阴性}-

    >> 阳性
    >> {乙肝病毒e抗原阳性}+
    """
  }
  {
    _id  : "280000000000000000000004"
    name : '乙肝病毒e抗体'
    abbr : 'HBeAb'
    category: 'number'
    conditions_string: """
    >> 阴性
    >> {乙肝病毒e抗体阴性}-

    >> 阳性
    >> {乙肝病毒e抗体阳性}+
    """
  }
  {
    _id  : "280000000000000000000005"
    name : '乙肝病毒核心抗体'
    abbr : 'HBcAb'
    category: 'number'
    conditions_string: """
    >> 阴性
    >> {乙肝病毒核心抗体阴性}-

    >> 阳性
    >> {乙肝病毒核心抗体阳性}+
    """
  }
  {
    _id  : "280000000000000000000006"
    name : '乙肝病毒DNA检测'
    abbr : 'HBV-DNA'
    category: 'number'
    conditions_string: """
    """
  }
  {
    _id  : "280000000000000000000007"
    name : '癌胚抗原'
    abbr : 'CEA'
    lt   : '0.00'
    ut   : '5.00'
    unit : 'ng/mL'
    category : 'number'
    conditions_string : """
    >> 偏高
    """
  }
  {
    _id  : "280000000000000000000008"
    name : '甲胎蛋白'
    abbr : 'AFP'
    lt   : '0.00'
    ut   : '20.00'
    unit : 'ng/mL'
    category: 'number'
    conditions_string: """
	>> 偏低

	>> 偏高
    """
  }
  {
    _id  : "280000000000000000000009"
    name : '前列腺特异性抗原'
    byname : ['总前列腺特异性抗原']
    abbr : 'T-PSA'
    sex  : '男'
    lt   : '0.0'
    ut   : '4.0'
    unit : 'ng/mL'
    category: 'number'
    conditions_string: """
	>> 偏低

	>> 偏高
    """
  }
  {
    _id  : "280000000000000000000010"
    name : '游离前列腺特异性抗原'
    abbr : 'F-PSA'
    sex  : '男'
    lt   : '0.00'
    ut   : '0.75'
    unit : 'ng/mL'
    category: 'number'
    conditions_string: """
	>> {游离前列腺特异性抗原阳性}偏高
    """
  }
  {
    _id : "280000000000000000000011"
    name : 'CA125'
    abbr : 'CA125'
    sex  : '女'
    lt   : '0.0'
    ut   : '35.0'
    unit : 'ng/mL'
    category: 'number'
    conditions_string: """
	>> 偏低

	>> 偏高
    """
  }
  {
    _id  : "280000000000000000000012"
    name : 'CA15-3'
    abbr : 'CA15-3'
    sex  : '女'
    lt   : '0.0'
    ut   : '28.0'
    unit : 'ng/mL'
    category: 'number'
    conditions_string: """
	>> 偏低

	>> 偏高
    """
  }
  {
    _id : "280000000000000000000013"
    name : 'CA19-9'
    abbr : 'CA19-9'
    lt   : '0.0'
    ut   : '37.0'
    unit : 'U/mL'
    category: 'number'
    conditions_string: """
	>> 偏低

	>> 偏高
    """
  }
  {
    _id : "280000000000000000000014"
    name : 'CA72-4'
    abbr : 'CA72-4'
    lt   : '0.0'
    ut   : '6.9'
    unit : 'U/mL'
    category: 'number'
    conditions_string: """
	>> 偏低

	>> 偏高
    """
  }
  {
    _id  : "280000000000000000000015"
    name : 'CA50'
    abbr : 'CA50'
    lt   : '0'
    ut   : '30'
    unit : 'U/mL'
    category: 'number'
    conditions_string: """
	>> 偏低

	>> 偏高
    """
  }
  {
    _id  : "280000000000000000000016"
    name : '细胞角蛋白19片段'
    abbr : 'CYFRA21-1'
    lt   : '0.0'
    ut   : '3.3'
    unit : 'ng/mL'
    category: 'number'
    conditions_string: """
	>> 偏低

	>> 偏高
    """
  }
  {
    _id  : "280000000000000000000017"
    name : 'NSE'
    abbr : 'NSE'
    lt   : '0.0'
    ut   : '12.5'
    unit : 'ng/mL'
    category: 'number'
    conditions_string: """
	>> 偏低

	>> 偏高
    """
  }
  {
    _id : "280000000000000000000018"
    name : 'CA242'
    abbr : 'CA242'
    lt   : '0.0'
    ut   : '22.0'
    unit : 'U/ml'
    category: 'number'
    conditions_string: """
	>> 偏低

	>> 偏高
    """
  }
  {
    _id  : "280000000000000000000019"
    name : 'SCC-Ag'
    byname : ['鳞状细胞癌相关抗原']
    abbr : 'SCC-Ag'
    sex  : '女'
    lt   : '0'
    ut   : '15'
    unit : 'ug/L'
    category: 'number'
    conditions_string: """
	>> 偏低

	>> 偏高
    """
  }
  {
    _id : "280000000000000000000020"
    name : 'AFU'
    abbr : 'AFU'
    lt   : '10'
    ut   : '35'
    unit : 'ng/ml'
    category: 'number'
    conditions_string: """
	>> 偏低

	>> 偏高
    """
  }
  {
    _id : "280000000000000000000021"
    name : 'EB病毒'
    abbr : 'EBv'
    lt   : '0.0'
    ut   : '2.1'
    unit : 'P/N'
    category: 'number'
    conditions_string: """
	>> 偏低

	>> 偏高
    """
  }
  {
    _id  : "280000000000000000000022"
    name : '血清铁蛋白'
    abbr : 'FER'
    lt   : "if sex is '男' then 12 else 5"
    ut   : "if sex is '男' then 245 else 130"
    unit : 'ng/mL'
    category: 'number'
    conditions_string: """
	>> 偏低

	>> 偏高
    """
  }
  {
    _id  : "280000000000000000000024"
    name : '人绒毛膜促性腺激素'
    byname : ['血清人绒毛膜促性腺激素β亚单位']
    abbr : 'β-HCG'
    lt   : '0.0'
    ut   : '3.1'
    unit : 'μg/L'
    category: 'number'
    conditions_string: """
  	>> 偏低
  
      	>> 偏高
    """
  }
  {
    _id  : "280000000000000000000025"
    name : '三碘原氨酸'
    abbr : 'T3'
    lt   : '0.7'
    ut   : '2.4'
    unit : 'ng/mL'
    category: 'number'
    conditions_string: """
	>> 偏低

	>> 偏高
    """
  }
  {
    _id  : "280000000000000000000026"
    name : '游离三碘原氨酸'
    abbr : 'FT3'
    lt   : '1.89'
    ut   : '5.91'
    unit : 'pg/mL'
    category: 'number'
    conditions_string: """
       >> 偏低

	>> 偏高
    """
  }
  {
    _id  : "280000000000000000000027"
    name : '甲状腺素'
    abbr : 'T4'
    lt   : '43'
    ut   : '134'
    unit : 'ng/mL'
    category: 'number'
    conditions_string: """
	>> 偏低

	>> 偏高
    """
  }
  {
    _id  : "280000000000000000000028"
    name : '游离甲状腺素'
    abbr : 'FT4'
    lt   : '11.5'
    ut   : '22.7'
    unit : 'pg/mL'
    category: 'number'
    conditions_string: """
	>> 偏低

	>> 偏高
    """
  }
  {
    _id  : "280000000000000000000029"
    name : '促甲状腺激素'
    abbr : 'TSH'
    lt   : '0.5'
    ut   : '5.0'
    unit : 'uIU/mL'
    category: 'number'
    conditions_string: """
	>> 偏低

	>> 偏高
    """
  }
  {
    _id  : "280000000000000000aaaa29"
    name : '甲状腺球蛋白抗体'
    byname : ['抗甲状腺球蛋白抗体']
    abbr : 'TGAb'
    lt   : '0'
    ut   : '115'
    unit : 'KU/L'
    # default:'阴性'
    category : 'number'
    conditions_string: """
	>> {甲状腺球蛋白抗体}偏高
    """
  }
  {
    _id  : "280000000000000000bbbb29"
    name : '甲状腺过氧化物酶抗体'
    byname : ['抗甲状腺过氧化物酶抗体']
    abbr : 'TPOAb'
    lt   : '0'
    ut   : '34'
    unit : 'KU/L'
    # default:'阴性'
    category : 'number'
    conditions_string: """
	>> {甲状腺过氧化物酶抗体偏高}偏高
    """
  }
  {
    _id  : "280000000000000000000030"
    name : '睾酮'
    abbr : 'T'
    lt   : "if sex is '男' then 1.6 else 0.1"
    ut   : "if sex is '男' then 10.0 else 2.3"
    unit : 'ng/mL'
    category: 'number'
    conditions_string: """
	>> 偏低

	>> 偏高
    """
  }
  {
    _id : "280000000000000000000031"
    name : '泌乳素'
    abbr : 'PRL'
    lt   : "if sex is '男' then 75 else 65"
    ut   : "if sex is '男' then 350 else 660"
    unit : 'uIU/mL'
    category: 'number'
    conditions_string: """
	>> 偏低

	>> 偏高
    """
  }
  {
    _id : "280000000000000000000032"
    name : '促卵泡生成素'
    abbr : 'FSH'
    lt   : ''
    ut   : ''
    unit : 'mIU/mL'
    sex  : '女' 
    category: 'number'
    conditions_string: """
	>> 偏低

	>> 偏高
    """
  }
  {
    _id : "280000000000000000000033"
    name : '促黄体生成素'
    abbr : 'LH'
    lt   : ''
    ut   : ''
    unit : 'mIU/mL'
    sex  : '女'
    category: 'number'
    conditions_string: """
	>> 偏低

	>> 偏高
    """
  }
  {
    _id  : "280000000000000000000034"
    name : '孕酮'
    abbr : 'P'
    lt   : ''
    ut   : ''
    unit : 'ng/ml'
    category: 'number'
    conditions_string: """
	>> 偏低

	>> 偏高
    """
  }
  {
    _id  : "280000000000000000000035"
    name : '雌二醇'
    abbr : 'E2'
    lt   : "if sex is '男' then 11.0 else 15.0"
    ut   : "if sex is '男' then 159.0 else 249.0"
    unit : "pg/mL"
    category: 'number'
    conditions_string: """
	>> 偏低

	>> 偏高
    """
  }
  {
    _id  : "280000000000000000000036"
    name : '梅毒螺旋体抗体'
    default:'阴性'
    category: 'text'
    conditions_string: """
    >> 阳性
    """
  }
  {
    _id  : "280000000000000000000037"
    name : '人免疫缺陷病毒抗体'
    abbr : '抗-HIV'
    category : 'number'
    conditions_string : """
    >> 阳性
    """
  }
  {
    _id  : "280000000000000000000038"
    name : '幽门螺旋杆菌抗体'
    abbr : 'HP'
    default:'阴性'
    category : 'text'
    conditions_string : """
    >> 阳性
    >> {幽门螺旋杆菌抗体阳性}+
    """
  }
  {
    _id  : "2800000000000000000aaa39"
    name : '甲肝抗体'
    byname : ['甲型肝炎抗体IgM']
    abbr : 'HAV'
    default:'阴性'
    category : 'number'
    conditions_string : """
    >> 阳性
    >> 弱阳性
    >> {甲肝抗体阳性}+
    >> {甲肝抗体弱阳性}+-
    """
  }
  {
    _id  : "2800000000000000000aaa40"
    name : '丙肝抗体'
    abbr : 'HCV'
    default:'阴性'
    category : 'number'
    conditions_string : """
    >> 阳性
    >> 弱阳性
    >> {丙肝抗体阳性}+
    >> {丙肝抗体弱阳性}+-
    """
  }
  {
    _id  : "2800000000000000000aaa41"
    name : '丁肝抗体'
    abbr : 'HDV'
    default:'阴性'
    category : 'number'
    conditions_string : """
    >> 阳性
    >> 弱阳性
    >> {丁肝抗体阳性}+
    >> {丁肝抗体弱阳性}+-
    """
  }
  {
    _id  : "2800000000000000000aaa42"
    name : '戊肝抗体'
    abbr : 'HEV'
    default:'阴性'
    category : 'number'
    conditions_string : """
    >> 阳性
    >> 弱阳性
    >> {戊肝抗体阳性}+
    >> {戊肝抗体弱阳性}+-
    """
  }
  {
    _id  : "2800000000000000000aaa43"
    name : '磷状上皮细胞癌抗原'
    abbr : 'SCCA'
    lt   : '0'
    ut   : '1.5'
    unit : 'μg/L'
    category : 'number'
    conditions_string : """
    """
  }
  {
    _id  : "2802013101500000000aaa44"
    name : '人胃蛋白酶原Ⅰ'
    abbr : ''
    lt   : '70'
    ut   : '200'
    category : 'number'
    conditions_string : """
       >> 偏低

       >> 偏高
    """
  }
  {
    _id  : "2802013101501000000aaa44"
    name : '人胃蛋白酶原Ⅱ'
    abbr : ''
    lt   : '1'
    ut   : '100'
    category : 'number'
    conditions_string : """
       >> 偏低

       >> 偏高
    """
  }
  {
    _id  : "2800000000000000000aaa44"
    name : '人胃蛋白酶原Ⅰ/Ⅱ'
    abbr : ''
    lt   : '3'
    ut   : '100'
    category : 'number'
    conditions_string : """
       >> 偏低

       >> 偏高
    """
  }
  {
    _id  : "2800000000000000000aaa45"
    name : '肿瘤特异性生长因子'
    abbr : ''
    lt   : '0'
    ut   : '64'
    unit : 'U/L'
    category : 'number'
    conditions_string : """
       >> 偏低

       >> 偏高
    """
  }
  #{
  #  _id  : "2800000000000000000aaa46"
  #  name : '细胞角质蛋白'
  #  abbr : 'CYFRA21-1'
  #  lt   : '0.0'
  #  ut   : '3.3'
  #  unit : 'ng/mL'
  #  category : 'number'
  #  conditions_string : """
  #     >> 偏低
  #
  #     >> 偏高
  #  """
  #}
  {
    _id : "2800000000000000000bbb47"
    name : '人乳头瘤病毒'
    abbr: 'HPV'
    unit : "级"
    sex : '女'
    category: 'number'
    conditions_string: """
    """
  }
  {
    _id : "280201310290000000000001"
    name : 'POA'
    lt   : '0.00'
    ut   : '18.60'
    unit : "mg/L"
    category: 'number'
    conditions_string: """
       >> 偏低

       >> 偏高
    """
  }
  {
    _id : "280201310290000000000002"
    name : 'NMP-22'
    lt   : '0.00'
    ut   : '10.00'
    unit : "U/ml"
    category: 'number'
    conditions_string: """
       >> 偏低

       >> 偏高
    """
  }
  {
    _id : "280201310300000000000001"
    name : '弓形体抗体IgM'
    abbr : 'TOX-IgM'
    category: 'number'
    conditions_string: """
       >> 阳性
    """
  }
  {
    _id : "280201404120000000000001"
    name : 'β2微球蛋白'
    abbr : 'β2-MG'
    lt   : '1.0'
    ut   : '3.0'
    unit : "mg/L"
    category: 'number'
    conditions_string: """
       >> 偏高
       >> 偏低
    """
  }
  {
    _id : "280201404120000000000002"
    name : '组织多肽特异性抗原'
    abbr : 'TPA'
    lt   : '0'
    ut   : '130'
    unit : "U/L"
    category: 'number'
    conditions_string: """
       >> 偏高
    """
  }
]

# 两对半项目单独处理，单独纸，与其它项目合并规则并不相同；
# 在总检中也不需要出现乙肝两对半项目。
