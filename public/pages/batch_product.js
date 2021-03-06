// Generated by CoffeeScript 1.6.3
(function() {
  var createCatalogue, process, setPageNum, set_appendix, set_mark;

  setPageNum = function(pages) {
    return $(pages).each(function(index) {
      return $(this).append("<div class='page_number' >" + (index + 1) + "</div>");
    });
  };

  set_appendix = function(pages, context) {
    return $(pages).each(function() {
      return $(this).append("<div class='fujian'>" + context + "</div>");
    });
  };

  set_mark = function(pages) {
    var mark1, mark2;
    mark1 = "<div class='zhushi'>\n<span>⊘</span>不适用项；<span>●</span>男宾已选项；<span>●</span>女宾已选项；<span>●</span>男女通用已选项；\n<span>○</span>男宾未选项；<span>○</span>女宾未选项；<span>○</span>男女通用未选项\n</div>";
    mark2 = "<div class='zhushi_p'><span>＊</span>现场自费价：非团体结算的自费宾客，可享用此优惠价格现场结算。</div>";
    return $(pages).each(function(index) {
      if ($(pages).length === 1) {
        return $(this).append(mark1 + mark2);
      } else {
        if (index === $(pages).length - 1) {
          return $(this).append(mark2);
        } else {
          return $(this).append(mark1);
        }
      }
    });
  };

  createCatalogue = function() {
    return $('.title_h1').each(function() {
      return $('.catalogue').append("<dl><dt>" + ($(this).text()) + "</dt><dd>" + ($(this).parent().parent().find('.page_number').text()) + "</dd><span></sapn></dl>");
    });
  };

  process = function(page, clone_first_row) {
    var cont, height, index, next_page, row, rows, _i, _len;
    rows = $('.row', page);
    height = parseFloat($(page).css('height'));
    for (index = _i = 0, _len = rows.length; _i < _len; index = ++_i) {
      row = rows[index];
      if ($(row).hasClass('ullist') && index !== 0) {
        $(page).after(next_page = page.cloneNode());
        $(next_page).append(rows.slice(index));
        return process(next_page, clone_first_row);
      }
      if (!($(row).position().top + $(row).outerHeight(true) > height)) {
        continue;
      }
      console.log($(row).next());
      if ($(row).prev().hasClass('group')) {
        row = $(row).prev()[0];
        index--;
      }
      $(page).after(next_page = page.cloneNode());
      if (clone_first_row) {
        $(next_page).append($(rows[0]).clone());
      }
      if (!$(row).hasClass('group') && $(row).next().hasClass('row') && !$(row).hasClass('pricediv')) {
        row = $(row).prev();
        while (row.length && !row.hasClass('group')) {
          row = $(row).prev();
        }
        if (row.hasClass('group')) {
          row = row.clone();
          cont = $('[cont]', row);
          cont.text(cont.attr('cont') + '（续）');
          $(next_page).append($(row));
        }
      }
      $(next_page).append(rows.slice(index));
      return process(next_page, clone_first_row);
    }
  };

  $('.log-page').each(function() {
    return process($(this)[0], $(this).hasClass('on'));
  });

  set_appendix($('.appendix1'), '附件一');

  set_appendix($('.appendix2'), '附件二');

  set_appendix($('.appendix3'), '附件三');

  set_mark($('.mark'));

  setPageNum($('.content'));

  createCatalogue();

}).call(this);
