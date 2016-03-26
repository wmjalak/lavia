define(['momenttimezone'], function(moment) {

  var tzdetect = {
    names: moment.tz.names(),
    matches: function(){
      var results = [], now = Date.now(), makekey = function(id){
        return [0, 4, 8, -5*12, 4-5*12, 8-5*12, 4-2*12, 8-2*12].map(function(months){
          var m = moment(now + months*30*24*60*60*1000);
          if (id) m.tz(id);
          return m.format("DDHH");
        }).join(' ');
      }, lockey = makekey();
      tzdetect.names.forEach(function(id){
        if (makekey(id)===lockey) results.push(id);
      });
      return results;
    }
  };

  var DateWithTimezone = function () {
  };

  DateWithTimezone.prototype.detectTimezone = function() {
    if (this.localTimezoneName == undefined) {
      this.setTimezone(tzdetect.matches()[0]);
    }
  }

  DateWithTimezone.prototype.convertToMoment = function(dateString) {
    return moment.tz(dateString, this.localTimezoneName);
  }

  DateWithTimezone.prototype.convertToDate = function(dateString) {
    m = this.convertToMoment(dateString);
    /* NOTE: Date object uses current locale timezone */
    return new Date(m.get('year'), m.get('month'), m.get('date'), m.get('hour'), m.get('minute'), m.get('second'), m.get('millisecond')); 
  }

  DateWithTimezone.prototype.convertToFormattedString = function(dateString, format) {
    //m = moment.tz(moment(dateString), this.localTimezoneName);
    m = moment.tz(dateString, this.localTimezoneName);
    return m.format(format);
  }

  /* for testing purposes */
  DateWithTimezone.prototype.setTimezone = function(timezoneIdentifier) {
    this.localTimezoneName = timezoneIdentifier;
    console.log("setTimezone: " + this.localTimezoneName);
  }

  return DateWithTimezone;

});
