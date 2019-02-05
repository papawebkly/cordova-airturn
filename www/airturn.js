
var exec = require('cordova/exec');
var channel = require('cordova/channel');

module.exports = {

    _channels: {},
    createEvent: function (type, data) {
        var event = document.createEvent('Event');
        event.initEvent(type, false, false);
        if (data) {
            for (var i in data) {
                if (data.hasOwnProperty(i)) {
                    event[i] = data[i];
                }
            }
        }
        return event;
    },
    initAirTurn: function (success, error) {
        exec(success, error, "airturn", "initAirTurn", null);
    },
    makeActive: function(success, error) {
        exec(success, error, "airturn", "makeActive", null);
    },
    allowWebViewFirstResponders: function (success, error) {
        exec(success, error, "airturn", "allowWebViewFirstResponders", null);
    },
    setting: function (success, error) {
        exec(success, error, "airturn", "setting", null);
    },

    isConnected: function (success, error) {
        exec(success, error, "airturn", "isConnected", null);
    },

    getInfo: function (success, error) {
        exec(success, error, "airturn", "getInfo", null);
    },

    killApp: function (success, error) {
        exec(success, error, "airturn", "killApp", null);
    },

    fireEvent: function (type, data) {
        var event = this.createEvent(type, data);
        if (event && (event.type in this._channels)) {
            this._channels[event.type].fire(event);
        }
    },

    addAirTurnEventListener: function (eventname, f) {
        if (!(eventname in this._channels)) {
            var me = this;
            exec(function () {
                me._channels[eventname] = channel.create(eventname);
                me._channels[eventname].subscribe(f);
            }, function (err) {
                console.log("ERROR addEventListener: " + err);
            }, "airturn", "addEventListener", [eventname]);
        }
        else {
            this._channels[eventname].subscribe(f);
        }
    },

    removeEventListener: function (eventname, f) {
        if (eventname in this._channels) {
            var me = this;
            exec(function () {
                me._channels[eventname].unsubscribe(f);
            }, function (err) {
                console.log("ERROR removeEventListener: " + err);
            }, "airturn", "removeEventListener", [eventname]);
        }
    }

};

