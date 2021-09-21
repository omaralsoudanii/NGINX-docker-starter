(()=>{/*!instant.page v5.1.0 - (C) 2019-2020 Alexandre Dieulot - https://instant.page/license*/var mouseoverTimer;var lastTouchTimestamp;var prefetches=new Set();var prefetchElement=document.createElement("link");var isSupported=prefetchElement.relList&&prefetchElement.relList.supports&&prefetchElement.relList.supports("prefetch")&&window.IntersectionObserver&&"isIntersecting"in IntersectionObserverEntry.prototype;var allowQueryString="instantAllowQueryString"in document.body.dataset;var allowExternalLinks="instantAllowExternalLinks"in document.body.dataset;var useWhitelist="instantWhitelist"in document.body.dataset;var mousedownShortcut="instantMousedownShortcut"in document.body.dataset;var DELAY_TO_NOT_BE_CONSIDERED_A_TOUCH_INITIATED_ACTION=1111;var delayOnHover=65;var useMousedown=false;var useMousedownOnly=false;var useViewport=false;if("instantIntensity"in document.body.dataset){const intensity=document.body.dataset.instantIntensity;if(intensity.substr(0,"mousedown".length)=="mousedown"){useMousedown=true;if(intensity=="mousedown-only"){useMousedownOnly=true;}}else if(intensity.substr(0,"viewport".length)=="viewport"){if(!(navigator.connection&&(navigator.connection.saveData||navigator.connection.effectiveType&&navigator.connection.effectiveType.includes("2g")))){if(intensity=="viewport"){if(document.documentElement.clientWidth*document.documentElement.clientHeight<45e4){useViewport=true;}}else if(intensity=="viewport-all"){useViewport=true;}}}else{const milliseconds=parseInt(intensity);if(!isNaN(milliseconds)){delayOnHover=milliseconds;}}}
if(isSupported){const eventListenersOptions={capture:true,passive:true};if(!useMousedownOnly){document.addEventListener("touchstart",touchstartListener,eventListenersOptions);}
if(!useMousedown){document.addEventListener("mouseover",mouseoverListener,eventListenersOptions);}else if(!mousedownShortcut){document.addEventListener("mousedown",mousedownListener,eventListenersOptions);}
if(mousedownShortcut){document.addEventListener("mousedown",mousedownShortcutListener,eventListenersOptions);}
if(useViewport){let triggeringFunction;if(window.requestIdleCallback){triggeringFunction=(callback)=>{requestIdleCallback(callback,{timeout:1500});};}else{triggeringFunction=(callback)=>{callback();};}
triggeringFunction(()=>{const intersectionObserver=new IntersectionObserver((entries)=>{entries.forEach((entry)=>{if(entry.isIntersecting){const linkElement=entry.target;intersectionObserver.unobserve(linkElement);preload(linkElement.href);}});});document.querySelectorAll("a").forEach((linkElement)=>{if(isPreloadable(linkElement)){intersectionObserver.observe(linkElement);}});});}}
function touchstartListener(event){lastTouchTimestamp=performance.now();const linkElement=event.target.closest("a");if(!isPreloadable(linkElement)){return;}
preload(linkElement.href);}
function mouseoverListener(event){if(performance.now()-lastTouchTimestamp<DELAY_TO_NOT_BE_CONSIDERED_A_TOUCH_INITIATED_ACTION){return;}
const linkElement=event.target.closest("a");if(!isPreloadable(linkElement)){return;}
linkElement.addEventListener("mouseout",mouseoutListener,{passive:true});mouseoverTimer=setTimeout(()=>{preload(linkElement.href);mouseoverTimer=void 0;},delayOnHover);}
function mousedownListener(event){const linkElement=event.target.closest("a");if(!isPreloadable(linkElement)){return;}
preload(linkElement.href);}
function mouseoutListener(event){if(event.relatedTarget&&event.target.closest("a")==event.relatedTarget.closest("a")){return;}
if(mouseoverTimer){clearTimeout(mouseoverTimer);mouseoverTimer=void 0;}}
function mousedownShortcutListener(event){if(performance.now()-lastTouchTimestamp<DELAY_TO_NOT_BE_CONSIDERED_A_TOUCH_INITIATED_ACTION){return;}
const linkElement=event.target.closest("a");if(event.which>1||event.metaKey||event.ctrlKey){return;}
if(!linkElement){return;}
linkElement.addEventListener("click",function(event2){if(event2.detail==1337){return;}
event2.preventDefault();},{capture:true,passive:false,once:true});const customEvent=new MouseEvent("click",{view:window,bubbles:true,cancelable:false,detail:1337});linkElement.dispatchEvent(customEvent);}
function isPreloadable(linkElement){if(!linkElement||!linkElement.href){return;}
if(useWhitelist&&!("instant"in linkElement.dataset)){return;}
if(!allowExternalLinks&&linkElement.origin!=location.origin&&!("instant"in linkElement.dataset)){return;}
if(!["http:","https:"].includes(linkElement.protocol)){return;}
if(linkElement.protocol=="http:"&&location.protocol=="https:"){return;}
if(!allowQueryString&&linkElement.search&&!("instant"in linkElement.dataset)){return;}
if(linkElement.hash&&linkElement.pathname+linkElement.search==location.pathname+location.search){return;}
if("noInstant"in linkElement.dataset){return;}
return true;}
function preload(url){if(prefetches.has(url)){return;}
const prefetcher=document.createElement("link");prefetcher.rel="prefetch";prefetcher.href=url;document.head.appendChild(prefetcher);prefetches.add(url);}
var viewAllButton=document.querySelector(".js-view-all");if(viewAllButton){viewAllButton.addEventListener("click",(event)=>{event.preventDefault();document.querySelector(".js-all").classList.remove("hidden");viewAllButton.parentNode.removeChild(viewAllButton);});}
var getLoadTime=()=>(window.performance.timing.domContentLoadedEventEnd-window.performance.timing.navigationStart)/1e3;window.addEventListener("load",()=>{document.querySelector(".js-loaded-in").innerText=`- loaded in ${getLoadTime()}s`;});var themeStorageKey="theme";var getTheme=()=>{return localStorage.getItem(themeStorageKey)||"dark";};var setLightMode=()=>{try{localStorage.setItem(themeStorageKey,"light");document.documentElement.classList.add("light");document.documentElement.classList.remove("dark");}catch(err){console.error(err);}};var setDarkMode=()=>{try{localStorage.setItem(themeStorageKey,"dark");document.documentElement.classList.remove("light");document.documentElement.classList.add("dark");}catch(err){console.error(err);}};var toggleTheme=()=>{const theme2=getTheme();if(theme2==="dark"){setLightMode();}else{setDarkMode();}};(()=>{const toggle=document.querySelector(".js-theme-toggle");if(toggle)
toggle.addEventListener("click",toggleTheme,false);})();})();