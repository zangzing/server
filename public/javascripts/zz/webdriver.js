
var webdriver = {
    async_count: 0,
    document_ready: false,

    enter_async: function(){
        this.async_count+=1;
    },

    leave_async: function(){
        this.async_count-=1;
    },

    javascript_done: function(){
        return (this.async_count == 0 && $(':animated').length == 0);
    },

    ready: function(){
        return this.document_ready && this.javascript_done();
    }

};

$(document).ready(function(){
    webdriver.document_ready = true;
});

$(document).ajaxSend(function(){
    webdriver.enter_async();
});

$(document).ajaxComplete(function(){
    webdriver.leave_async();
});
