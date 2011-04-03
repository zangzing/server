
jQuery(function ($) {
    $('#basic-modal-content').modal();
});
jQuery(document).ready(function(){
	var next = new Array();
	var back = new Array();
	for (var i=1; i<7; i++){
		next[i] = '#next'+i;
		back[i] = '#back'+i;
		$(next[i]).click(function(){
			var id = this.id;
			var numb = id.split('t');
			numb=parseInt(numb[1]);
			var step ="step"+numb;
			var stepnext ="step"+(numb+1);
			$('#'+step).css('display','none');
			$('#'+stepnext).css('display','block');
		});
		$(back[i]).click(function(){
			var id = this.id;
			var numb = id.split('k');
			numb=parseInt(numb[1]);
			var step ="step"+numb;
			var stepnext ="step"+(numb-1);
			$('#'+step).css('display','none');
			$('#'+stepnext).css('display','block');
		});		
	}	
});