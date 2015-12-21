
(function(window) {
    'use strict';


    window.monitor_front = window.monitor_front || {
    
        getTimes: function(opts) {
            var performance = window.performance || window.webkitPerformance || window.msPerformance || window.mozPerformance;

            if (performance === undefined) {
                console.log('Unfortunately, your browser does not support the Navigation Timing API');
                return;
            }

            var timing = performance.timing;

            var api = {};
            opts = opts || {};

            if (timing) {
                if(opts && !opts.simple) {
                    for (var k in timing) {
                        if (timing.hasOwnProperty(k)) {
                            api[k] = timing[k];
                        }
                    }
                }
                // Time to first paint
                if (api.firstPaint === undefined) {
                    // All times are relative times to the start time within the
                    // same objects
                    var firstPaint = 0;

                    // Chrome
                    if (window.chrome && window.chrome.loadTimes) {
                        // Convert to ms
                        firstPaint = window.chrome.loadTimes().firstPaintTime * 1000;
                        api.firstPaintTime = firstPaint - (window.chrome.loadTimes().startLoadTime * 1000);
                    }
                    // IE
                    else if (typeof window.performance.timing.msFirstPaint === 'number') {

                        firstPaint = window.performance.timing.msFirstPaint;
                        api.firstPaintTime = firstPaint - window.performance.timing.navigationStart;
                    }
                    // Firefox
                    // This will use the first times after MozAfterPaint fires
                    //else if (window.performance.timing.navigationStart && typeof InstallTrigger !== 'undefined') {
                    //    api.firstPaint = window.performance.timing.navigationStart;
                    //    api.firstPaintTime = mozFirstPaintTime - window.performance.timing.navigationStart;
                    //}
                    if (opts && !opts.simple) {
                        api.firstPaint = firstPaint;
                    }
                }

                // Total time from start to load
                api.loadTime = timing.loadEventEnd - timing.fetchStart;
                // Time spent constructing the DOM tree
                api.domReadyTime = timing.domComplete - timing.domInteractive;
                // Time consumed preparing the new page
                api.readyStart = timing.fetchStart - timing.navigationStart;
                // Time spent during redirection
                api.redirectTime = timing.redirectEnd - timing.redirectStart;
                // AppCache
                api.appcacheTime = timing.domainLookupStart - timing.fetchStart;
                // Time spent unloading documents
                api.unloadEventTime = timing.unloadEventEnd - timing.unloadEventStart;
                // DNS query time
                api.lookupDomainTime = timing.domainLookupEnd - timing.domainLookupStart;
                // TCP connection time
                api.connectTime = timing.connectEnd - timing.connectStart;
                // Time spent during the request
                api.requestTime = timing.responseEnd - timing.requestStart;
                // Request to completion of the DOM loading
                api.initDomTreeTime = timing.domInteractive - timing.responseEnd;
                // Load event time
                api.loadEventTime = timing.loadEventEnd - timing.loadEventStart;

                api.dom_time = timing.domComplete - timing.navigationStart;//用户可操作时间

                api.load_time = timing.loadEventEnd - timing.navigationStart;//完全加载时间

            }

            return api;
        },
        /**
         * Uses console.table() to print a complete table of timing information
         * @param  Object opts Options (simple (bool) - opts out of full data view)
         */
        printTable: function(opts) {
            var table = {};
            var data  = this.getTimes(opts) || {};
            Object.keys(data).sort().forEach(function(k) {
                table[k] = {
                    ms: data[k],
                    s: +((data[k] / 1000).toFixed(2))
                };
            });
            console.table(table);
        },
        /**
         * Uses console.table() to print a summary table of timing information
         */
        printSimpleTable: function() {
            this.printTable({simple: true});
        },

        getFristViewTime: function(first_view_bg){
        	if(!performance.getEntriesByType){
        		return 0;
        	}
        	var $img = $('img,embed'), 
	        	_h = window.innerHeight, 
	        	names = [];
	        if(first_view_bg){
	        	names.push(first_view_bg);
	        }
        	for(var i = 0,len = $img.length; i < len; i++){
        		var img = $img.eq(i);
        		if(img.offset().top < _h){
        			names.push(img[0].src);
        		}else{
        			break;
        		}
        		// console.log(img);
        		// console.log(i);
        	}
        	
			var resource = window.performance.getEntriesByType("resource");
			var time = 0;
			for(var index in names){
        		var name = names[index];
				for (var i = 0; i < resource.length; i++) {
					if(resource[i].name.indexOf(name) > -1){
						if(resource[i].responseEnd > time){
							time = resource[i].responseEnd;
						}
						break;
					}
				};
			}
			return time;
		},
		setCookie: function(name,value){ 
			var Days = 1; 
			var exp = new Date(); 
			exp.setTime(exp.getTime() + Days * 24 * 60 * 60 * 1000); 
			document.cookie = name + "=" + escape (value) + ";expires=" + exp.toGMTString(); 
		},
		getCookie: function(name){
			var arr = document.cookie.match(new RegExp("(^| )" + name + "=([^;]*)(;|$)")); 
			if(arr != null) return unescape(arr[2]); return null; 
		}, 
	
		getBrowserInfo: function(){
			var agent = navigator.userAgent.toLowerCase() ;

			var regStr_ie = /msie [\d.]+;/gi ;
			var regStr_ff = /firefox\/[\d.]+/gi
			var regStr_chrome = /chrome\/[\d.]+/gi ;
			var regStr_saf = /safari\/[\d.]+/gi ;
			//IE
			if(agent.indexOf("msie") > 0)
			{
				return {
					name: 'ie',
					version: agent.match(regStr_ie)[0].replace(/[^0-9.]/ig,"")
				};
			}
			//firefox
			if(agent.indexOf("firefox") > 0)
			{
				return {
					name: 'firefox',
					version: agent.match(regStr_ff)[0].replace(/[^0-9.]/ig,"")
				};
			}
			//Chrome
			if(agent.indexOf("chrome") > 0)
			{
				return {
					name: 'chrome',
					version: agent.match(regStr_chrome)[0].replace(/[^0-9.]/ig,"")
				};
			}
			//Safari
			if(agent.indexOf("safari") > 0 && agent.indexOf("chrome") < 0)
			{
				return {
					name: 'safari',
					version: agent.match(regStr_saf)[0].replace(/[^0-9.]/ig,"")
				};
			}

		},

		Monitor: function(pageName, resources, first_view_bg){
			// 如果拿不到performance，则不统计
			if(!window.performance){
				return null;
			}
			// if(this.getCookie('monitor_flag')){
			// 	return null
			// }
			this.setCookie('monitor_flag',new Date().valueOf());
			// 稀释统计频次
			// if(Math.random() > 0.0001){
			// 	return null;
			// }
			// resources = [
			// 	{
			// 		fileName: "xxx.png",
			// 		isFirstView: true
			// 	}
			// ]

			var performance = this.getTimes();
			
			var browser = this.getBrowserInfo();
			var data = {};
			var sendTime = new Date().valueOf();
			resources = resources ? resources: [];
			pageName = pageName ? pageName: 'index';
			
			data.timing = performance;
			data.browser_name = browser.name;
			data.browser_version = browser.version;
			data.screen_height = window.screen.height;
			data.screen_width = window.screen.width;
			data.page_name = pageName;
			// data.start_render = performance.start_render;
			// data.dom_ready = performance.dom_ready;
			// data.page_load = performance.page_load;
			// data.connect_time = performance.connectTime;
			data.timing.first_view = this.getFristViewTime(first_view_bg);
			data.timing.first_view = data.timing.first_view ? data.timing.first_view : data.timing.dom_time;


			var _data = {
				browser_name: data.browser_name,
				browser_version: data.browser_version,
				resolution: data.screen_width + "*" + data.screen_height,
				first_view: data.timing.first_view,
				first_paint: data.timing.firstPaintTime,
				dom_ready: data.timing.dom_time,
				load_time: data.timing.load_time,
				page_name: data.page_name
			};

			$.ajax({
					url: 'http://10.1.172.58:8200/api/receive',
					method: 'get',
					data:_data,
					error:function(err){
						throw err;
					}
			});

		}
    };

})(this);
// var aaa=0,bbb=0,ccc=0;
// for(var m=0,l=50;m<l;m++){
// 	aaa=0,bbb=0;
// 	for(var i=0,len=1000000;i<len;i++){
// 		window.timing.Monitor('百度首页', null, null);
// 	}
// 	ccc+=bbb;
// 	console.log("样本值="+bbb);
// }

// 	console.log("平均值="+ccc/50);


