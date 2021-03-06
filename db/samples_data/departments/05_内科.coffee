# 科室属性结构

# 科室编号
_id : "110000000000000000000000"
# 科室显示顺序
order            : 5
# 科室名称
name             : '内科'
# 科室类型（临床类型或者实验室类型）[clinic|laboratory]
category             : 'clinic'
# 图片所放位置
image_path:        './neike.svg'
# 门牌号
door_number: ['107','207']
# 房间名称
door_name: '内科'
# 相关联的科室
references: ['腹部彩超','心电图','外科']
# 项目
items         : [
  {
    # 项目编号
    _id : "110000000000000000000001"
    # 项目名称
    name : '病史'
    # 类型
    category: 'text'
    # 小结与建议
    # 1、单独加一个键，来定义该项目语音播报使用的关键字；
    # 2、# 主述 + 症状
    # 3、每个症状前加关键字：主述高血压史已服药
    conditions_string: """
                # 心脑血管疾病

                >> 高血压史已服药

                >> 高血压史未服药

                >> 心律失常史

                >> 心律不齐史

                >> 房颤史

                >> 胸闷史

                >> 冠心病史

                >> 心肌梗塞史

                >> 心包炎术后

                >> 预激综合症史

                >> 心肌炎史

                >> 心绞痛史

                >> 冠状动脉搭桥术后

                >> 冠状动脉支架术后

                >> 心脏起搏器植入术后

                >> 脑卒中史

                >> 脑膜瘤术后

                >> 脑动脉硬化史

                >> 脑梗史

                >> 脑血栓史

                >> 脑出血史

                >> 风心病史
                
                >> 心脏瓣膜病史
                
                >> 二尖瓣狭窄史
                
                >> 二尖瓣关闭不全史
                
                >> 主动脉瓣狭窄史
                
                >> 主动脉瓣关闭不全史
                
                >> 三尖瓣狭窄史
                
                >> 三尖瓣关闭不全史

                >> 心动过速史

                >> 肺动脉瓣狭窄史
                
                >> 先天性心脏病史
                
                >> 动脉导管未闭史
                
                >> 房间隔缺损史
                
                >> 室间隔缺损史
                
                >> 法乐氏四联症史
                
                >> 法乐氏三联症史
                
                >> 卵圆孔未闭史

                >> 心动过缓史

                >> 帕金森病

                # 内分泌疾病

                >> 肝功能异常史

                >> 肝局灶结节术后

                >> 胆囊切除史

                >> 胆囊炎史

                >> 胆囊结石史

                >> 胆囊炎史

                >> 胆囊息肉史

                >> 糖尿病史

                >> 糖耐量受损史

                >> 空腹血糖受损史

                >> 血脂异常史

                >> 脂肪肝史

                >> 澳抗阳性

                >> 肝癌术后

                >> 甲亢史

                >> 甲低史

                >> 痛风史
                
                >> 亚急性甲状腺炎史
                
                >> 单纯性甲状腺肿大史

                >> 每日稀便异常史

                # 呼吸系统疾病

                >> 肺炎史

                >> 气胸术后

                >> 哮喘史

                >> 慢性支气管炎史

                >> 支气管哮喘史

                >> 慢性阻塞性肺病

                >> 左肺渗出性胸膜炎史

                >> 肺栓塞史

                >> 肺结节病史

                >> 肺结核史
                
                >> 支气管扩张史
                
                >> 肺脓肿史
                
                >> 结核性胸膜炎史

                >> 肺癌术后

                # 消化道疾病

                >> 食道溃疡史

                >> 胃溃疡史

                >> 胃炎史

                >> 胃痛史

                >> 胃癌术后

                >> 胃息肉术后

                >> 反流性食管炎史

                >> 慢性胰腺炎史

                >> 慢性胃炎史

                >> 慢性消化道溃疡史

                >> 消化系统慢性疾病史

                >> 肠炎史

                >> 肝炎史

                >> 肝血管瘤史

                >> 肝硬化史
                
                >> 胃大部分切除术后

                >> 十二指肠球部溃疡穿孔术后

                >> 肠功能紊乱史
      
                >> 结肠癌术后

                # 泌尿系统疾病

                >> 泌尿系统感染史

                >> 前列腺疾病史

                >> 泌尿系统肿瘤史

                >> 泌尿系统结石史

                >> 急性肾小球肾炎史
                
                >> 慢性肾小球肾炎史
                
                >> IgA肾炎史
                
                >> 狼疮肾炎史

                >> 肾病综合征史
                
                >> 肾炎史

                >> 肾盂炎史

                >> 肾上腺功能减退

                >> 慢性肾功能不全史

                >> 肌酐升高史
                
                >> 尿毒症史

                >> 高尿酸血症史

                >> 高血压肾病史
                
                >> 糖尿病肾病史
                
                >> 过敏性紫癜肾炎

                >> 慢性肾衰史

                >> 高尿酸血症史

                >> 肾癌术后

                >> 膀胱癌术后

                # 其他

                >> 纤维瘤术后

                >> 低钾血症史

                >> 风湿病史
                
                >> 风湿性关节炎史
                
                >> 类风湿性关节炎史
                
                >> 强直性脊柱炎史
                
                >> 血友病史
                
                >> 过敏性紫癜史
                
                >> 原发性血小板减少性紫癜史
                
                >> 真性红细胞增多症史
                
                >> 巨幼红细胞贫血史
                
                >> 缺铁性贫血史
                
                >> 再生障碍性贫血

                >> 神经衰弱史

                >> 直肠癌术后

                >> 病毒性心肌炎史

                >> 吸烟史

                >> 饮酒史

                >> 早搏

                >> 物质过敏

                >> 甲肝史

                >> 乙肝携带者

                >> 切口术后

                >> 红细胞增多症史

                >> 伤寒史

                >> 肌肉肿瘤史

                >> 甲状腺术后

                >> 乳腺癌史

                >> 主动脉瓣钙化换瓣后

                >> 主动脉瓣置换术后

                >> 胸腺瘤术后

                >> （慢性、急性）阑尾炎史

                >> 面瘫

                >> 晕厥史

                >> 脾脏术后

                >> 系统性红斑狼疮

                >> 其他
                """
  }
  {
    # 项目编号
    _id : "110000000000000000000002"
    # 项目名称
    name : '胸廓'
    # 类型
    category: 'text'
    # 小结与建议
    conditions_string: """
                >> 胸廓变形

                >> 胸廓畸形

                >> 桶状胸

                >> 扁平胸

                >> 鸡胸

                >> 漏斗胸

                >> 胸廓不对称

                >> 胸廓陈旧瘢痕

                >> 其他
                """
  }
  {
    # 项目编号
    _id : "110000000000000000000003"
    # 项目名称
    name : '心率'
    lt   : '60'
    ut   : '100'
    unit : '次/分'
    # 类型
    category: 'number'
    # 小结与建议
    conditions_string: """
                >> 值 < 40  -> 心动过缓（心率每分钟40次以下）

                >> 值 < 60  -> 心动过缓（心率每分钟40到60次）

                >> 值 > 100 -> 心动过速
                """
  }
  {
    # 项目编号
    _id : "110000000000000000000004"
    # 项目名称
    name : '心律'
    # 类型
    category: 'text'
    # 小结与建议
    conditions_string: """
                >> 心律不齐

                >> 偶发早搏（≤5次/分钟）

                >> 频发早搏（＞5次/分钟）

                >> 心房纤颤

                >> 期外收缩

                >> 其他
                """
  }
  {
    # 项目编号
    _id : "110000000000000000000005"
    # 项目名称
    name : '心音'
    # 类型
    category: 'text'
    # 小结与建议
    conditions_string: """
                >> 二尖瓣Ⅱ级收缩期（柔和的、粗糙的）吹风样杂音

                >> 二尖瓣≥Ⅲ级收缩期（柔和的、粗糙的）吹风样杂音

                >> 二尖瓣舒张期隆隆样杂音

                >> 三尖瓣Ⅱ级收缩期杂音

                >> 三尖瓣≥Ⅲ级收缩期吹风样杂音

                >> 三尖瓣舒张期隆隆样杂音

                >> 主动脉瓣区收缩期杂音

                >> 主动脉瓣区舒张期杂音

                >> 肺动脉瓣区收缩期杂音

                >> 肺动脉瓣区舒张期杂音
                
                >> 主动脉瓣第二听诊区收缩期杂音
                
                >> 主动脉瓣第二听诊区舒张期杂音
                
                >> 心包摩擦音

                >> 心尖区舒张期杂音

                >> 心尖区（收缩期、舒张期）杂音 

                >> 心音强

                >> 心音亢进

                >> 心音异常

                >> 其他
                """
  }
  {
    # 项目编号
    _id : "110000000000000000000006"
    # 项目名称
    name : '心界'
    # 类型
    category: 'text'
    # 小结与建议
    conditions_string: """
                >> 心浊音界缩小

                >> 心浊音界增大

                >> 其他
                """
  }
  {
    # 项目编号
    _id : "110000000000000000000007"
    # 项目名称
    name : '腹部'
    # 类型
    category: 'text'
    # 小结与建议
    conditions_string: """
                >> [腹部触及包块]（上腹部、左上腹、左下腹、右上腹、右下腹、脐周、下腹部、剑突下）触及包块?cm×?cm，(表面光滑、表面粗糙)，（质地柔韧、质地偏硬），（有压痛、无压痛），（可移动、不可移动）（可搏动、不可搏动）

                >> 上腹部压痛

                >> 左上腹压痛

                >> 左下腹压痛

                >> 右上腹压痛

                >> 右下腹压痛

                >> 脐周压痛

                >> 下腹部压痛

                >> 剑突下压痛
                
                >> [腹部反跳痛]（上腹部、左上腹、左下腹、右上腹、右下腹、脐周、下腹部、剑突下）反跳痛

                >> 阑尾区压痛

                >> 腹部陈旧性疤痕

                >> 胃压痛

                >> 腹胀明显

                >> 其他
                """
  }
  {
    # 项目编号
    _id : "110000000000000000000008"
    # 项目名称
    name : '肺部'
    # 类型
    category: 'text'
    # 小结与建议
    conditions_string: """
                >> （左上、左下、右上、右中、右下、双）肺呼吸音增强

                >> （左上、左下、右上、右中、右下、双）肺呼吸音减弱
                
                >> （左上、左下、右上、右中、右下、双）肺呼吸音粗糙
                
                >> （左上、左下、右上、右中、右下、双）肺管状呼吸音
                
                >> （左上、左下、右上、右中、右下）肺呼吸音消失

                >> （左上、左下、右上、右中、右下、双）肺部听诊干啰音

                >> （左上、左下、右上、右中、右下、双）肺部听诊湿啰音

                >> （左上、左下、右上、右中、右下、双）肺部叩诊过清音

                >> （左上、左下、右上、右中、右下、双）肺部叩诊实音

                >> （左上、左下、右上、右中、右下、双）肺部叩诊浊音
                
                >> （左侧、右侧、双侧）胸膜摩擦音

                >> 其他
                """
  }
  {
    # 项目编号
    _id : "110000000000000000000009"
    # 项目名称
    name : '肝脏'
    # 类型
    category: 'text'
    # 小结与建议
    conditions_string: """
                >> ［肝大］肝大，肋下?cm，（质软、质韧、质硬），（表面光滑、表面不均匀）

                >> 肝区压痛

                >> 肝区叩击痛

                >> 丙肝史

                >> 肝脏切除术后

                >> 其他
                """
  }
  {
    # 项目编号
    _id : "110000000000000000000010"
    # 项目名称
    name : '胆囊'
    # 类型
    category: 'text'
    # 小结与建议
    conditions_string: """
                >> 莫非氏征阳性

                >> 其他
                """
  }
  {
    # 项目编号
    _id : "110000000000000000000011"
    # 项目名称
    name : '脾脏'
    # 类型
    category: 'text'
    # 小结与建议
    conditions_string: """
                >> ［脾大］脾大，肋下?cm，（质软、质硬），（表面光滑、表面不均匀）

                >> 脾切除术后

                >> 其他
                """
  }
  {
    # 项目编号
    _id : "110000000000000000000012"
    # 项目名称
    name : '肾脏'
    # 类型
    category: 'text'
    # 小结与建议
    conditions_string: """
                >> （左、右、双）肾区叩击痛

                >> （左、右、双）肾切除

                >> 其他
                """
  }
  {
    # 项目编号
    _id : "110000000000000000000013"
    # 项目名称
    name : '周围血管'
    # 类型
    category: 'text'
    # 小结与建议
    conditions_string: """
                >> 动脉杂音
    
                >> 甲状腺侧叶连续性杂音
                
                >> 上腹部或腰背部收缩期杂音
                
                >> 周围血管症
                
                >> 枪击音
                
                >> Duroziez双重杂音
                
                >> 毛细血管搏动症

                >> 四肢浮肿

                >> 其他
                """
  }
  {
    # 项目编号
    _id : "110000000000000000000014"
    # 项目名称
    name : '神经系统'
    # 类型
    category: 'text'
    # 小结与建议
    conditions_string: """
                >> 膝腱反射减弱

                >> 膝腱反射增强

                >> 膝腱反射亢进

                >> 肢体活动受限、肌力减弱

                >> 帕金森氏病

                >> 其他
                """
  }
]

