// Generated by CoffeeScript 1.6.3
var events_bind, render_departments, render_profile, render_record;

render_profile = function(barcode) {
  return $.get("/records/" + barcode + "?fields=profile.basic", function(record) {
    $('.name').html(record.profile.name);
    $('.sex').html(record.profile.sex);
    return $('.age').html(record.profile.age);
  });
};

render_departments = function(barcode) {
  return $.get("/records/" + barcode, function(record) {
    var c, content, d, departments, ids, room_id, rooms, _i, _len, _ref;
    departments = record.departments;
    content = [];
    departments = departments.filter(function(d) {
      var _ref, _ref1;
      return ((_ref = d.status) === '未完成' || _ref === '未采样' || _ref === '放弃' || _ref === '延期') && ((_ref1 = d.name) !== '尿常规' && _ref1 !== '便潜血' && _ref1 !== '便隐血');
    });
    for (_i = 0, _len = departments.length; _i < _len; _i++) {
      d = departments[_i];
      if (d.name.match(/(宫颈.*细胞学|TCT)/)) {
        d.name = 'TCT标本';
      } else if (d.name.match(/宫颈刮片/)) {
        d.name = '宫颈刮片标本';
      } else if (d.name.match(/白带常规/)) {
        d.name = '白带常规标本';
      }
      if (d.category === 'laboratory' && ((_ref = d.required_samplings) != null ? _ref.some(function(s) {
        return s.match(/采血/);
      }) : void 0)) {
        d.room_id = '000000000000000000000001';
        d.name = '采血';
      } else {
        d.room_id = d._id;
      }
    }
    rooms = _.groupBy(departments, function(d) {
      return d.room_id;
    });
    content = (function() {
      var _results;
      _results = [];
      for (room_id in rooms) {
        departments = rooms[room_id];
        c = {};
        ids = departments.reduce(function(memo, d) {
          memo.push(d._id);
          return memo;
        }, []);
        c._id = ids.join(',');
        c.room_id = room_id;
        c.name = departments[0].name;
        if (departments.some(function(d) {
          var _ref1;
          return (_ref1 = d.status) === '未完成' || _ref1 === '未采样';
        })) {
          c.status = 'incomplete';
          c.index = 1;
        } else if (departments.some(function(d) {
          return d.status === '放弃';
        })) {
          c.status = 'giveup';
          c.index = 2;
        } else if (departments.some(function(d) {
          return d.status === '延期';
        })) {
          c.status = 'reschedule';
          c.index = 3;
        }
        _results.push(c);
      }
      return _results;
    })();
    content = _.sortBy(content, function(item) {
      return item.index;
    });
    $('ul').html(Mustache.render($('#template').html(), content));
    if (content.length <= 6) {
      $('ul').addClass('status1');
    } else {
      $('ul').addClass('status2');
    }
    return events_bind(barcode);
  });
};

events_bind = function(barcode) {
  var actions, hammer;
  actions = {
    'giveup': 'reschedule',
    'reschedule': 'giveup',
    'incomplete': 'giveup'
  };
  $("li").click(function(event) {
    var id, status,
      _this = this;
    event.stopPropagation();
    id = $(this).attr('_id');
    status = actions[$(this).attr('class')];
    return $.ajax({
      type: 'POST',
      url: "records/" + barcode + "/departments/" + id + "/" + status,
      success: function(result) {
        return $(_this).attr('class', status);
      }
    });
  });
  hammer = new Hammer($("ul")[0]);
  return hammer.ondragstart = function(event) {
    var directions, ids;
    ids = [];
    $("li.incomplete").each(function() {
      return ids.push($(this).attr('_id'));
    });
    ids = ids.join(',') || '';
    directions = {
      'right': 'giveup',
      'left': 'reschedule'
    };
    if (ids) {
      return $.ajax({
        type: 'POST',
        url: "records/" + barcode + "/departments/" + directions[event.direction] + "?departments=" + ids,
        success: function(result) {
          return $("li.incomplete").attr('class', directions[event.direction]);
        }
      });
    }
  };
};

render_record = function(barcode) {
  render_profile(barcode);
  return render_departments(barcode);
};

barcode.regist(/\d{8}/, render_record);
