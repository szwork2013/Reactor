#
# *  BarCode Coder Library (BCC Library)
# *  BCCL Version 2.0
# *    
# *  Porting : jQuery barcode plugin 
# *  Version : 2.0.2
# *   
# *  Date  : March 01, 2011
# *  Author  : DEMONTE Jean-Baptiste <jbdemonte@gmail.com>
# *            HOUREZ Jonathan
# *             
# *  Web site: http://barcode-coder.com/
# *  dual licence :  http://www.cecill.info/licences/Licence_CeCILL_V2-fr.html
# *                  http://www.gnu.org/licenses/gpl.html
# *
# *  Managed :
# *     
# *    standard 2 of 5 (std25)
# *    interleaved 2 of 5 (int25)
# *    ean 8 (ean8)
# *    ean 13 (ean13)   
# *    code 11 (code11)
# *    code 39 (code39)
# *    code 93 (code93)
# *    code 128 (code128)  
# *    codabar (codabar)
# *    msi (msi)
# *    datamatrix (datamatrix)
# *  
# *  Output :
# *   
# *    CSS (compatible with any browser)
# *    SVG inline (not compatible with IE)
# *    BMP inline (not compatible with IE)      
# *    CANVAS html 5 (not compatible with IE)
# * 
# *  Changelog :
# *    
# *    1.1 - 2009/05/26 
# *      std25 fixed
# *    1.2 - 2009/09/10
# *      parseInt replaced by intval (nb: parseInt("09") => 0)
# *      code128 fixed (C Table analyse) - Thanks to Vadim for the bug report
# *    1.3 - 2009/09/26
# *      bmp and svg image renderer added   
# *    1.3.2 - 2009/10/03
# *      manage int and string formated values for barcode width/height
# *    1.3.3 - 2009/10/17
# *      no wait document is ready to add plugin
# *    2.0.1 - 2010/09/05
# *      CSS fixed to print easily - Thanks to Léo West for this fix
# *      datamatrix added - Jonathan Hourez join developper team
# *      canvas renderer added    
# *      code cleaned
# *      fontSize become an integer 
# *    2.0.2 - 2011-03-01
# *     integration to jquery updated
# *     table B of code 128 fixed (\\ instead of \) thanks to jmcarson
# 
barcode =
  settings:
    barWidth: 1
    barHeight: 50
    moduleSize: 5
    showHRI: true
    addQuietZone: true
    marginHRI: 5
    bgColor: "#FFFFFF"
    color: "#000000"
    fontSize: 10
    output: "css"
    posX: 0
    posY: 0

  intval: (val) ->
    type = typeof (val)
    if type is "string"
      val = val.replace(/[^0-9-.]/g, "")
      val = parseInt(val * 1, 10)
      return (if isNaN(val) or not isFinite(val) then 0 else val)
    (if type is "number" and isFinite(val) then Math.floor(val) else 0)

  i25: # std25 int25
    encoding: ["NNWWN", "WNNNW", "NWNNW", "WWNNN", "NNWNW", "WNWNN", "NWWNN", "NNNWW", "WNNWN", "NWNWN"]
    compute: (code, crc, type) ->
      unless crc
        code = "0" + code  unless code.length % 2 is 0
      else
        code = "0" + code  if (type is "int25") and (code.length % 2 is 0)
        odd = true
        v = undefined
        sum = 0
        i = code.length - 1

        while i > -1
          v = barcode.intval(code.charAt(i))
          return ("")  if isNaN(v)
          sum += (if odd then 3 * v else v)
          odd = not odd
          i--
        code += ((10 - sum % 10) % 10).toString()
      code

    getDigit: (code, crc, type) ->
      code = @compute(code, crc, type)
      return ("")  if code is ""
      result = ""
      i = undefined
      j = undefined
      if type is "int25"
        
        # Interleaved 2 of 5
        
        # start
        result += "1010"
        
        # digits + CRC
        c1 = undefined
        c2 = undefined
        i = 0
        while i < code.length / 2
          c1 = code.charAt(2 * i)
          c2 = code.charAt(2 * i + 1)
          j = 0
          while j < 5
            result += "1"
            result += "1"  if @encoding[c1].charAt(j) is "W"
            result += "0"
            result += "0"  if @encoding[c2].charAt(j) is "W"
            j++
          i++
        
        # stop
        result += "1101"
      else if type is "std25"
        
        # Standard 2 of 5 is a numeric-only barcode that has been in use a long time. 
        # Unlike Interleaved 2 of 5, all of the information is encoded in the bars; the spaces are fixed width and are used only to separate the bars.
        # The code is self-checking and does not include a checksum.
        
        # start
        result += "11011010"
        
        # digits + CRC
        c = undefined
        i = 0
        while i < code.length
          c = code.charAt(i)
          j = 0
          while j < 5
            result += "1"
            result += "11"  if @encoding[c].charAt(j) is "W"
            result += "0"
            j++
          i++
        
        # stop
        result += "11010110"
      result

  ean:
    encoding: [["0001101", "0100111", "1110010"], ["0011001", "0110011", "1100110"], ["0010011", "0011011", "1101100"], ["0111101", "0100001", "1000010"], ["0100011", "0011101", "1011100"], ["0110001", "0111001", "1001110"], ["0101111", "0000101", "1010000"], ["0111011", "0010001", "1000100"], ["0110111", "0001001", "1001000"], ["0001011", "0010111", "1110100"]]
    first: ["000000", "001011", "001101", "001110", "010011", "011001", "011100", "010101", "010110", "011010"]
    getDigit: (code, type) ->
      
      # Check len (12 for ean13, 7 for ean8)
      len = (if type is "ean8" then 7 else 12)
      code = code.substring(0, len)
      return ("")  unless code.length is len
      
      # Check each digit is numeric
      c = undefined
      i = 0

      while i < code.length
        c = code.charAt(i)
        return ("")  if (c < "0") or (c > "9")
        i++
      
      # get checksum
      code = @compute(code, type)
      
      # process analyse
      result = "101" # start
      if type is "ean8"
        
        # process left part
        i = 0

        while i < 4
          result += @encoding[barcode.intval(code.charAt(i))][0]
          i++
        
        # center guard bars
        result += "01010"
        
        # process right part
        i = 4

        while i < 8
          result += @encoding[barcode.intval(code.charAt(i))][2]
          i++
      else # ean13
        # extract first digit and get sequence
        seq = @first[barcode.intval(code.charAt(0))]
        
        # process left part
        i = 1

        while i < 7
          result += @encoding[barcode.intval(code.charAt(i))][barcode.intval(seq.charAt(i - 1))]
          i++
        
        # center guard bars
        result += "01010"
        
        # process right part
        i = 7

        while i < 13
          result += @encoding[barcode.intval(code.charAt(i))][2]
          i++
      # ean13
      result += "101" # stop
      result

    compute: (code, type) ->
      len = (if type is "ean13" then 12 else 7)
      code = code.substring(0, len)
      sum = 0
      odd = true
      i = code.length - 1
      while i > -1
        sum += ((if odd then 3 else 1)) * barcode.intval(code.charAt(i))
        odd = not odd
        i--
      code + ((10 - sum % 10) % 10).toString()

  msi:
    encoding: ["100100100100", "100100100110", "100100110100", "100100110110", "100110100100", "100110100110", "100110110100", "100110110110", "110100100100", "110100100110"]
    compute: (code, crc) ->
      if typeof (crc) is "object"
        if crc.crc1 is "mod10"
          code = @computeMod10(code)
        else code = @computeMod11(code)  if crc.crc1 is "mod11"
        if crc.crc2 is "mod10"
          code = @computeMod10(code)
        else code = @computeMod11(code)  if crc.crc2 is "mod11"
      else code = @computeMod10(code)  if crc  if typeof (crc) is "boolean"
      code

    computeMod10: (code) ->
      i = undefined
      toPart1 = code.length % 2
      n1 = 0
      sum = 0
      i = 0
      while i < code.length
        if toPart1
          n1 = 10 * n1 + barcode.intval(code.charAt(i))
        else
          sum += barcode.intval(code.charAt(i))
        toPart1 = not toPart1
        i++
      s1 = (2 * n1).toString()
      i = 0
      while i < s1.length
        sum += barcode.intval(s1.charAt(i))
        i++
      code + ((10 - sum % 10) % 10).toString()

    computeMod11: (code) ->
      sum = 0
      weight = 2
      i = code.length - 1

      while i >= 0
        sum += weight * barcode.intval(code.charAt(i))
        weight = (if weight is 7 then 2 else weight + 1)
        i--
      code + ((11 - sum % 11) % 11).toString()

    getDigit: (code, crc) ->
      table = "0123456789"
      index = 0
      result = ""
      code = @compute(code, false)
      
      # start
      result = "110"
      
      # digits
      i = 0
      while i < code.length
        index = table.indexOf(code.charAt(i))
        return ("")  if index < 0
        result += @encoding[index]
        i++
      
      # stop
      result += "1001"
      result

  code11:
    encoding: ["101011", "1101011", "1001011", "1100101", "1011011", "1101101", "1001101", "1010011", "1101001", "110101", "101101"]
    getDigit: (code) ->
      table = "0123456789-"
      i = undefined
      index = undefined
      result = ""
      intercharacter = "0"
      
      # start
      result = "1011001" + intercharacter
      
      # digits
      i = 0
      while i < code.length
        index = table.indexOf(code.charAt(i))
        return ("")  if index < 0
        result += @encoding[index] + intercharacter
        i++
      
      # checksum
      weightC = 0
      weightSumC = 0
      weightK = 1 # start at 1 because the right-most character is "C" checksum
      weightSumK = 0
      i = code.length - 1
      while i >= 0
        weightC = (if weightC is 10 then 1 else weightC + 1)
        weightK = (if weightK is 10 then 1 else weightK + 1)
        index = table.indexOf(code.charAt(i))
        weightSumC += weightC * index
        weightSumK += weightK * index
        i--
      c = weightSumC % 11
      weightSumK += c
      k = weightSumK % 11
      result += @encoding[c] + intercharacter
      result += @encoding[k] + intercharacter  if code.length >= 10
      
      # stop
      result += "1011001"
      result

  code39:
    encoding: ["101001101101", "110100101011", "101100101011", "110110010101", "101001101011", "110100110101", "101100110101", "101001011011", "110100101101", "101100101101", "110101001011", "101101001011", "110110100101", "101011001011", "110101100101", "101101100101", "101010011011", "110101001101", "101101001101", "101011001101", "110101010011", "101101010011", "110110101001", "101011010011", "110101101001", "101101101001", "101010110011", "110101011001", "101101011001", "101011011001", "110010101011", "100110101011", "110011010101", "100101101011", "110010110101", "100110110101", "100101011011", "110010101101", "100110101101", "100100100101", "100100101001", "100101001001", "101001001001", "100101101101"]
    getDigit: (code) ->
      table = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%*"
      i = undefined
      index = undefined
      result = ""
      intercharacter = "0"
      return ("")  if code.indexOf("*") >= 0
      
      # Add Start and Stop charactere : *
      code = ("*" + code + "*").toUpperCase()
      i = 0
      while i < code.length
        index = table.indexOf(code.charAt(i))
        return ("")  if index < 0
        result += intercharacter  if i > 0
        result += @encoding[index]
        i++
      result

  code93:
    encoding: ["100010100", "101001000", "101000100", "101000010", "100101000", "100100100", "100100010", "101010000", "100010010", "100001010", "110101000", "110100100", "110100010", "110010100", "110010010", "110001010", "101101000", "101100100", "101100010", "100110100", "100011010", "101011000", "101001100", "101000110", "100101100", "100010110", "110110100", "110110010", "110101100", "110100110", "110010110", "110011010", "101101100", "101100110", "100110110", "100111010", "100101110", "111010100", "111010010", "111001010", "101101110", "101110110", "110101110", "100100110", "111011010", "111010110", "100110010", "101011110"]
    getDigit: (code, crc) ->
      table = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%____*" # _ => ($), (%), (/) et (+)
      c = undefined
      result = ""
      return ("")  if code.indexOf("*") >= 0
      code = code.toUpperCase()
      
      # start :  *
      result += @encoding[47]
      
      # digits
      i = 0
      while i < code.length
        c = code.charAt(i)
        index = table.indexOf(c)
        return ("")  if (c is "_") or (index < 0)
        result += @encoding[index]
        i++
      
      # checksum
      if crc
        weightC = 0
        weightSumC = 0
        weightK = 1 # start at 1 because the right-most character is "C" checksum
        weightSumK = 0
        i = code.length - 1
        while i >= 0
          weightC = (if weightC is 20 then 1 else weightC + 1)
          weightK = (if weightK is 15 then 1 else weightK + 1)
          index = table.indexOf(code.charAt(i))
          weightSumC += weightC * index
          weightSumK += weightK * index
          i--
        c = weightSumC % 47
        weightSumK += c
        k = weightSumK % 47
        result += @encoding[c]
        result += @encoding[k]
      
      # stop : *
      result += @encoding[47]
      
      # Terminaison bar
      result += "1"
      result

  code128:
    encoding: ["11011001100", "11001101100", "11001100110", "10010011000", "10010001100", "10001001100", "10011001000", "10011000100", "10001100100", "11001001000", "11001000100", "11000100100", "10110011100", "10011011100", "10011001110", "10111001100", "10011101100", "10011100110", "11001110010", "11001011100", "11001001110", "11011100100", "11001110100", "11101101110", "11101001100", "11100101100", "11100100110", "11101100100", "11100110100", "11100110010", "11011011000", "11011000110", "11000110110", "10100011000", "10001011000", "10001000110", "10110001000", "10001101000", "10001100010", "11010001000", "11000101000", "11000100010", "10110111000", "10110001110", "10001101110", "10111011000", "10111000110", "10001110110", "11101110110", "11010001110", "11000101110", "11011101000", "11011100010", "11011101110", "11101011000", "11101000110", "11100010110", "11101101000", "11101100010", "11100011010", "11101111010", "11001000010", "11110001010", "10100110000", "10100001100", "10010110000", "10010000110", "10000101100", "10000100110", "10110010000", "10110000100", "10011010000", "10011000010", "10000110100", "10000110010", "11000010010", "11001010000", "11110111010", "11000010100", "10001111010", "10100111100", "10010111100", "10010011110", "10111100100", "10011110100", "10011110010", "11110100100", "11110010100", "11110010010", "11011011110", "11011110110", "11110110110", "10101111000", "10100011110", "10001011110", "10111101000", "10111100010", "11110101000", "11110100010", "10111011110", "10111101110", "11101011110", "11110101110", "11010000100", "11010010000", "11010011100", "11000111010"]
    getDigit: (code) ->
      tableB = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
      result = ""
      sum = 0
      isum = 0
      i = 0
      j = 0
      value = 0
      
      # check each characters
      i = 0
      while i < code.length
        return ("")  if tableB.indexOf(code.charAt(i)) is -1
        i++
      
      # check firsts characters : start with C table only if enought numeric
      tableCActivated = code.length > 1
      c = ""
      i = 0
      while i < 3 and i < code.length
        c = code.charAt(i)
        tableCActivated &= c >= "0" and c <= "9"
        i++
      sum = (if tableCActivated then 105 else 104)
      
      # start : [105] : C table or [104] : B table 
      result = @encoding[sum]
      i = 0
      while i < code.length
        unless tableCActivated
          j = 0
          
          # check next character to activate C table if interresting
          j++  while (i + j < code.length) and (code.charAt(i + j) >= "0") and (code.charAt(i + j) <= "9")
          
          # 6 min everywhere or 4 mini at the end
          tableCActivated = (j > 5) or ((i + j - 1 is code.length) and (j > 3))
          if tableCActivated
            result += @encoding[99] # C table
            sum += ++isum * 99
        
        #         2 min for table C so need table B
        else if (i is code.length) or (code.charAt(i) < "0") or (code.charAt(i) > "9") or (code.charAt(i + 1) < "0") or (code.charAt(i + 1) > "9")
          tableCActivated = false
          result += @encoding[100] # B table
          sum += ++isum * 100
        if tableCActivated
          value = barcode.intval(code.charAt(i) + code.charAt(i + 1)) # Add two characters (numeric)
          i += 2
        else
          value = tableB.indexOf(code.charAt(i)) # Add one character
          i += 1
        result += @encoding[value]
        sum += ++isum * value
      
      # Add CRC
      result += @encoding[sum % 103]
      
      # Stop
      result += @encoding[106]
      
      # Termination bar
      result += "11"
      result

  codabar:
    encoding: ["101010011", "101011001", "101001011", "110010101", "101101001", "110101001", "100101011", "100101101", "100110101", "110100101", "101001101", "101100101", "1101011011", "1101101011", "1101101101", "1011011011", "1011001001", "1010010011", "1001001011", "1010011001"]
    getDigit: (code) ->
      table = "0123456789-$:/.+"
      i = undefined
      index = undefined
      result = ""
      intercharacter = "0"
      
      # add start : A->D : arbitrary choose A
      result += @encoding[16] + intercharacter
      i = 0
      while i < code.length
        index = table.indexOf(code.charAt(i))
        return ("")  if index < 0
        result += @encoding[index] + intercharacter
        i++
      
      # add stop : A->D : arbitrary choose A
      result += @encoding[16]
      result

  datamatrix:
    encoding: ["101010011", "101011001", "101001011", "110010101", "101101001", "110101001", "100101011", "100101101", "100110101", "110100101", "101001101", "101100101", "1101011011", "1101101011", "1101101101", "1011011011", "1011001001", "1010010011", "1001001011", "1010011001"]
    # 24 squares et 6 rectangular
    lengthRows: [10, 12, 14, 16, 18, 20, 22, 24, 26, 32, 36, 40, 44, 48, 52, 64, 72, 80, 88, 96, 104, 120, 132, 144, 8, 8, 12, 12, 16, 16]
    # Number of columns for the entire datamatrix
    lengthCols: [10, 12, 14, 16, 18, 20, 22, 24, 26, 32, 36, 40, 44, 48, 52, 64, 72, 80, 88, 96, 104, 120, 132, 144, 18, 32, 26, 36, 36, 48]
    # Number of rows for the mapping matrix
    mappingRows: [8, 10, 12, 14, 16, 18, 20, 22, 24, 28, 32, 36, 40, 44, 48, 56, 64, 72, 80, 88, 96, 108, 120, 132, 6, 6, 10, 10, 14, 14]
    # Number of columns for the mapping matrix
    mappingCols: [8, 10, 12, 14, 16, 18, 20, 22, 24, 28, 32, 36, 40, 44, 48, 56, 64, 72, 80, 88, 96, 108, 120, 132, 16, 28, 24, 32, 32, 44]
    # Number of data codewords for the datamatrix
    dataCWCount: [3, 5, 8, 12, 18, 22, 30, 36, 44, 62, 86, 114, 144, 174, 204, 280, 368, 456, 576, 696, 816, 1050, 1304, 1558, 5, 10, 16, 22, 32, 49]
    # Number of Reed-Solomon codewords for the datamatrix
    solomonCWCount: [5, 7, 10, 12, 14, 18, 20, 24, 28, 36, 42, 48, 56, 68, 84, 112, 144, 192, 224, 272, 336, 408, 496, 620, 7, 11, 14, 18, 24, 28]
    # Number of rows per region
    dataRegionRows: [8, 10, 12, 14, 16, 18, 20, 22, 24, 14, 16, 18, 20, 22, 24, 14, 16, 18, 20, 22, 24, 18, 20, 22, 6, 6, 10, 10, 14, 14]
    # Number of columns per region
    dataRegionCols: [8, 10, 12, 14, 16, 18, 20, 22, 24, 14, 16, 18, 20, 22, 24, 14, 16, 18, 20, 22, 24, 18, 20, 22, 16, 14, 24, 16, 16, 22]
    # Number of regions per row
    regionRows: [1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 4, 4, 4, 4, 4, 4, 6, 6, 6, 1, 1, 1, 1, 1, 1]
    # Number of regions per column
    regionCols: [1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 4, 4, 4, 4, 4, 4, 6, 6, 6, 1, 2, 1, 2, 2, 2]
    # Number of blocks
    interleavedBlocks: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 4, 4, 4, 4, 6, 6, 8, 8, 1, 1, 1, 1, 1, 1]
    # Table of log for the Galois field
    logTab: [-255, 255, 1, 240, 2, 225, 241, 53, 3, 38, 226, 133, 242, 43, 54, 210, 4, 195, 39, 114, 227, 106, 134, 28, 243, 140, 44, 23, 55, 118, 211, 234, 5, 219, 196, 96, 40, 222, 115, 103, 228, 78, 107, 125, 135, 8, 29, 162, 244, 186, 141, 180, 45, 99, 24, 49, 56, 13, 119, 153, 212, 199, 235, 91, 6, 76, 220, 217, 197, 11, 97, 184, 41, 36, 223, 253, 116, 138, 104, 193, 229, 86, 79, 171, 108, 165, 126, 145, 136, 34, 9, 74, 30, 32, 163, 84, 245, 173, 187, 204, 142, 81, 181, 190, 46, 88, 100, 159, 25, 231, 50, 207, 57, 147, 14, 67, 120, 128, 154, 248, 213, 167, 200, 63, 236, 110, 92, 176, 7, 161, 77, 124, 221, 102, 218, 95, 198, 90, 12, 152, 98, 48, 185, 179, 42, 209, 37, 132, 224, 52, 254, 239, 117, 233, 139, 22, 105, 27, 194, 113, 230, 206, 87, 158, 80, 189, 172, 203, 109, 175, 166, 62, 127, 247, 146, 66, 137, 192, 35, 252, 10, 183, 75, 216, 31, 83, 33, 73, 164, 144, 85, 170, 246, 65, 174, 61, 188, 202, 205, 157, 143, 169, 82, 72, 182, 215, 191, 251, 47, 178, 89, 151, 101, 94, 160, 123, 26, 112, 232, 21, 51, 238, 208, 131, 58, 69, 148, 18, 15, 16, 68, 17, 121, 149, 129, 19, 155, 59, 249, 70, 214, 250, 168, 71, 201, 156, 64, 60, 237, 130, 111, 20, 93, 122, 177, 150]
    # Table of aLog for the Galois field
    aLogTab: [1, 2, 4, 8, 16, 32, 64, 128, 45, 90, 180, 69, 138, 57, 114, 228, 229, 231, 227, 235, 251, 219, 155, 27, 54, 108, 216, 157, 23, 46, 92, 184, 93, 186, 89, 178, 73, 146, 9, 18, 36, 72, 144, 13, 26, 52, 104, 208, 141, 55, 110, 220, 149, 7, 14, 28, 56, 112, 224, 237, 247, 195, 171, 123, 246, 193, 175, 115, 230, 225, 239, 243, 203, 187, 91, 182, 65, 130, 41, 82, 164, 101, 202, 185, 95, 190, 81, 162, 105, 210, 137, 63, 126, 252, 213, 135, 35, 70, 140, 53, 106, 212, 133, 39, 78, 156, 21, 42, 84, 168, 125, 250, 217, 159, 19, 38, 76, 152, 29, 58, 116, 232, 253, 215, 131, 43, 86, 172, 117, 234, 249, 223, 147, 11, 22, 44, 88, 176, 77, 154, 25, 50, 100, 200, 189, 87, 174, 113, 226, 233, 255, 211, 139, 59, 118, 236, 245, 199, 163, 107, 214, 129, 47, 94, 188, 85, 170, 121, 242, 201, 191, 83, 166, 97, 194, 169, 127, 254, 209, 143, 51, 102, 204, 181, 71, 142, 49, 98, 196, 165, 103, 206, 177, 79, 158, 17, 34, 68, 136, 61, 122, 244, 197, 167, 99, 198, 161, 111, 222, 145, 15, 30, 60, 120, 240, 205, 183, 67, 134, 33, 66, 132, 37, 74, 148, 5, 10, 20, 40, 80, 160, 109, 218, 153, 31, 62, 124, 248, 221, 151, 3, 6, 12, 24, 48, 96, 192, 173, 119, 238, 241, 207, 179, 75, 150, 1]
    champGaloisMult: (a, b) -> # MULTIPLICATION IN GALOIS FIELD GF(2^8)
      return 0  if not a or not b
      @aLogTab[(@logTab[a] + @logTab[b]) % 255]

    champGaloisDoub: (a, b) -> # THE OPERATION a * 2^b IN GALOIS FIELD GF(2^8)
      return 0  unless a
      return a  unless b
      @aLogTab[(@logTab[a] + b) % 255]

    champGaloisSum: (a, b) -> # SUM IN GALOIS FIELD GF(2^8)
      a ^ b

    selectIndex: (dataCodeWordsCount, rectangular) -> # CHOOSE THE GOOD INDEX FOR TABLES
      return -1  if (dataCodeWordsCount < 1 or dataCodeWordsCount > 1558) and not rectangular
      return -1  if (dataCodeWordsCount < 1 or dataCodeWordsCount > 49) and rectangular
      n = 0
      n = 24  if rectangular
      n++  while @dataCWCount[n] < dataCodeWordsCount
      n

    encodeDataCodeWordsASCII: (text) ->
      dataCodeWords = new Array()
      n = 0
      i = undefined
      c = undefined
      i = 0
      while i < text.length
        c = text.charCodeAt(i)
        if c > 127
          dataCodeWords[n] = 235
          c = c - 127
          n++
        else if (c >= 48 and c <= 57) and (i + 1 < text.length) and (text.charCodeAt(i + 1) >= 48 and text.charCodeAt(i + 1) <= 57)
          c = ((c - 48) * 10) + ((text.charCodeAt(i + 1)) - 48)
          c += 130
          i++
        else
          c++
        dataCodeWords[n] = c
        n++
        i++
      dataCodeWords

    addPadCW: (tab, from, to) ->
      return  if from >= to
      tab[from] = 129
      r = undefined
      i = undefined
      i = from + 1
      while i < to
        r = ((149 * (i + 1)) % 253) + 1
        tab[i] = (129 + r) % 254
        i++

    calculSolFactorTable: (solomonCWCount) -> # CALCULATE THE REED SOLOMON FACTORS
      g = new Array()
      i = undefined
      j = undefined
      i = 0
      while i <= solomonCWCount
        g[i] = 1
        i++
      i = 1
      while i <= solomonCWCount
        j = i - 1
        while j >= 0
          g[j] = @champGaloisDoub(g[j], i)
          g[j] = @champGaloisSum(g[j], g[j - 1])  if j > 0
          j--
        i++
      g

    addReedSolomonCW: (nSolomonCW, coeffTab, nDataCW, dataTab, blocks) -> # Add the Reed Solomon codewords
      temp = 0
      errorBlocks = nSolomonCW / blocks
      correctionCW = new Array()
      i = undefined
      j = undefined
      k = undefined
      k = 0
      while k < blocks
        i = 0
        while i < errorBlocks
          correctionCW[i] = 0
          i++
        i = k
        while i < nDataCW
          temp = @champGaloisSum(dataTab[i], correctionCW[errorBlocks - 1])
          j = errorBlocks - 1
          while j >= 0
            unless temp
              correctionCW[j] = 0
            else
              correctionCW[j] = @champGaloisMult(temp, coeffTab[j])
            correctionCW[j] = @champGaloisSum(correctionCW[j - 1], correctionCW[j])  if j > 0
            j--
          i = i + blocks
        
        # Renversement des blocs calcules
        j = nDataCW + k
        i = errorBlocks - 1
        while i >= 0
          dataTab[j] = correctionCW[i]
          j = j + blocks
          i--
        k++
      dataTab

    getBits: (entier) -> # Transform integer to tab of bits
      bits = new Array()
      i = 0

      while i < 8
        bits[i] = (if entier & (128 >> i) then 1 else 0)
        i++
      bits

    next: (etape, totalRows, totalCols, codeWordsBits, datamatrix, assigned) -> # Place codewords into the matrix
      chr = 0 # Place of the 8st bit from the first character to [4][0]
      row = 4
      col = 0
      loop
        
        # Check for a special case of corner
        if (row is totalRows) and (col is 0)
          @patternShapeSpecial1 datamatrix, assigned, codeWordsBits[chr], totalRows, totalCols
          chr++
        else if (etape < 3) and (row is totalRows - 2) and (col is 0) and (totalCols % 4 isnt 0)
          @patternShapeSpecial2 datamatrix, assigned, codeWordsBits[chr], totalRows, totalCols
          chr++
        else if (row is totalRows - 2) and (col is 0) and (totalCols % 8 is 4)
          @patternShapeSpecial3 datamatrix, assigned, codeWordsBits[chr], totalRows, totalCols
          chr++
        else if (row is totalRows + 4) and (col is 2) and (totalCols % 8 is 0)
          @patternShapeSpecial4 datamatrix, assigned, codeWordsBits[chr], totalRows, totalCols
          chr++
        
        # Go up and right in the datamatrix
        loop
          if (row < totalRows) and (col >= 0) and (assigned[row][col] isnt 1)
            @patternShapeStandard datamatrix, assigned, codeWordsBits[chr], row, col, totalRows, totalCols
            chr++
          row -= 2
          col += 2
          break unless (row >= 0) and (col < totalCols)
        row += 1
        col += 3
        
        # Go down and left in the datamatrix
        loop
          if (row >= 0) and (col < totalCols) and (assigned[row][col] isnt 1)
            @patternShapeStandard datamatrix, assigned, codeWordsBits[chr], row, col, totalRows, totalCols
            chr++
          row += 2
          col -= 2
          break unless (row < totalRows) and (col >= 0)
        row += 3
        col += 1
        break unless (row < totalRows) or (col < totalCols)

    patternShapeStandard: (datamatrix, assigned, bits, row, col, totalRows, totalCols) -> # Place bits in the matrix (standard or special case)
      @placeBitInDatamatrix datamatrix, assigned, bits[0], row - 2, col - 2, totalRows, totalCols
      @placeBitInDatamatrix datamatrix, assigned, bits[1], row - 2, col - 1, totalRows, totalCols
      @placeBitInDatamatrix datamatrix, assigned, bits[2], row - 1, col - 2, totalRows, totalCols
      @placeBitInDatamatrix datamatrix, assigned, bits[3], row - 1, col - 1, totalRows, totalCols
      @placeBitInDatamatrix datamatrix, assigned, bits[4], row - 1, col, totalRows, totalCols
      @placeBitInDatamatrix datamatrix, assigned, bits[5], row, col - 2, totalRows, totalCols
      @placeBitInDatamatrix datamatrix, assigned, bits[6], row, col - 1, totalRows, totalCols
      @placeBitInDatamatrix datamatrix, assigned, bits[7], row, col, totalRows, totalCols

    patternShapeSpecial1: (datamatrix, assigned, bits, totalRows, totalCols) ->
      @placeBitInDatamatrix datamatrix, assigned, bits[0], totalRows - 1, 0, totalRows, totalCols
      @placeBitInDatamatrix datamatrix, assigned, bits[1], totalRows - 1, 1, totalRows, totalCols
      @placeBitInDatamatrix datamatrix, assigned, bits[2], totalRows - 1, 2, totalRows, totalCols
      @placeBitInDatamatrix datamatrix, assigned, bits[3], 0, totalCols - 2, totalRows, totalCols
      @placeBitInDatamatrix datamatrix, assigned, bits[4], 0, totalCols - 1, totalRows, totalCols
      @placeBitInDatamatrix datamatrix, assigned, bits[5], 1, totalCols - 1, totalRows, totalCols
      @placeBitInDatamatrix datamatrix, assigned, bits[6], 2, totalCols - 1, totalRows, totalCols
      @placeBitInDatamatrix datamatrix, assigned, bits[7], 3, totalCols - 1, totalRows, totalCols

    patternShapeSpecial2: (datamatrix, assigned, bits, totalRows, totalCols) ->
      @placeBitInDatamatrix datamatrix, assigned, bits[0], totalRows - 3, 0, totalRows, totalCols
      @placeBitInDatamatrix datamatrix, assigned, bits[1], totalRows - 2, 0, totalRows, totalCols
      @placeBitInDatamatrix datamatrix, assigned, bits[2], totalRows - 1, 0, totalRows, totalCols
      @placeBitInDatamatrix datamatrix, assigned, bits[3], 0, totalCols - 4, totalRows, totalCols
      @placeBitInDatamatrix datamatrix, assigned, bits[4], 0, totalCols - 3, totalRows, totalCols
      @placeBitInDatamatrix datamatrix, assigned, bits[5], 0, totalCols - 2, totalRows, totalCols
      @placeBitInDatamatrix datamatrix, assigned, bits[6], 0, totalCols - 1, totalRows, totalCols
      @placeBitInDatamatrix datamatrix, assigned, bits[7], 1, totalCols - 1, totalRows, totalCols

    patternShapeSpecial3: (datamatrix, assigned, bits, totalRows, totalCols) ->
      @placeBitInDatamatrix datamatrix, assigned, bits[0], totalRows - 3, 0, totalRows, totalCols
      @placeBitInDatamatrix datamatrix, assigned, bits[1], totalRows - 2, 0, totalRows, totalCols
      @placeBitInDatamatrix datamatrix, assigned, bits[2], totalRows - 1, 0, totalRows, totalCols
      @placeBitInDatamatrix datamatrix, assigned, bits[3], 0, totalCols - 2, totalRows, totalCols
      @placeBitInDatamatrix datamatrix, assigned, bits[4], 0, totalCols - 1, totalRows, totalCols
      @placeBitInDatamatrix datamatrix, assigned, bits[5], 1, totalCols - 1, totalRows, totalCols
      @placeBitInDatamatrix datamatrix, assigned, bits[6], 2, totalCols - 1, totalRows, totalCols
      @placeBitInDatamatrix datamatrix, assigned, bits[7], 3, totalCols - 1, totalRows, totalCols

    patternShapeSpecial4: (datamatrix, assigned, bits, totalRows, totalCols) ->
      @placeBitInDatamatrix datamatrix, assigned, bits[0], totalRows - 1, 0, totalRows, totalCols
      @placeBitInDatamatrix datamatrix, assigned, bits[1], totalRows - 1, totalCols - 1, totalRows, totalCols
      @placeBitInDatamatrix datamatrix, assigned, bits[2], 0, totalCols - 3, totalRows, totalCols
      @placeBitInDatamatrix datamatrix, assigned, bits[3], 0, totalCols - 2, totalRows, totalCols
      @placeBitInDatamatrix datamatrix, assigned, bits[4], 0, totalCols - 1, totalRows, totalCols
      @placeBitInDatamatrix datamatrix, assigned, bits[5], 1, totalCols - 3, totalRows, totalCols
      @placeBitInDatamatrix datamatrix, assigned, bits[6], 1, totalCols - 2, totalRows, totalCols
      @placeBitInDatamatrix datamatrix, assigned, bits[7], 1, totalCols - 1, totalRows, totalCols

    placeBitInDatamatrix: (datamatrix, assigned, bit, row, col, totalRows, totalCols) -> # Put a bit into the matrix
      if row < 0
        row += totalRows
        col += 4 - ((totalRows + 4) % 8)
      if col < 0
        col += totalCols
        row += 4 - ((totalCols + 4) % 8)
      unless assigned[row][col] is 1
        datamatrix[row][col] = bit
        assigned[row][col] = 1

    addFinderPattern: (datamatrix, rowsRegion, colsRegion, rowsRegionCW, colsRegionCW) -> # Add the finder pattern
      totalRowsCW = (rowsRegionCW + 2) * rowsRegion
      totalColsCW = (colsRegionCW + 2) * colsRegion
      datamatrixTemp = new Array()
      datamatrixTemp[0] = new Array()
      j = 0

      while j < totalColsCW + 2
        datamatrixTemp[0][j] = 0
        j++
      i = 0

      while i < totalRowsCW
        datamatrixTemp[i + 1] = new Array()
        datamatrixTemp[i + 1][0] = 0
        datamatrixTemp[i + 1][totalColsCW + 1] = 0
        j = 0

        while j < totalColsCW
          if i % (rowsRegionCW + 2) is 0
            if j % 2 is 0
              datamatrixTemp[i + 1][j + 1] = 1
            else
              datamatrixTemp[i + 1][j + 1] = 0
          else if i % (rowsRegionCW + 2) is rowsRegionCW + 1
            datamatrixTemp[i + 1][j + 1] = 1
          else if j % (colsRegionCW + 2) is colsRegionCW + 1
            if i % 2 is 0
              datamatrixTemp[i + 1][j + 1] = 0
            else
              datamatrixTemp[i + 1][j + 1] = 1
          else if j % (colsRegionCW + 2) is 0
            datamatrixTemp[i + 1][j + 1] = 1
          else
            datamatrixTemp[i + 1][j + 1] = 0
            datamatrixTemp[i + 1][j + 1] = datamatrix[i - 1 - (2 * (parseInt(i / (rowsRegionCW + 2))))][j - 1 - (2 * (parseInt(j / (colsRegionCW + 2))))]
          j++
        i++
      datamatrixTemp[totalRowsCW + 1] = new Array()
      j = 0

      while j < totalColsCW + 2
        datamatrixTemp[totalRowsCW + 1][j] = 0
        j++
      datamatrixTemp

    getDigit: (text, rectangular) ->
      dataCodeWords = @encodeDataCodeWordsASCII(text) # Code the text in the ASCII mode
      dataCWCount = dataCodeWords.length
      index = @selectIndex(dataCWCount, rectangular) # Select the index for the data tables
      totalDataCWCount = @dataCWCount[index] # Number of data CW
      solomonCWCount = @solomonCWCount[index] # Number of Reed Solomon CW
      totalCWCount = totalDataCWCount + solomonCWCount # Number of CW
      rowsTotal = @lengthRows[index] # Size of symbol
      colsTotal = @lengthCols[index]
      rowsRegion = @regionRows[index] # Number of region
      colsRegion = @regionCols[index]
      rowsRegionCW = @dataRegionRows[index]
      colsRegionCW = @dataRegionCols[index]
      rowsLengthMatrice = rowsTotal - 2 * rowsRegion # Size of matrice data
      colsLengthMatrice = colsTotal - 2 * colsRegion
      blocks = @interleavedBlocks[index] # Number of Reed Solomon blocks
      errorBlocks = (solomonCWCount / blocks)
      dataBlocks = (totalDataCWCount / blocks)
      @addPadCW dataCodeWords, dataCWCount, totalDataCWCount # Add codewords pads
      g = @calculSolFactorTable(errorBlocks) # Calculate correction coefficients
      @addReedSolomonCW solomonCWCount, g, totalDataCWCount, dataCodeWords, blocks # Add Reed Solomon codewords
      codeWordsBits = new Array() # Calculte bits from codewords
      i = 0

      while i < totalCWCount
        codeWordsBits[i] = @getBits(dataCodeWords[i])
        i++
      datamatrix = new Array() # Put data in the matrix
      assigned = new Array()
      i = 0

      while i < colsLengthMatrice
        datamatrix[i] = new Array()
        assigned[i] = new Array()
        i++
      
      # Add the bottom-right corner if needed
      if ((rowsLengthMatrice * colsLengthMatrice) % 8) is 4
        datamatrix[rowsLengthMatrice - 2][colsLengthMatrice - 2] = 1
        datamatrix[rowsLengthMatrice - 1][colsLengthMatrice - 1] = 1
        datamatrix[rowsLengthMatrice - 1][colsLengthMatrice - 2] = 0
        datamatrix[rowsLengthMatrice - 2][colsLengthMatrice - 1] = 0
        assigned[rowsLengthMatrice - 2][colsLengthMatrice - 2] = 1
        assigned[rowsLengthMatrice - 1][colsLengthMatrice - 1] = 1
        assigned[rowsLengthMatrice - 1][colsLengthMatrice - 2] = 1
        assigned[rowsLengthMatrice - 2][colsLengthMatrice - 1] = 1
      
      # Put the codewords into the matrix
      @next 0, rowsLengthMatrice, colsLengthMatrice, codeWordsBits, datamatrix, assigned
      
      # Add the finder pattern
      datamatrix = @addFinderPattern(datamatrix, rowsRegion, colsRegion, rowsRegionCW, colsRegionCW)
      datamatrix

  # convert a bit string to an array of array of bit char
  bitStringTo2DArray: (digit) ->
    d = []
    d[0] = []
    i = 0

    while i < digit.length
      d[0][i] = digit.charAt(i)
      i++
    d

  # svg barcode renderer
  digitToSvgRenderer: ($container, settings, digit, hri, mw, mh) ->
    lines = digit.length
    columns = digit[0].length
    width = mw * columns
    height = mh * lines
    if settings.showHRI
      fontSize = barcode.intval(settings.fontSize)
      height += barcode.intval(settings.marginHRI) + fontSize
    
    # svg header
    svg = "<svg xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\" width=\"" + width + "\" height=\"" + height + "\">"
    
    # background
    svg += "<rect width=\"" + width + "\" height=\"" + height + "\" x=\"0\" y=\"0\" fill=\"" + settings.bgColor + "\" />"
    bar1 = "<rect width=\"&W\" height=\"" + mh + "\" x=\"&X\" y=\"&Y\" fill=\"" + settings.color + "\" />"
    len = undefined
    current = undefined
    y = 0

    while y < lines
      len = 0
      current = digit[y][0]
      x = 0

      while x < columns
        if current is digit[y][x]
          len++
        else
          svg += bar1.replace("&W", len * mw).replace("&X", (x - len) * mw).replace("&Y", y * mh)  if current is "1"
          current = digit[y][x]
          len = 1
        x++
      svg += bar1.replace("&W", len * mw).replace("&X", (columns - len) * mw).replace("&Y", y * mh)  if (len > 0) and (current is "1")
      y++
    if settings.showHRI
      svg += "<g transform=\"translate(" + Math.floor(width / 2) + " 0)\">"
      svg += "<text y=\"" + (height - Math.floor(fontSize / 2)) + "\" text-anchor=\"middle\" style=\"font-family: Arial; font-size: " + fontSize + "px;\" fill=\"" + settings.color + "\">" + hri + "</text>"
      svg += "</g>"
    
    # svg footer
    svg + "</svg>"
    
  # svg 1D barcode renderer
  digitToSvg: ($container, settings, digit, hri) ->
    w = barcode.intval(settings.barWidth)
    h = barcode.intval(settings.barHeight)
    @digitToSvgRenderer $container, settings, @bitStringTo2DArray(digit), hri, w, h

  
  # svg 2D barcode renderer
  digitToSvg2D: ($container, settings, digit, hri) ->
    s = barcode.intval(settings.moduleSize)
    @digitToSvgRenderer $container, settings, digit, hri, s, s

module.exports = (datas, type, settings) ->
  digit = ""
  hri = ""
  code = ""
  crc = true
  rect = false
  b2d = false
  if typeof (datas) is "string"
    code = datas
  else if typeof (datas) is "object"
    code = (if typeof (datas.code) is "string" then datas.code else "")
    crc = (if typeof (datas.crc) isnt "undefined" then datas.crc else true)
    rect = (if typeof (datas.rect) isnt "undefined" then datas.rect else false)
  return null  if code is ""
  settings = []  if typeof (settings) is "undefined"
  for name of barcode.settings
    settings[name] = barcode.settings[name]  if settings[name] is `undefined`
  switch type
    when "std25", "int25"
      digit = barcode.i25.getDigit(code, crc, type)
      hri = barcode.i25.compute(code, crc, type)
    when "ean8", "ean13"
      digit = barcode.ean.getDigit(code, type)
      hri = barcode.ean.compute(code, type)
    when "code11"
      digit = barcode.code11.getDigit(code)
      hri = code
    when "code39"
      digit = barcode.code39.getDigit(code)
      hri = code
    when "code93"
      digit = barcode.code93.getDigit(code, crc)
      hri = code
    when "code128"
      digit = barcode.code128.getDigit(code)
      hri = code
    when "codabar"
      digit = barcode.codabar.getDigit(code)
      hri = code
    when "msi"
      digit = barcode.msi.getDigit(code, crc)
      hri = barcode.msi.compute(code, crc)
    when "datamatrix"
      digit = barcode.datamatrix.getDigit(code, rect)
      hri = code
      b2d = true
  return null if digit.length is 0
  
  # Quiet Zone
  digit = "0000000000" + digit + "0000000000"  if not b2d and settings.addQuietZone
  fname = "digitToSvg" + ((if b2d then "2D" else ""))
  barcode[fname] null, settings, digit, hri
