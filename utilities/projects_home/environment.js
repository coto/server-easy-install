    function hasClass(ele,cls) {
		return ele.className.match(new RegExp('(\\s|^)'+cls+'(\\s|$)'));
	}
	function addClass(ele,cls) {
		if (!this.hasClass(ele,cls)) ele.className += " "+cls;
	}
	function removeClass(ele,cls) {
		if (hasClass(ele,cls)) {
			var reg = new RegExp('(\\s|^)'+cls+'(\\s|$)');
			ele.className=ele.className.replace(reg,' ');
		}
	}

	backs = ["1223285840843.jpeg", "1223285840885.jpeg", "1223287650751.jpeg", "1223287688562.jpeg", "1223287769682.jpeg", "1223287773856.jpeg", "1223287778664.jpeg", "1223287779413.jpeg", "1223287780018.jpeg", "1223287782160.jpeg", "1223287789692.jpeg", "1223287792172.jpeg", "1223287792822.jpeg", "1223287797524.jpeg", "1223287804852.jpeg", "1223287808725.jpeg", "1223287809041.jpeg", "1223287824000.jpeg", "1223287824276.jpeg", "1223289615815.jpeg", "1223290016344.jpeg", "1223291800752.jpeg", "1223294724231.jpeg", "1223297337677.jpeg", "1223299128959.jpeg", "1223299315388.jpeg", "1227883742635.jpeg", "1227895573514.jpeg", "1227896423609.jpeg", "1227900338912.jpeg", "1227902714200.jpeg", "1227920142561.jpeg", "wallpaper.gif","1227944208161.gif", "1227965332814.jpeg", "1227954597124.jpeg", "1223291800753.jpeg"];
	window.onload = function(){
		var content = document.getElementById("Content");
		rdm_index = Math.floor(Math.random()*backs.length);
		//better backs[34]
		content.style.background = "transparent url('./backgrounds/" +  backs[rdm_index] + "') 0 0 no-repeat";
		addClass(content, "back_" + Math.floor(rdm_index));
	}
