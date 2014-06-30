fs = require 'fs'
_  = require 'underscore'
moment = require 'moment'

module.exports = (models, bcm) ->
  console.log bcm[0]
  net = require 'net'
  tcp_buffer = ''
  separator = String.fromCharCode('0x0D') + String.fromCharCode('0x1C') + String.fromCharCode('0x0D')
  {Record} = models
  sb = String.fromCharCode 0x0B
  sd = String.fromCharCode 0x0D

  server = net.createServer (stream) ->
    stream.setEncoding 'utf8'
    stream.addListener 'connect', ->
      console.log 'connected'
    stream.addListener 'data', (data) ->
      console.log 'on data'
      tcp_buffer += data
      fs.appendFileSync('income.bin', data)
      while (idx = tcp_buffer.indexOf(separator)) isnt -1
        message = tcp_buffer.substr 0, idx
        message = message.replace (new RegExp(String.fromCharCode(0x0D), "g")), "\r\n"
        pattern1 = /MSH\|[^\|]*\|[^\|]*\|[^\|]*\|[^\|]*\|[^\|]*\|[^\|]*\|[^\|]*\|([^\|]*)\|([^\|]*)\|[^\|]*\|[^\|]*\|[^\|]*\|[^\|]*\|[^\|]*\|[^\|]*\|[^\|]*\|/
        identity = message.match(pattern1)[1]
        num = message.match(pattern1)[2]
        if identity is 'ORU^R01'
          pattern2 = /OBR\|[\d]*\|\|([^\|]*)\|[^\|]*\|\|[^\|]*\|[^\|]*\|[^\|]*\|[^\|]*\|[^\|]*\|[^\|]*\|[^\|]*\|[^\|]*\|[^\|]*\|[^\|]*\|[^\|]*\|[^\|]*\|[^\|]*\|[^\|]*\|[^\|]*\|[^\|]*\|[^\|]*\|[^\|]*\|[^\|]*\|[^\|]*\|[^\|]*\|[^\|]*\|([^\|]*)\|[^\|]*\|[^\|]*\|[^\|]*\|([^\|]*)\r\n/
          check_data = message.match(pattern2)
          console.log check_data, 'check_data'
          sample_id = check_data[1]
          console.log sample_id, 'sample_id'
          barcode   = sample_id.substring(0, 8)
          audit     = check_data[2]
          doctor    = check_data[3]
          respond = """
                    MSH|^~\\&|LIS||||#{moment().format('YYYYMMDDHHmmss')}||ACK^R01|1|P|2.3.1||||||UNICODE
                    MSA|AA|#{num}
                    """
          respond = sb + respond.split('\n').join(sd) + separator
          if audit and doctor
            result =
              barcode: barcode
              entries: []
            pattern3 = /OBX\|[\d]*\|NM\|[^\|]*\^([^\|\^]*)\^[^\|]*\|[^\|]*\|([^\|]*)\|([^\|]*)\|([^\|\-]*)-([^\|\-]*)\|[^\|]*\w\|[^\|]*\|[^\|]*\|\w/g
            while match = pattern3.exec(message)
              item =
                name: match[1]
                value: match[2]
                unit: match[3]
                lt: match[4]
                ut: match[5]
              result.entries.push item
            do (result, doctor, num) ->
              console.log result.barcode, 'barcode: begin'
              found_unaudit = _.any result.entries , (item) -> item.value is '*'
              if not found_unaudit
                found_WBC  = _.find result.entries , (item) -> item.name is 'WBC'
                found_NEU1 = _.find result.entries , (item) -> item.name is 'NEU%'
                if found_WBC?.value >= 4.0 and found_WBC?.value <= 10.0 and found_NEU1?.value <= 60
                  found_LYM1 = _.find result.entries , (item) -> item.name is 'LYM%'
                  if found_LYM1?.value > 20
                    found_LYM2 = _.find result.entries , (item) -> item.name is 'LYM#'
                    found_NEU2 = _.find result.entries , (item) -> item.name is 'NEU#'
                    found_MON1 = _.find result.entries , (item) -> item.name is 'MON%'
                    found_MON2 = _.find result.entries , (item) -> item.name is 'MON#'
                    minus_num = (found_LYM1?.value - 20) * (20/35)
                    found_LYM1.value = String((parseFloat(found_LYM1.value) - minus_num).toFixed(2)) if found_LYM1
                    found_LYM2.value = String((found_WBC.value * (found_LYM1.value/100)).toFixed(2)) if found_WBC and found_LYM1
                    found_NEU1.value = String((parseFloat(found_NEU1.value) + (minus_num * 0.91111)).toFixed(2)) if found_LYM1 and minus_num
                    found_NEU2.value = String((found_WBC.value * (found_NEU1.value/100)).toFixed(2)) if found_WBC and found_NEU1
                    found_MON1.value = String((parseFloat(found_MON1.value) + (minus_num * 0.08999)).toFixed(2)) if found_MON1 and minus_num
                    found_MON2.value = String((found_WBC.value * (found_MON1.value/100)).toFixed(2)) if found_WBC and found_MON1
                Record.import_single_record_entries result, '血常规', doctor, (error, according_items) ->
                  console.log 'result', JSON.stringify result
                  stream.write(respond, 'utf8')
                  if error
                    console.error error
                  else if not according_items
                    console.log result.barcode, 'barcode: after1'
                    console.log "样本编号为" + result.barcode + "的项目数据导入不成功！"
                  else
                    console.log result.barcode, 'barcode: after2'
                    console.log "样本编号为" + result.barcode + "的项目数据导入成功！"
              else
                stream.write(respond, 'utf8')
          else
            console.log respond, 'unaudit'
            stream.write(respond, 'utf8')
        else if identity is 'ORM^O01'
          pattern4 = /ORC\|[^\|]*\|[^\|]*\|([^\|]*)\|[^\|]*\|[^\|]*/
          sample_id = message.match(pattern4)[1]
          console.log sample_id, 'sample_id'
          barcode = sample_id.substring(0, 8)
          console.log barcode, 'searchbefore: barcode'
          do (barcode, num) ->
            Record.findOne({barcode: barcode})
            .select('profile')
            .exec (error, record) ->
              console.log record, 'searchafter: record'
              if error
                respond = """
                          MSH|^~\\&|LIS||||#{moment().format('YYYYMMDDHHmmss')}||ORR^O02|1|P|2.3.1||||||UNICODE
                          MSA|AR|#{num}
                          """
                console.log respond, 'respond'
                stream.write(sb + respond.split('\n').join(sd) + separator, 'utf8')
                fs.appendFileSync('outcome.bin', sb + respond.split('\n').join(sd) + separator)
              else if not sample_id.trim()
                respond = """
                          MSH|^~\\&|LIS||||#{moment().format('YYYYMMDDHHmmss')}||ORR^O02|1|P|2.3.1||||||UNICODE
                          MSA|AA|#{num}
                          PID|1||#{sample_id}^^^^MR||^name|||男
                          ORC|AF|#{sample_id}|||
                          OBR|1|#{sample_id}||||||||||||||||||||||||||||||
                          OBX|1|IS|08001^Take Mode^99MRC||A||||||F
                          OBX|2|IS|08002^Blood Mode^99MRC||W||||||F
                          OBX|3|IS|08003^Test Mode^99MRC||CBC+DIFF||||||F
                          OBX|4|IS|01002^Ref Group^99MRC||||||||F
                          """
                respond = respond.split('\n').join(sd)
                stream.write(sb + respond + separator,'utf8')
                fs.appendFileSync('outcome.bin', sb + respond.split('\n').join(sd) + separator)
              else if not record
                #respond = """
                #          MSH|^~\\&|LIS||||#{moment().format('YYYYMMDDHHmmss')}||ORR^O02|1|P|2.3.1||||||UNICODE
                #          MSA|AR|#{num}||||204
                #          ORC|AF|#{sample_id}|||
                #          OBR|1|#{sample_id}||||||||||||||||||||||||||||||
                #          OBX|1|IS|08001^Take Mode^99MRC||A||||||F
                #          OBX|2|IS|08002^Blood Mode^99MRC||W||||||F
                #          OBX|3|IS|08003^Test Mode^99MRC||CBC||||||F
                #          OBX|4|IS|01002^Ref Group^99MRC||||||||F
                #          """
                respond = """
                          MSH|^~\\&|LIS||||#{moment().format('YYYYMMDDHHmmss')}||ORR^O02|1|P|2.3.1||||||UNICODE
                          MSA|AA|#{num}
                          PID|1||#{sample_id}^^^^MR||^Invalid|||
                          ORC|AF|#{sample_id}|||
                          OBR|1|#{sample_id}||||||||||||||||||||||||||||||
                          OBX|1|IS|08001^Take Mode^99MRC||A||||||F
                          OBX|2|IS|08002^Blood Mode^99MRC||W||||||F
                          OBX|3|IS|08003^Test Mode^99MRC||CBC+DIFF||||||F
                          OBX|4|IS|01002^Ref Group^99MRC||||||||F
                          """
                console.log respond, 'respond'
                stream.write(sb + respond.split('\n').join(sd) + separator, 'utf8')
                #console.log '没有编号为' + barcode + '的样本！'
                console.log '没有编号为' + barcode + '的样本！'
                fs.appendFileSync('outcome.bin', sb + respond.split('\n').join(sd) + separator)
              else if record
                respond = """
                          MSH|^~\\&|LIS||||#{moment().format('YYYYMMDDHHmmss')}||ORR^O02|1|P|2.3.1||||||UNICODE
                          MSA|AA|#{num}
                          PID|1||#{sample_id}^^^^MR||^#{record.profile.name}|||#{record.profile.sex}
                          ORC|AF|#{sample_id}|||
                          OBR|1|#{sample_id}||||||||||||||||||||||||||||||
                          OBX|1|IS|08001^Take Mode^99MRC||A||||||F
                          OBX|2|IS|08002^Blood Mode^99MRC||W||||||F
                          OBX|3|IS|08003^Test Mode^99MRC||CBC+DIFF||||||F
                          OBX|4|IS|01002^Ref Group^99MRC||||||||F
                          """
                if record.profile.age in ['#', 0]
                  respond = respond.split('\n').join(sd)
                else
                  respond = respond.split('\n').join(sd) + sd + "OBX|5|NM|30525-0^Age^LN||#{record.profile.age}|yr|||||F"
                console.log respond, 'respond'
                stream.write(sb + respond + separator,'utf8')
                fs.appendFileSync('outcome.bin', sb + respond.split('\n').join(sd) + separator)
        tcp_buffer = tcp_buffer.substr idx + separator.length
    stream.addListener 'end', ->
      console.log 'disconnected'
  server.listen bcm[0], '0.0.0.0'
