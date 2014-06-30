_       = require 'underscore'

# TODO: 记录生化仪盘号与标本号。

# TODO: 在签名中解构。
module.exports = (models, biochem) ->
  {Record} = models
  # ## 生化仪参数配置

  # ### 设备端口与主机
  tba_host = biochem[0]
  tba_port = biochem[1]
  
  connect_str = "ws://192.168.1.33:5331/"
  
  console.log tba_port, tba_host
  # ## 生化项目矩阵
  #
  # 项目矩阵根据TBA120FR控制台中*Assay**界面配置，注意：
  #
  #   1. 确保与**科室及项目设置**中**生化检验**科室中所含项目
  #   之缩写相同（大小写不敏感）。
  #   2. 确保与TBA120FR控制台中**Assay**界面位置相同。
  #
  #   TODO：启动时检查名称设置是否正确，若不正确（如：不匹配、
  #   有歧义等），则给予相应提示。
  assay_matrix = [
    "ALT"   , "AST"  , "ALP"   , "GGT"   , "CHE"   , "TP"    , "ALB"   , "TBA"   , "GLU"   , "UA"
    "CRE"   , "BUN"  , "LDH"   , "HBDH"  , "CK"    , "CKMB"  , "CHO"   , "TG"    , "HDL"   , "LDL"
    "CRP"   , "ASO"  , "RF"    , "HCY"   , "ApoA1" , "ApoB"  , "Lp-a"  , "HbA1c" , "TBIL"  , "DBIL"
    "Ca"    , "Mg"   , "PHOS"  , "Zn"    , "Fe"    , "MALB"
  ]

  xueqing_items = [] # ['CA', 'PHOS', 'MG', 'FE', 'ZN']

  assay_matrix = _.map assay_matrix, (item) -> item.toUpperCase()

  # ## 建立鲁棒TCP套接

  # TODO: TCP套接部分存在缺陷。
  #

  # 启动时自动连接生化仪。
  WebSocketClient = require('websocket').client
  client = new WebSocketClient()
  #client.connect "ws://#{tba_host}:#{tba_port}/", 'echo-protocol'
  client.connect connect_str

  heart_beat = null

  # 响应socket的`error`事件，以保证本模块无异常抛出。
  client.on 'connectFailed', (error) ->
    console.error 'Connection to TBA120FR Error', error.toString()
    clearInterval heart_beat
    setTimeout ->
      client.connect connect_str
    , 2000

  # 连接建立后，保持0.5秒的心跳包，在tcp失去连接时，帮助serwebproxy及早
  # 释放连接。serwebproxy设置为1秒超时。具体配置如下：
  #
  #     comm_ports=1
  #     comm_baud=9600
  #     comm_databits=8
  #     comm_stopbits=1
  #     comm_parity=none
  #     timeout=1
  #     net_protocol1=0
  #     net_port1=5331
  client.on 'connect', (connection) ->
    console.log 'open'
    console.log 'Connection to TBA120FR Established.'
    heart_beat = setInterval ->
      if connection.connected
        connection.sendUTF String.fromCharCode 0x20
    , 500

    connection.on 'error', (error) ->
      console.log "Connection Error: " + error.toString()

    # 遇网络故障，TBA120FR端的serwebproxy可能因超时关闭。网络恢复后，socket亦
    # 被关闭。首先停止心跳包发送，并于1秒后重新建立socket连接。
    connection.on 'close', ->
      console.log 'close'
      console.log 'Connection to TBA120FR Dropped, Reconnecting After 1 Second.'
      clearInterval heart_beat
      setTimeout ->
        client.connect connect_str
      , 2000


    # ## TBA120FR协议

    # Spec Page 9.
    stx = String.fromCharCode 0x02
    etx = String.fromCharCode 0x03
    etb = String.fromCharCode 0x17
    ack = String.fromCharCode 0x06

    # ### 底层消息拆分
    #
    # 从TCP套接字积累数据，并拆包成为TBA120FR消息。
    # Spec Page 10.
    buffer = ''
    connection.on 'message', (data) ->
      if data.type is 'utf8'
        buffer += '' + data.utf8Data
      console.log buffer, 'buffer'
      message_pattern_string = "#{stx}(.*)#{etx}"
      message_pattern_regexp = new RegExp message_pattern_string, "g"
      while result = message_pattern_regexp.exec buffer
        if result[1].length > 1
          func = result[1].substr 0, 2
          data = result[1].substr 2
          console.log 'func', func, 'data', data
          do (func, data) ->
            process_message func, data
      buffer = buffer.replace message_pattern_regexp, ''

    # ### 消息应答
    #
    # Spec Page 11.
    ack_message = "#{stx}#{ack}#{etx}"
    send_ack = ->
      if connection.connected
        connection.sendUTF ack_message

    # ### 消息处理
    #
    # 根据不同的消息动作，分派至不同处理方法。
    process_message = (func, data) ->
      console.log 'process_message', data
      send_ack()
      switch func
        # 项目检索消息，见Page 14.
        when "Q "
          send_order data
        # 检验结果传送
        when "R "
          save_result data

    # ### 发送订单
    #
    send_order = (data) ->

      console.log 'data', data
      match = /\d{4}((.{20})(.{7}))/.exec data
      sample_id = match[2].trim()
      barcode = sample_id.substring(0,8)
      code    = sample_id.substring(8,10)
      id_group = match[1]
      # 盘号与孔位
      disk_number = match[3].substr(0, 4)
      on_disk_position = match[3].substr(4)
      plate_hole = disk_number + '盘' + on_disk_position + '孔'
      do (code, barcode, plate_hole, id_group) ->
        Record.retrieve_biochemical code, barcode, plate_hole, (error, record) ->
          if error or not record
            if connection.connected
              connection.sendUTF "#{stx}O #{id_group}#{etb}#{etb}#{etx}"
            console.error error
          else
            # Order Group
            # 订单项目，根据客人健康档案获取。
            console.log JSON.stringify assaies = record.biochemical_items
            console.log "assaies.length:", assaies.length
            assaies = assaies.map((a) -> "   #{assay_matrix.indexOf(a?.toUpperCase()) + 1}1").map((b) -> b.substr b.length - 5).join('')
            order_group = "  1#{assaies}#{etb}"

            # Patient Group
            # 患者数据
            ordered = new Array(13).join('0')
            name = barcode
            name_length = Buffer.byteLength name
            name = name + new Array(43 - name_length).join(' ')
            pid = sample_id + new Array(21 - sample_id.length).join(' ')
            # 根据客人性别调整
            sex = if record.profile.sex is '男' then 'M' else 'F'
            birth = record.profile.birthday?.replace /[-]/g, ''
            # 根据客人年龄调整
            birth = birth or (if ((new Date).getFullYear() - record.profile.age) then ((new Date).getFullYear() - record.profile.age + '0101') else '        ')
            # 科室信息
            location = new Array(33).join(' ')
            # 医生信息
            doctor = new Array(33).join(' ')
            # 备注信息
            comment = new Array(33).join(' ')
            patient_group = "#{ordered}#{name}#{pid}#{sex}#{birth}#{location}#{doctor}#{comment}#{etb}"

            # Final Message
            order = "#{stx}O #{id_group}#{order_group}#{patient_group}#{etx}"
            console.log order.length, order
            if connection.connected
              console.log 'order', order
              connection.sendUTF order

    #send_order '000100007771            0010001'

    # ### 保存检验结果

    # 检验结果接收后，解析样本编号与各个化验项结果。见Page 22。
    #
    result_group_regexp = /.{4}(.{20}).{22}(.*)/
    save_result = (result) ->
      console.log 'result', result
      result = result.split(etb)[0]
      match = result.match(result_group_regexp)
      sample_id = match[1].trim()
      barcode = sample_id.substr(0, sample_id.length-2)
      return if barcode is '00000080'
      entries = match[2]
      number_of_entries = entries.length / 15
      results = while number_of_entries--
        entry = entries[(number_of_entries) * 15...(number_of_entries * 15 + 15)]
        {
          name: assay_matrix[1 * entry[0...4].trim() - 1]
          value: entry[4...10].trim()
        }
      results = results.filter (item) -> item.value and not isNaN(item.value*1) 
      # 总蛋白TP
      tp = _.find results, (item) -> item.name.toUpperCase() is 'TP'
      # 白蛋白ALB
      alb = _.find results, (item) -> item.name.toUpperCase() is 'ALB'
      if tp?.value*1 <= alb?.value*1
        results = results.filter (item) -> item.name.toUpperCase() not in ['TP', 'ALB']
      # 总胆红素TBIL
      tbil = _.find results, (item) -> item.name.toUpperCase() is 'TBIL'
      # 直接胆红素DBIL
      dbil = _.find results, (item) -> item.name.toUpperCase() is 'DBIL'
      if tbil?.value*1 <= dbil?.value*1
        results = results.filter (item) -> item.name.toUpperCase() not in ['TBIL', 'DBIL']

      #glu = _.find results, (item) -> item.name.toUpperCase() is 'GLU'
      #glu.value = glu.value*0.9

      #tg = _.find results, (item) -> item.name.toUpperCase() is 'TG'
      #tg.value = tg.value*0.75

      #hdl = _.find results, (item) -> item.name.toUpperCase() is 'HDL'
      #hdl.value = hdl.value*0.85

      bio_results = results.filter (item) -> item.name.toUpperCase()
      biochemical_result =
        barcode: barcode
        entries: bio_results
      console.log 'biochemical', JSON.stringify biochemical_result
      do (biochemical_result) ->
        if bio_results.length
          Record.import_single_record_entries biochemical_result, '生化检验', '李晓明', (error, according_items) ->
            return console.error error if error
            console.log "样本编号为" + biochemical_result.barcode + "的生化项目导入成功！"
