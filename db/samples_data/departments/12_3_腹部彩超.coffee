# 科室属性结构

# 科室编号
_id : "700000000000000000000000"
# 科室显示顺序
order            : 13
# 科室名称
name             : '腹部彩超'
# 科室类型（临床类型或者实验室类型）[clinic|laboratory]
category             : 'clinic'
# 图片所放位置
image_path:        './fubucaichao.svg'
# 门牌号
door_number: ['108','210']
# 房间名称
door_name: '腹部彩超'
references:['内科','外科']
# 项目
items         : [
  {
    # 项目编号
    _id : "700000000000000000000001"
    # 项目名称
    name : '肝'
    # 类型
    category: 'text'
    # 小结与建议
    conditions_string: """
                # 脂肪肝

                >> 轻度脂肪肝

                >> 中度脂肪肝

                >> 重度脂肪肝

                >> 不均匀性脂肪肝

                >> [肝岛]肝岛？cm × ？cm

                # 形态或实质回声异常

                >> 肝脏强回声

                >> 肝脏回声不均匀

                >> 肝内回声略增粗、欠均匀

                >> 肝脏低回声

                >> 肝脏回声异常

                >> 肝纤维化

                >> 肝硬化

                >> ［肝脏肿大］肝脏肿大左叶厚？cm，右叶最大斜径？cm

                >> 肝左叶显示不清

                >> 肝脏显示不清

                >> 酒精性肝损害

                >> 药物性肝损害

                >> 慢性血吸虫肝

                >> 肝吸虫病

                >> [肝内高回声团块]肝内高回声团块，肝、脾肿大（高雪氏病不除外）

                # 静脉异常

                >> [门静脉增宽]门静脉增宽？cm

                >> [门静脉栓塞]门静脉栓塞？cm

                >> 门静脉海绵样变

                >> 肝静脉增宽（平均宽度>1.2cm）（淤血性肝病）

                >> 肝静脉增宽、下腔静脉增宽、波动减弱（右心功能不全）

                >> 下腔静脉栓塞（布-加氏综合征）

                >> 胃底静脉曲张

                >> 脐静脉开放

                # 占位性病变

                >> [肝内实性肿物]肝内实性肿物？cm×？cm

                >> [肝血管瘤]肝血管瘤直径？cm

                >> [肝脏毛细血管瘤]肝脏毛细血管瘤直径？cm

                >> [肝脏海绵状血管瘤]肝脏海绵状血管瘤？cm×？cm

                >> [肝腺瘤]肝腺瘤？cm×？cm

                >> [肝脏局灶性结节性增生]肝脏局灶性结节性增生？cm×？cm

                >> [肝癌]肝癌？cm×？cm

                >> [肝转移病灶]肝转移病灶？cm×？cm

                >> [肝母细胞瘤]肝母细胞瘤？cm×？cm

                >> [肝内囊实性肿物]肝内囊实性肿物？cm×？cm

                >> [肝包虫囊肿]肝包虫囊肿？cm×？cm

                >> [肝囊肿]肝囊肿直径？cm

                >> 多囊肝

                >> 微泡型多囊肝

                >> [肝内囊性肿物]肝内囊性肿物？cm×？cm

                # 肝内钙化结石

                >> [肝内钙化灶]肝内钙化灶？cm×？cm

                >> 肝内小胆管钙化

                # 其他

                >> 肝癌术后

                >> 肝脏切除术后

                >> 肝脏弥漫性改变

                >> 其他
                """
  }
  {
    # 项目编号
    _id : "700000000000000000000002"
    # 项目名称
    name : '胆'
    # 类型
    category: 'text'
    # 小结与建议
    conditions_string: """
                # 胆囊

                >> 胆囊显示不清

                >> 胆总管显示不清晰

                >> 餐后胆囊

                >> 胆囊切除术后

                >> [胆囊增大]胆囊增大（横径＞3.5cm）

                >> [胆囊壁增厚]胆囊壁增厚（＞3mm）

                >> 胆囊（大量、少量）沉积物

                >> 胆囊壁毛糙

                >> 胆囊壁模糊

                >> 禁食性胆汁淤滞

                >> 团块状黏稠胆汁

                >> 胆囊絮状沉积物

                >> 胆囊碎屑状沉积物

                >> 胆囊内出血

                >> 胆囊小、胆汁未充盈

                # 胆囊炎

                >> 急性胆囊炎

                >> 慢性胆囊炎

                # 胆囊结石

                >> [胆囊结石]胆囊结石直径？cm

                >> [胆囊多发结石]胆囊多发结石？cm至？cm

                >> 胆囊充满型结石

                >> 胆囊颈部结石嵌顿

                >> 胆囊少量泥沙状结石

                >> [钙化胆囊]钙化胆囊（瓷器样胆囊）

                # 增生性胆囊疾病

                >> 胆囊附壁结晶

                >> [胆囊壁胆固醇沉着症]胆囊壁胆固醇沉着症（胆固醇性息肉）

                >> 胆囊（局限型、节段型、弥漫型）腺肌增生症

                # 胆囊隆起性病变

                >> [胆囊息肉]胆囊息肉？cm

                >> [胆囊实性肿物]胆囊实性肿物？cm至？cm

                >> [胆囊癌]胆囊癌？cm×？cm

                # 胆道疾病

                >> [胆总管实性肿物]胆总管实性肿物？cm×？cm

                >> [胆总管增宽]胆总管增宽？cm

                >> [胆总管扩张]胆总管扩张？cm

                >> [胆总管结石]胆总管结石？cm

                >> [肝内胆管增宽]肝内胆管增宽？cm

                >> [肝内胆管结石]肝内胆管结石？cm

                >> 胆总管异物

                >> 胆道蛔虫

                >> 胆总管、肝内胆管积气

                >> 硬化性胆管炎

                >> 化脓性胆管炎

                >> 胆管癌

                # 胆囊先天性畸形

                >> 褶皱胆囊

                >> 双胆囊

                >> 先天性胆囊缺如

                >> [胆囊憩室]胆囊憩室直径？cm

                >> 肝内胆囊

                >> 游离胆囊
                
                备注游离胆囊：游离胆囊（系膜胆囊、异位胆囊）

                # 先天性胆管疾病

                >> [先天性胆总管囊状扩张]先天性胆总管囊状扩张宽？cm

                >> [先天性肝内胆管囊状扩张]先天性肝内胆管囊状扩张宽？cm

                >> 先天性胆道闭锁

                # 其他

                >> 胆汁淤积

                >> 胆囊萎缩

                >> 肝门部胆管增宽

                >> 胆囊体积小

                >> 胆囊回声异常

                >> 其他
                """
  }
  {
    # 项目编号
    _id : "700000000000000000000003"
    # 项目名称
    name : '胰'
    # 类型
    category: 'text'
    # 小结与建议
    conditions_string: """
                # 胰腺弥漫性病变

                >> 胰腺不均质改变

                >> 胰腺酒精性损害

                >> 胰腺脂肪浸润

                # 胰腺炎症性病变

                >> [急性胰腺炎]急性胰腺炎胰体厚？cm

                >> [慢性胰腺炎]慢性胰腺炎胰体厚？cm

                >> [慢性局限性胰腺炎]慢性局限性胰腺炎胰体厚？cm

                >> [自身免疫性胰腺炎]自身免疫性胰腺炎胰体厚？cm

                # 胰腺占位性病变

                >> [胰腺囊性肿物]胰腺囊性肿物直径？cm

                >> [胰腺囊实性肿物]胰腺囊实性肿物直径？cm

                >> [胰腺实性肿物]胰腺实性肿物直径？cm

                >> [胰腺囊肿]胰腺囊肿直径？cm

                >> 先天性多囊胰腺

                >> [胰腺包虫囊肿]胰腺包虫囊肿直径？cm

                >> [假性胰腺囊肿]假性胰腺囊肿？cm×？cm

                >> [胰腺囊腺癌]胰腺囊腺癌？cm×？cm

                >> [胰腺癌]胰腺癌？cm×？cm

                >> [壶腹周围癌]壶腹周围癌？cm×？cm

                # 胰腺管病变

                >> [胰腺管增宽]胰腺管增宽？cm

                >> [胰腺管结石]胰腺管结石直径？cm

                >> [胰腺管实性肿物]胰腺管实性肿物？cm×？cm

                # 其他

                >> 胃肠胀气、胰腺显示不清

                >> 胰腺回声异常

                >> 其他
                """
  }
  {
    # 项目编号
    _id : "700000000000000000000004"
    # 项目名称
    name : '脾'
    # 类型
    category: 'text'
    # 小结与建议
    conditions_string: """
                # 形态异常

                >> [脾大]脾大，厚？cm

                >> [脾缩小]脾缩小，小于？cm

                >> 脾厚

                >> 脾未显示

                # 脾先天性异常

                >> [副脾]副脾直径？cm

                >> 先天性脾缺如

                >> 先天性多脾综合征

                >> 游走脾

                # 脾占位性病变

                >> [脾实性肿物]脾实性肿物？cm×？cm

                >> [脾囊实性肿物]脾囊实性肿物？cm×？cm

                >> [脾囊肿]脾囊肿？cm

                >> 多囊脾

                >> [脾皮样囊肿]脾皮样囊肿？cm×？cm

                >> [脾假性囊肿]脾假性囊肿？cm×？cm

                >> [脾包虫囊肿]脾包虫囊肿？cm×？cm

                >> [脾血管瘤]脾血管瘤？cm×？cm

                >> [脾错构瘤]脾错构瘤？cm×？cm

                >> [脾转移病灶]脾转移病灶？cm×？cm

                # 脾良性局灶性病变

                >> [脾结核]脾结核？cm×？cm

                >> [脾脓肿]脾脓肿？cm×？cm

                >> [脾梗死]脾梗死？cm×？cm

                >> 脾内密集钙化点

                # 脾破裂

                >> [脾内血肿]脾内血肿？cm×？cm

                >> [脾包膜下积液]脾包膜下积液（血肿）？cm×？cm

                # 脾血管病变

                >> 脾静脉血栓

                >> 脾门静脉曲张

                >> [脾假性动脉瘤]脾假性动脉瘤？cm×？cm

                # 其他

                >> 脾切除术

                >> 其他
                """
  }
  {
    # 项目编号
    _id : "700000000000000000000005"
    # 项目名称
    name : '肾'
    # 类型
    category: 'text'
    # 小结与建议
    conditions_string: """
                # 形态、实质或髓质异常

                >> [肾增大]（左、右、双）肾增大？cm×？cm

                >> [肾缩小]（左、右、双）肾缩小？cm×？cm

                >> 双肾弥漫性病变

                >> 双肾老年性改变、弥漫性病变均不除外

                >> （左、右、双）肾实质回声增强

                >> （左、右）肾切除术后

                # 肾先天性反常

                >> 先天性（左、右）肾缺如

                >> （左、右、双）肾发育不全

                >> 异位肾

                >> （左侧、右侧、双侧）重复肾

                >> 双侧分叶肾

                >> （左、右、双）肾叶发育异常

                >> （左、右、双）肾旋转反常

                >> [U型融合肾]U型融合肾（马蹄肾）

                >> [左肾静脉压迫]左肾静脉压迫（胡桃夹现象）

                >> （左肾、右肾）双肾盂

                # 肾下垂

                >> （左、右、双）肾轻度下垂

                >> （左、右、双）肾中度下垂

                >> （左、右、双）肾重度下垂

                >> （左侧、右侧，双侧）游走肾

                # 肾占位性病变

                >> [肾实性肿物]（左、右、双）肾实性肿物？cm×？cm

                >> [肾囊性肿物]（左、右、双）肾囊性肿物？cm×？cm

                >> [肾囊实性肿物]（左、右、双）肾囊实性肿物？cm×？cm

                >> [肾囊肿]（左、右、双）肾囊肿直径？cm

                >> [多发性肾囊肿]（左、右、双）多发性肾囊肿直径？cm至？cm

                >> [多房性肾囊肿]（左、右、双）多房性肾囊肿？cm×？cm

                >> [肾多囊性发育异常]（左、右、双）肾多囊性发育异常直径？cm

                >> [多囊肾]（左、右、双）多囊肾

                >> [肾包虫囊肿]（左、右、双）肾包虫囊肿？cm×？cm

                >> [囊性肾肿瘤]（左、右、双）囊性肾肿瘤？cm×？cm

                >> 肾脏错构瘤

                >> 肾输尿管囊肿

                # 肾实质病变

                >> 肾实质弥漫性病变

                >> 急性肾功能不全

                >> 慢性肾功能不全

                >> （左、右、双）肾盂黄色肉芽肿性肾炎

                >> （左、右、双）肾脓肿

                >> （左、右、双）肾周围炎与肾周围脓肿

                >> （左、右、双）肾结核

                # 肾损伤

                >> （左、右、双）肾破裂

                >> （左、右、双）肾包膜下血肿

                >> （左、右、双）肾包膜下尿外渗

                # 肾内强回声病变

                >> [肾结石]（左、右、双）肾结石？cm至？cm

                >> （左、右、双）肾椎体内微小结晶物

                >> （左、右、双）肾锥体乳头部微小结晶物

                >> （左、右、双）肾钙质沉积症

                >> （左、右、双）肾钙化灶

                >> （左、右、双）肾内（单发、多发）结晶物

                >> （左、右、双）肾实质内钙化灶

                >> （左、右、双）肾窦壁局灶性纤维化

                >> （左、右、双）肾结核性钙化

                >> [肾钙乳性囊肿]（左、右、双）肾钙乳性囊肿直径？cm

                >> [海绵肾]（左侧、右侧、双侧）海绵肾（肾髓质囊肿）

                >> （左、右、双）肾回声异常

                # 肾积水

                >> [肾盂轻度积水]（左、右、双）肾盂轻度积水，宽？cm

                >> [中度肾积水]（左、右、双）肾中度积水？cm×？cm

                >> [重度肾积水]（左、右、双）肾重度积水？cm×？cm

                >> [肾上腺实性肿物]（左、右、双）肾上腺实性肿物？cm×？cm

                # 其他

                >> 肾盏扩张

                >> 肾皮质钙化

                >> 肾移植

                >> 肾上腺皮质腺瘤

                >> 双肾皮质稍薄

                >> （左、右、双）肾低回声区

                >> （左、右、双）肾未显示

                >> （左、右、双）肾结构不清晰

                >> 其他
                """
  }
  {
    # 项目编号
    _id : "700000000000000000000006"
    # 项目名称
    name : '前列腺'
    sex : '男'
    # 类型
    category: 'text'
    # 小结与建议
    conditions_string: """
                # 前列腺囊肿

                >> [前列腺囊肿]前列腺囊肿？cm

                >> [滞留性囊肿]滞留性囊肿？cm

                >> [苗勒管囊肿]苗勒管囊肿？cm

                >> [射精管囊肿]射精管囊肿？cm

                >> [前列腺小结石]前列腺（少量、大量）小结石

                >> 前列腺结节

                >> 前列腺钙化灶

                >> 前列腺钙化

                # 前列腺炎

                >> [急性前列腺炎]急性前列腺炎？cm×？cm×？cm

                >> [慢性前列腺炎]慢性前列腺炎？cm×？cm×？cm

                >> 前列腺回声不均匀
 
                >> 前列腺强回声区

                # 前列腺增大

                >> [前列腺轻度增大]前列腺轻度增大$，横径＞？cm$

                >> [前列腺增大增生]前列腺增大增生$，横径＞？cm$

                >> [前列腺实性结节]前列腺实性结节，直径？cm

                >> [前列腺尿道结石]前列腺尿道结石直径？cm

                >> 前列腺（轻度、中度、重度）增生伴钙化

                # 其他

                >> 前列腺显示不清

                >> 前列腺术后

                >> 其他
                """
  }
  {
    # 项目编号
    _id : "700000000000000000000007"
    # 项目名称
    name : '子宫附件'
    # 性别
    sex : '女'
    # 类型
    category: 'text'
    # 小结与建议
    conditions_string: """
                # 子宫

                >> 子宫（前壁、后壁、浆膜下）肌瘤

                >> 子宫肌瘤钙化
                该症状是暂时性的

                >> 子宫腺肌症

                >> 绝经后子宫

                >> 老年性子宫

                >> 子宫增大

                >> 子宫萎缩

                >> 子宫偏小

                >> 双子宫

                >> 纵隔子宫

                >> 早孕

                >> 宫腔内回声异常

                >> 子宫壁增厚

                >> 宫腔积液

                >> 子宫形态饱满

                # 子宫颈

                >> 宫颈纳氏囊肿

                >> 宫颈多发囊肿

                >> 宫颈息肉

                >> 宫颈肥大

                >> 宫颈内见节育器回声

                >> 宫颈切除

                # 子宫内膜

                >> 子宫内膜增厚

                >> 子宫内膜息肉

                >> 子宫内膜回声不均

                # 附件与卵巢

                >> （左侧、右侧、双侧）附件囊性肿物

                >> （左侧、右侧、双侧）卵泡囊肿

                >> （左侧、右侧、双侧）附件囊实性肿物

                >> （左侧、右侧、双侧）附件实性肿物

                >> 双侧附件显示不清

                >> （左侧、右侧、双侧）卵巢囊性肿物

                >> （左侧、右侧、双侧）卵巢巧克力囊肿

                >> （左侧、右侧、双侧）卵巢囊性结节

                >> 多囊卵巢

                >> （左侧、右侧、双侧）卵巢术后

                >> 双侧卵巢显示不清

                >> （左侧、右侧、双侧）附件区回声异常

                # 其他

                >> 子宫切除术后

                >> 子宫切除术后，双附件区未见异常

                >> 膀胱充盈欠佳

                >> 宫内环正常

                >> 宫内节育器下移

                >> 盆腔游离液

                >> 盆腔积液

                >> 盆腔囊肿

                >> 盆腔静脉曲张

                >> 盆腔内回声异常

                >>（左侧、右侧、双侧）卵巢未探及

                >> 其他
                """
  }
  {
    # 项目编号
    _id : "700000000000000000000008"
    # 项目名称
    name : '其他'
    # 类型
    category: 'text'
    # 小结与建议
    conditions_string: """
                >> [腹水]（大量、少量）腹水，下腹水厚？cm

                >> [腹腔实性肿物]腹腔实性肿物？cm×？cm

                >> [腹腔囊实性肿物]腹腔囊实性肿物？cm×？cm

                >> [腹膜后实性肿物]腹膜后实性肿物？cm×？cm

                >> [腹膜后囊实性肿物]腹膜后囊实性肿物？cm×？cm

                >> [腹腔、腹膜后增大淋巴结]腹腔、腹膜后增大淋巴结？cm×？cm

                >> 浅表性胃炎

                >> 其他
                """
  }
  {
    # 项目编号
    _id : "7000000000000000000000a9"
    # 项目名称
    name : '心脏'
    # 类型
    category: 'text'
    # 小结与建议
    conditions_string: """
                >> 室间隔增粗

                >> 静脉曲张

                >> 舒张功能减低

                >> 肺动脉瓣返流束

                >> 主动脉瓣返流

                >> 二尖瓣轻度返流

                >> 心律不齐

                >> 左心室缩小

                >> 其他
                """
  }
]
