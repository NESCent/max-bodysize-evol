menu_init = function() {
  var elements = document.getElementById("top_menu").getElementsByTagName("LI");
  
  for (var i = 0; i < elements.length; i++) {
    elements[i].onmouseover=function() {
			this.className+=" iehover";
    }
    elements[i].onmouseout=function() {
			this.className=this.className.replace(new RegExp(" iehover\\b"), "");
    }
  }
}

if (window.attachEvent) window.attachEvent("onload", menu_init);
