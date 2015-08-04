var e = document.createEvent('Events');
e.initEvent("hybriddeviceready");
document.dispatchEvent(e);
window.hybriddeviceready = true;
